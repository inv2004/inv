
module Main where

-- import Visualise
import Core
import HN.Parser2
import HN.ParserTest
import Utils
import qualified Data.Map as M
import HN.MyTypeCheck
import HN.TypeParser
import Intermediate
import CPP.Intermediate

import Check3
import Types
import HN.SplExport
import CPP.TypeProducer
import qualified Top


simpleParse prog = head $ fromRight $ parseProg prog

baseToTdi = M.map (const $ CppFqMethod "ff") Top.get_types

tdi = DefinitionInherited {
	diLevel        = 3,
	diSymTab       = baseToTdi,
	diFreeVarTypes = Top.get_types
}
    
testCodeGen = rt (dsCppDef . (sem_Definition tdi))

test2 = rt (getDefinitionFreeVars) 

rt f = mapM (print . f . simpleParse) testSet

testSet =
	[
		-- ��������, ������ ffi-�������
		"main = incr 2"
		-- ����������� �������, 1 ��������
	,	"main x = incr x"
		-- ��������� ����������
	,	"main x z = sum x z"
		-- ����������� �������
		-- BROKEN �� ������ ���� typedef local
	,	"main x = { o a b = sum a b\no x x }"
		-- ���������� fqn-������� ����������
	,	"main sum = incr sum"
		-- ���������� fqn-������� ����������� ���������
		-- BROKEN �� ������ ���� typedef local
	,	"main x = { elist a b = sum a b\nelist x x }" 
		-- ���������� fqn-������� ��������� ����������
	,	"main x z = { head = incr z\nsum x head }"
		-- ����������� ������
	,	"main = \"aaa\""
		-- ���������� fqn-������� ����������� 
	,	"main x = { head z a = z a x\nhead sum 5 }"
		-- ��������� ��������� c ����������
	,	"main a b = { c i = sum i b\nincr (sum a (c a)) }"
 
	,	"main a b = { c i x = sum b (sum x i)\nd i = sum i i\nincr (c a (d a)) }"
		-- ��������� ����������
	,	"main x = { y = sum x x\nsum y y }"
		-- & ����� ����������� �� ������� (������������� ����� ���������� C++)
		-- ������� ��� �������� ��������� ������� �����������
		-- f x y a -> f(x, y, hn::bind(impl, &main_impl::a)) 
	,	"main x z l = { a = incr z\ny z = less (sum x a) z\nfilter y l }"
		-- BROKEN & ����� ����������� �� ����������� ������� 
	,	"main l = {\n\tf x = less 1 x\n\tfilter f l\n}"
	
	-- l*((f*(filter f l)) (x*less 1 x)) 		
	
	]
	
defaultEnv = Env 1 $ M.fromList $ map (\(a, b) -> (a, simpleParse2 b)) [
		("head",  "(List 1) -> 1" )
	,	("plus1", "Int -> Int" )
	]

testCheck3 = mapM (print . check0 . convertExpr) [
		Constant (ConstInt 123),
		Atom "a",
		Application (Atom "sum") $ map (Constant . ConstInt) [1, 2],
		Application (Atom "incr") $ [Atom "x"]
	]
	
main = do
--	mapM (print . simpleParse2) $ [ "aaa", "aaa bbb", "aaa -> bbb", "(List 1) -> 1", "Int -> Int" ]
--	print defaultEnv 
	mapM (print . snd . (typeCheck defaultEnv)) [
--			Atom "l"
--		,	Atom "head"
--		,	Application (Atom "head") [Atom "l"]
		]  
	runTests

	testCheck3
	rt convertDef
	rt $ \x -> check0 (convertDef x)
--	test2
	print $ cppType $ T "num"
	
	testCodeGen
 	getLine
	return ()
