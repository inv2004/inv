module BaseFunctions where

import Data.Map as M

import Types

data Fun = Fun C T

base = M.fromList $
	("sum", Fun
		(CL (CInFun 2 (InFun "" do_sum)) (K []))
		(TT [T "num", T "num", T "num"]))
	:("incr", Fun
		(CL (CInFun 1 (InFun "" do_incr)) (K []))
		(TT [T "num", T "num"]))
	:("elist", Fun
		(CList [])
		(TD "list" [TU "a"]))
	:("head", Fun
		(CL (CInFun 1 (InFun "" do_head)) (K []))
		(TT [TD "list" [TU "a"], TU "a"]))
	:("join1", Fun
		(CL (CInFun 2 (InFun "" do_joina)) (K []))
		(TT [TU "a", TD "list" [TU "a"], TD "list" [TU "a"]]))
	:("length", Fun
		(CL (CInFun 1 (InFun "" do_length)) (K []))
		(TT [TD "list" [TU "a"], T "num"]))
	:("to_string", Fun
		(CL (CInFun 1 (InFun "" do_to_string)) (K []))
		(TT [TU "a", T "string"]))
	:("pair", Fun
		(CL (CInFun 2 (InFun "" do_pair)) (K []))
		(TT [TU "a", TU "b", TD "pair" [TU "a",TU "b"]]))
	:("debug", Fun
		(CL (CInFun 1 (InFun "" do_debug)) (K []))
		(TT [TU "a", TU "a"]))
	:("go", Fun
		(CNum 0)
		TL)
	:("iff", Fun
		(CL (CInFun 1 (InFun "" do_iff)) (K []))
		(TT [TD "list" [TD "pair" [T "boolean", TT [TL, TU "a"]]], TU "a"]))
	:("iff2", Fun
		(CL (CInFun 1 (InFun "" do_iff2)) (K []))
		(TT [TD "list" [TD "pair" [T "boolean", TT [TL, TU "a"]]], TT [TL, TU "a"]]))
	:[]

put_name n (CL (CInFun i (InFun "" f)) (K [])) = CL (CInFun i (InFun n f)) (K [])
put_name n o = o

get_code n (Fun c _) = put_name n c
get_type (Fun _ t) = t

get_codes = M.mapWithKey get_code base
get_types = M.map get_type base

-- native functions
do_sum (CNum a:CNum b:[]) e = CNum (a+b)
do_sum o e = error ("do_sum"++show o)

do_incr (CNum a:[]) e = CL (CVal "sum") (K [CNum a, CNum 1])
do_incr o e = error ("do_incr"++show o)

do_joina (a:CList b:[]) e = CList (a:b)
do_joina o e = error $ show o

do_head (CList a:[]) e = head a

do_length (CList l:[]) e = CNum (length l)

do_debug (a:[]) e = a

do_to_string (a:[]) e = CStr (show a)

do_pair (a:b:[]) e = CPair (a:b:[])

do_iff (CList []:[]) e = CNum 0
do_iff (CList ((CPair (CBool i:exp:[])):is):[]) e| i = CL exp (K [CVal "go"])
do_iff (CList (CBool i:is):[]) e = do_iff (CList is:[]) e

do_iff2 (CList []:[]) e = CNum 0
do_iff2 (CList ((CPair (CBool i:exp:[])):is):[]) e| i = exp
do_iff2 (CList (CBool i:is):[]) e = do_iff (CList is:[]) e


