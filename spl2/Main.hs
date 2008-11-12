
module Main where

import Visualise
import Core
import ParserTest
import Parser2
import Utils
import qualified Data.Map as M
import MyTypeCheck
import TypeParser
import Intermediate

import Check3
import Code

simpleParse prog = head $ fromRight $ parseProg prog

tdi = DefinitionInherited {
	diLevel = 3,
	diSymTab = M.fromList [ ("f", CppFqMethod "ffi"),  ("g", CppFqMethod "ffi"), ("h", CppFqMethod "ffi")]
}
    
test1 = rt (dsCppDef . (sem_Definition tdi))

test2 = rt (getDefinitionFreeVars) 

rt f = mapM (print . f . simpleParse) testSet

testSet = 
	[
		-- ������ ffi-�������
		"main = f x"
		-- ����������� �������, 1 ��������
	,	"main x = f x"
		-- ��������� ����������
	,	"main x z = f x y"
		-- ����������� �������
		-- BROKEN �� ������ ���� typedef local
	,	"main x = { o a b = g a a b\no x x }"
		-- ���������� fqn-������� ����������
	,	"main g = f g"
		-- ���������� fqn-������� ����������� ���������
		-- BROKEN �� ������ ���� typedef local
	,	"main x = { g z = z z\ng y y }"
		-- ���������� fqn-������� ��������� ����������
	,	"main x z = { y = b z\nf x y a }"
		-- ����������� ������
	,	"main x = \"aaa\""
			-- ���������� fqn-������� ����������� 
	,	"main x = { g z a = z a x\ng y y }"
		-- ��������� ��������� c ����������
	,	"main a b = { c i = g i b\nf (c a (g a)) }"
 
	,	"main a b = { c i = g i b\nd i = g i i\nf (c a (d a)) }"
		-- ��������� ����������
	,	"main x = { y = x x\ng y y }"
		-- & ����� ����������� �� ������� (������������� ����� ���������� C++)
		-- ������� ��� �������� ��������� ������� �����������
		-- f x y a -> f(x, y, hn::bind(impl, &main_impl::a)) 
	,	"main x z = { a = b z\ny z = g x z\nf x y a }"
		-- BROKEN & ����� ����������� �� ����������� ������� 
	,	"main l = { f x = g 1 x\nmap f l }" 		
	
	]
	
defaultEnv = Env 1 $ M.fromList $ map (\(a, b) -> (a, simpleParse2 b)) [
		("head",  "(List 1) -> 1" )
	,	("plus1", "Int -> Int" )
	]
	
convertExpr (Constant (ConstInt i)) = CNum 123
convertExpr (Atom a) = CVal a
convertExpr (Application a b) = 
	
testCheck3 = mapM (print . check0 . convertExpr) [
		Constant (ConstInt 123),
		Atom "a"
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
	test1
	testCheck3
--	test2
	getLine
	return ()