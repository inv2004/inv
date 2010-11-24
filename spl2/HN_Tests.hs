
module Main where

-- import Visualise
import Utils
import qualified Data.Map as M

import HN.Parser2
import Test.ParserTest
import HN.TypeParser
import HN.Intermediate
import HN.SplExport

import CPP.CompileTools
import CPP.Intermediate
import CPP.TypeProducer

import SPL.Top
import SPL.Types
import SPL.Check3
import qualified SPL.Top

simpleParse  = head . fromRight . parseProg

testCodeGen = rt compileDefinition

-- test2 = rt getDefinitionFreeVars

rt f = mapM (print . f . simpleParse) testSet

testSet =
	[
		-- ��������, ������ ffi-�������
		"main = incr 2"
		-- ����������� �������, 1 ��������
	,	"main x = incr x"
		-- ��������� ����������
	,	"main x z = sum x z"
		-- ���������� fqn-������� ����������
	,	"main sum = incr sum"
		-- ���������� fqn-������� ����������� ���������
		-- BROKEN �� ������ ���� typedef local
	,	"main x = { elist a b = sum a b\nelist x x }"
		-- ���������� fqn-������� ��������� ����������
	,	"main x z = { head = incr z\nsum x head }"
		-- ����������� ������
	,	"main = \"aaa\""
		-- ��������� ��������� c ����������
	,	"main a b = { c i = sum i b\nincr (sum a (c a)) }"

--	,	"main a b = { c i x = sum b (sum x i)\nd i = sum i i\nincr (c a (d a)) }"
		-- ��������� ����������
	,	"main x = { y = sum x x\nsum y y }"
		-- & ����� ����������� �� ������� (������������� ����� ���������� C++)
		-- ������� ��� �������� ��������� ������� �����������
		-- f x y a -> f(x, y, hn::bind(impl, &main_impl::a))
--	,	"main x z l = { a = incr z\ny z = less (sum x a) z\nfilter y l }"
		-- BROKEN & ����� ����������� �� ����������� �������
	,	"main l = {\n\tf x = less 1 x\n\tfilter f l\n}"

	-- l*((f*(filter f l)) (x*less 1 x))
		-- ���������� fqn-������� �����������
	,	"main x = { head z a = z a x\nhead sum 5 }"
			-- ����������� �������
		-- BROKEN �� ������ ���� typedef local
	,	"main x = { o a b = sum a b\no x x }"
		-- polymorphic function
	,	"main l f = filter f l"
	-- polymorphic function without free variables
	,	"flip f = { flipped x y = f y x\nflipped }"
	,	"map f l = {\n\tg x y = join1 (f x) y\n\tfoldr g elist l }"
		-- parameter name conflicts with inferred type variable name
	,	"main a f = filter f a"
	]
	{-
defaultEnv = Env 1 $ M.fromList $ map (\(a, b) -> (a, simpleParse2 b)) [
		("head",  "(List 1) -> 1" )
	,	("plus1", "Int -> Int" )
	]
-}
testCheck3 = mapM (print . SPL.Top.check0 . convertExpr) [
		Constant (ConstInt 123),
		Atom "a",
		Application (Atom "sum") $ map (Constant . ConstInt) [1, 2],
		Application (Atom "incr") [Atom "x"]
	]

main = do
--	mapM (print . simpleParse2) $ [ "aaa", "aaa bbb", "aaa -> bbb", "(List 1) -> 1", "Int -> Int" ]
--	print defaultEnv
--	mapM_ (print . snd . typeCheck defaultEnv) [
--			Atom "l"
--		,	Atom "head"
--		,	Application (Atom "head") [Atom "l"]
--		]
	runTests

--	testCheck3
	rt convertDef
	rt $ SPL.Top.check0 . convertDef
--	test2
	print $ cppType $ T "num"

	testCodeGen
 	getLine
	return ()
