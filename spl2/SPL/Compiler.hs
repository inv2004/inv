module SPL.Compiler (compile, c_of_cp, res) where

import SPL.Types
import SPL.Parser hiding (P (..), res)
import SPL.Code hiding (res)

comp (Sn x i) =
	CPNum x i
comp (Sb x i) =
	CPBool x i
comp (Sstr s i) =
	CPStr s i
comp (Ss s i) =
	CPVal s i
comp (Scall f (SynK a) i) =
	CPL (comp f) (K (map comp a)) i
comp (Scall f (SynS a) i) =
	CPL (comp f) (S a) i
comp (Scall f (SynM a) i) =
	CPL (comp f) R i
comp (Scall f SynL i) =
	CPL (comp f) L i

compile = comp

c_of_cp (CPNum x i) =
	CNum x
c_of_cp (CPBool x i) =
	CBool x
c_of_cp (CPStr s i) =
	CStr s
c_of_cp (CPVal s i) =
	CVal s
c_of_cp (CPL f (K a) i) =
	CL (c_of_cp f) (K (map c_of_cp a))
c_of_cp (CPL f (S a) i) =
	CL (c_of_cp f) (S a)
c_of_cp (CPL f R i) =
	CL (c_of_cp f) R
c_of_cp (CPL f L i) =
	CL (c_of_cp f) L

{-tests = [
	(Sn 2, CNum 2)
	,(Sn 12, CNum 12)
	,(Ss "sum", CVal "sum")
	,(Scall (Ss "sum") (SynK [Ss "one"]), CL (CVal "sum") (K [CVal "one"]))
	,(Scall (Ss "sum") (SynK [Sn 11, Sn 22]), CL (CVal "sum") (K [CNum 11,CNum 22]))
	,(Scall (Ss "sum") (SynK [Sn 11, Scall (Ss "min") (SynK [Sn 22, Sn 33])]), CL (CVal "sum") (K [CNum 11,CL (CVal "min") (K [CNum 22,CNum 33])]))
	,(Scall (Ss "incr") (SynK [Scall (Ss "min") (SynK [Sn 22, Sn 33])]), CL (CVal "incr") (K [CL (CVal "min") (K [CNum 22,CNum 33])]))
	,(Scall (Scall (Ss "sum") (SynK [Sn 1])) (SynS ["a", "b"]), CL (CL (CVal "sum") (K [CNum 1])) (S ["a","b"]))
	,(Scall (Scall (Scall (Scall (Ss "sum") (SynK [Sn 1,Scall (Ss "min") (SynK [Sn 22,Ss "z"])])) (SynS ["a","b"])) (SynK [Scall (Ss "min") (SynK [Ss "z"])])) (SynS ["x","y"]), CL (CL (CL (CL (CVal "sum") (K [CNum 1,CL (CVal "min") (K [CNum 22,CVal "z"])])) (S ["a","b"])) (K [CL (CVal "min") (K [CVal "z"])])) (S ["x","y"]))
	,(Scall (Scall (Scall (Ss "sum") (SynK [Ss "a", Ss "b"])) (SynS ["a", "b"])) (SynK [Sn 12, Sn 22]), CL (CL (CL (CVal "sum") (K [CVal "a",CVal "b"])) (S ["a","b"])) (K [CNum 12,CNum 22]))
	,(Scall ((Scall (Scall (Scall (Ss "if") (SynK [Scall (Ss "less") (SynK [Ss "_",Sn 5]),Scall (Ss "sum") (SynK [Ss "_",Scall (Ss "_r") (SynK [Scall (Ss "sum") (SynK [Ss "_",Sn 1])])]),Ss "_"])) (SynS ["_"]))) (SynM [MarkR])) (SynK [Sn 1]), CNum 1)
--	,((Scall (Scall (Scall (Ss "if") (SynK [Scall (Ss "less") (SynK [Ss "_",Sn 5]),Scall (Ss "sum") (SynK [Ss "_",Scall (Ss "_r") (SynK [Scall (Ss "sum") (SynK [Ss "_",Sn 1])])]),Ss "_"])) (SynS ["_"]))) (SynM [MarkR]), CNum 1)
--	,((Scall (Scall (Scall (Ss "_") (SynK [Scall (Ss "list") (SynK [Sn 1,Sn 2,Sn 3,Sn 4,Sn 5])])) (SynS ["_"])) (SynK [Scall (Scall (Scall (Ss "if") (SynK [Scall (Ss "is_empty") (SynK [Ss "_"]),Ss "list",Scall (Scall (Ss "join") (SynK [Scall (Ss "_r") (SynK [Scall (Ss "filter") (SynK [Scall (Ss "le") (SynK [Ss "h"]),Ss "_"])]),Ss "h",Scall (Ss "join") (SynK [Scall (Ss "list") (SynK [Ss "h"]),Scall (Ss "_r") (SynK [Scall (Ss "filter") (SynK [Scall (Ss "more") (SynK [Ss "h"]),Ss "_"])])])])) (SynS ["h","t"]),Scall (Ss "head") (SynK [Ss "_"]),Scall (Ss "tail") (SynK [Ss "_"])])) (SynS ["_"])) (SynM [MarkR])])))
	]

mk_test (s, e) =
	(case compile s of
		P s2|e == s2 -> "ok - "
		P s2 -> "ce:\n"++"  cur: "++(show s2)++"\n  exp: "++(show e)
		N -> "ce - ") ++ "\n test:" ++ show s
-}
res = "res"


