module Main where

import Data.Map as M
import SPL.Types
import SPL.Compiler
import SPL.Check4
import Test.SPL

base2 = M.fromList $
	("sum",
		(CL (CInFun 2 (InFun "sum" do_sum)) (K [])))
--		(TT [T "num", T "num", T "num"]))
	:("incr", 
		(CL (CInFun 1 (InFun "incr" do_incr)) (K [])))
--		(TT [T "num", T "num"]))
	:[]

do_sum (CNum a:CNum b:[]) e = CL (CVal "sum") (K [CNum a, CNum b])
do_sum o e = error ("do_sum"++show o)

do_incr (CNum a:[]) e = CL (CVal "sum") (K [CNum a, CNum 1])
do_incr o e = error ("do_incr"++show o)

test (str, _, t) =
--	case compile str of
	show $ compile str
--		SPL.Compiler.P c -> "ok"
--			case check c base2 0 of
--				SPL.Check4.P ((CTyped t2 _), b)|t2 == t -> "ok"
--				SPL.Check4.P (a, b) -> ("no: "++show a)
--				SPL.Check4.N i b -> b
--		SPL.Compiler.N i e -> e

res = test (head tests)

main = putStrLn Main.res

