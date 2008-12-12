module HN.SplExport where
import HN.Intermediate
import SPL.Types

convertExpr (Constant (ConstInt i)) = CNum i
convertExpr (Constant (ConstString i)) = CStr i

convertExpr (Atom a) = CVal a
convertExpr (Application a b) = CL (convertExpr a) (K $ map convertExpr b)
convertExpr expr = error $ show expr 

convertDef (Definition _ [] value []) = convertExpr value

convertDef (Definition _ arguments value whereDefinitions) 
	= (case arguments of
		[] -> convertedWithWhere
		_ -> CL xvalue (S arguments)) where
		xvalue = case whereDefinitions of
			[] -> convertExpr value
			_  -> convertedWithWhere
		whereVars = whereMap (\(Definition name _ _ _) -> name)
		whereValues = whereMap convertDef
		whereMap f = map f whereDefinitions
		convertedWithWhere = CL (CL (convertExpr value) (S whereVars)) (K whereValues)