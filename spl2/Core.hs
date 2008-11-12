module Core where

import Intermediate
import qualified Data.Set as S
import qualified Data.Map as M
import Data.List

import Debug.Trace
import Visualise
import Utils

-- inherited attributes for Definition
data DefinitionInherited = DefinitionInherited {
	diLevel :: Int,
	diSymTab :: M.Map String CppAtomType
}

-- synthesized attributes for Definition
data DefinitionSynthesized = DefinitionSynthesized {
	dsCppDef :: CppDefinition
}

sem_Definition inh self @ (Definition name args val wh)
    = DefinitionSynthesized {
    	dsCppDef = CppFunctionDef {
		    	functionLevel 			= diLevel inh
		    ,	functionIsStatic		= isFunctionStatic self
			,	functionReturnTypeName 	= "int"
			,	functionContext			= getContext inh symTabWithStatics self
			,	functionName 			= name
			,	functionArgs 			= map (CppVarDecl "int") args
			,	functionLocalVars 		= wsLocalVars semWhere
			,	functionRetExpr			= sem_Expression (symTabTranslator symTabWithoutArgsAndLocals) val 	    	
		    }
    } where
    	-- localsList : semWhere 
    	localsList = map (\(CppVar _ name _ ) -> name) (wsLocalVars semWhere)
    	-- symTabWithStatics : semWhere
      	symTabWithStatics = (wsLocalFunctionMap semWhere) `M.union` (diSymTab inh)   	

		-- symTabWithoutArgsAndLocals : self symTabWithStatics localsList      	
    	symTabWithoutArgsAndLocals = symTabWithStatics `subtractKeysFromMap` args `subtractKeysFromMap` localsList
    	  	
    	semWhere = sem_Where symTabT classPrefix isFunctionStatic (diSymTab inh) wh where
	    	classPrefix = CppFqMethod $ name ++ "_impl"
	    	-- symTabT : symTabWithStatics 
    		symTabT = symTabTranslator symTabWithStatics
    
    	isFunctionStatic def  = S.null $ getDefinitionFreeVarsWithoutFqn def where
    	    getDefinitionFreeVarsWithoutFqn def = getDefinitionFreeVars def `subtractSet` M.keysSet (diSymTab inh)
  	
data WhereSynthesized = WhereSynthesized {
	wsLocalVars :: [CppLocalVarDef]
,	wsLocalFunctionMap :: M.Map String CppAtomType
}
    	
sem_Where symTabT classPrefix isFunctionStatic symTab self 
	= WhereSynthesized {
		wsLocalVars = getWhereVars symTabT self
	,	wsLocalFunctionMap = getFunctionMap
	} where 	
		getFunctionMap = M.fromList $ mapPrefix classPrefix isFunctionStatic ++ mapPrefix objPrefix (not . isFunctionStatic) where
			objPrefix = CppContextMethod
			mapPrefix prefix fn = map (\(Definition locName _ _ _) -> (locName, prefix)) $ filter (\x -> isFunction x && (fn x)) self
    
isFunction (Definition _ args _ _) = not $ null args

symTabTranslator symTab f x = case M.lookup x symTab of
	Just (CppFqMethod prefix) -> prefix ++ "::" ++ x
	Just CppContextMethod -> if f then "impl." ++ x else "hn::bind(impl, &local::" ++ x ++ ")" 
	Nothing -> x

getContext inh fqnWithLocals def @ (Definition name args _ wh) = constructJust (null vars && null methods) $ CppContext (diLevel inh) (name ++ "_impl") vars methods where

	-- ���������� ��������� - ��� 
	-- ��������� ������� �������, ��������� � where-��������
	-- ��������� ����������, ��������� � where-�������� 
	vars = (filter (\(CppVar _ name _ ) -> not $ S.member name lvn) $ getWhereVars (symTabTranslator (diSymTab inh)) wh) ++ contextArgs   
	methods = getWhereMethods ((diLevel inh) + 1) (diSymTab inh) def
	lvn = getLocalVars wh
	contextArgs = map (\x -> CppVar "int" x $ CppAtom x) $ filter isArgContext args

	wfv = getWhereFuncFreeVars def
	
	isArgContext a = S.member a wfv 
	
isVar (Definition _ args _ _) = null args
getFromWhere wh mf ff = map mf $ filter ff wh

getWhereVars fqn def = getFromWhere def (transformVarDefinition fqn) isVar
getWhereMethods level fqn def @ (Definition _ _ _ wh) = getFromWhere wh ((.) dsCppDef $ sem_Definition $ DefinitionInherited level fqn) (not . isVar)
getWhereX wh f = S.fromList $ getFromWhere wh (\(Definition name _ _ _) -> name) f

getWhereVarNames wh = getWhereX wh isVar 
getWhereAtoms wh =  getWhereX wh (const True)

-- ��������� ���������� - ������ �������
getLocalVars wh = getWhereVarNames wh    

-- ����������� ���������� - � impl
getContextVars def = getXVars subtractSet def

-- ������� ���������� - � impl.outer
getOuterVars def = getXVars S.intersection def

getXVars fn def = fn (getWhereFreeVars def) (getDefinitionFreeVars def)

-- ����������, ��������� � ������ where. ����� ���� ������������ ��� ��������
getWhereFreeVars (Definition _ _ _ wh) = getSetOfListFreeVars wh

getWhereFuncFreeVars (Definition _ _ _ wh) = getSetOfListFreeVars (filter isFunction wh)

getSetOfListFreeVars ww = S.unions $ map getDefinitionFreeVars ww

transformVarDefinition fqn def @ (Definition name [] val _) =
	CppVar "int" name $ sem_Expression fqn val
	
sem_Expression fqn p = case p of
	Atom x -> CppAtom $ fqn False x
	Constant x -> CppLiteral x
	-- ���� hn::bind(impl, &main_impl::a) - CppApplication CppAtom "hn::bind" [ CppAtom "impl", CppPtr (CppAtom a) ] 
	-- ���� impl.a - CppField impl a
	-- ���� &main_impl::a - CppPtr (CppAtom a)
	Application x y -> CppApplication transformApplicand (map transformOperand y) where
		transformApplicand = case x of
			Atom a -> CppAtom $ fqn True a
			_ -> sem_Expression fqn x
		transformOperand (Atom a) = CppAtom $ if elem ':' aaa && (not $ isPrefixOf "hn::" aaa) then '&' : aaa else aaa where
				aaa = fqn False a
		transformOperand x = sem_Expression fqn x

getExpressionAtoms (Atom x) = S.singleton x
getExpressionAtoms (Application a b) = S.unions $ map getExpressionAtoms (a : b)  
getExpressionAtoms _ = S.empty

getDefinitionFreeVars def @ (Definition _ args val wh) 
	= (S.union (getExpressionAtoms val) (getSetOfListFreeVars wh)) `subtractSet` (S.fromList args) `subtractSet` (getWhereAtoms wh)