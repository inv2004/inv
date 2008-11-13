module Main where
import Structure
import Parser
import Base
import Compile
import Eval
import Debug.Trace as D

run s =
	case parse s of
		Just (i,v)|i == length s -> Just (eval (Compile.make v) base)
		Just (i,v)|i < length s -> error "2"
		Nothing -> error "3"

{- test -}
data Test = Test [Char] [Char]
call_test (Test req res) =
	case run req of
		Just r|(show r) == res -> (True, pref ++ "ok: " ++ req)
		Just r -> (False, pref ++ "ERROR: " ++ req ++ "\n"
								++ tab ++ "result: " ++ show r ++ "\n"
								++ tab ++ "  wait: " ++ res ++ "\n"
								++ tab ++ " parse: " ++ (case parse req of Just a -> show a; o -> show o))
		Nothing -> (False, pref ++ "ERROR: Cannot_parse")
	where
		tab = "    "
		pref = "test_"
{- end test -}

tests = [
	Test "1" "Enum 1"
	,Test "t" "Ebool True"
	,Test "f" "Ebool False"
	,Test "sum" "Elambda N (Erun \"sum\" 2 Fun) [] []"
	,Test ".sum" "Elambda N (Efun False (Erun \"sum\" 2 Fun) [] []) [] []"
	,Test ".sum 1" "Elambda N (Efun False (Erun \"sum\" 2 Fun) [Enum 1] []) [] []"
	,Test ".sum 1 2" "Enum 3"
	,Test ".list 1 2 3 4 5" "El [Enum 1,Enum 2,Enum 3,Enum 4,Enum 5]"
	,Test ".list" "El []"
	,Test ".sum 1 .sum 2 .sum 3 4" "Enum 10"
	,Test ",sum 1" "Elambda N (En \"sum\") [Enum 1] []"
	,Test "(,sum 1)" "Elambda N (En \"sum\") [Enum 1] []"
	,Test "map" "Elambda N (Erun \"map\" 2 Fun) [] []"
	,Test ".map (,sum 1).list 1 2 3 4 5" "El [Enum 2,Enum 3,Enum 4,Enum 5,Enum 6]"
	,Test ".(.sum 2) 3" "Enum 5"
	,Test ".(sum) 2 3" "Enum 5"
	,Test ".(~sum 2.sum 1) 3" "Enum 6"
	,Test ".map (~sum 1.sum 1).list 1 2 3 4 5" "El [Enum 3,Enum 4,Enum 5,Enum 6,Enum 7]"
	,Test ".map (,sum 10).list 1 2 3 4 5" "El [Enum 11,Enum 12,Enum 13,Enum 14,Enum 15]"
	,Test ".count 3 .list 10" "El [El [Enum 10],El [Enum 10],El [Enum 10]]"
	,Test ".map (.dot 4).count 3 (~sum 2)" "El [Enum 6,Enum 6,Enum 6]"
	,Test ".if (,eq 3) (,sum 10) (,sum -3) 3" "Enum 13"
	,Test ".if (,eq 3) (,sum 10) (,sum -3) 4" "Enum 1"
	,Test ".(,if (,eq 3) (,sum 10) ,if (,eq 4) (,sum 11) (,sum -4)) 3" "Enum 13"
	,Test ".if (,eq 3) (,sum 10) (,if (,eq 4) (,sum 11) (,sum -4)) 4" "Enum 15"
	,Test ".fst 3 4" "Enum 3"
	,Test ".if (,eq 3) (,fst 10) (,fst 0) 3" "Enum 10"
	,Test ".(~sum _) 2" "Enum 4"
	,Test ".(,sum _) 2" "Enum 4"
	,Test ".(~sum (.sum 1 4)) 3" "Enum 8"
	,Test ".(^if (,eq 0) (,fst 1) ,if (,eq 1) (,fst 1) (~sum (._f.sum -2 _) ._f.sum -1)) 10" "Enum 89"
	,Test ".find (~not.less 3) .list 5 4 3 2 1" "El [Enum 3,Enum 2,Enum 1]"
	,Test ".sum a.incr 2 |a:4 |incr:,sum 1" "Enum 7"
	,Test ".(~sum 2.sum h |h:_) 3" "Enum 8"
	,Test ".(^if (~eq 0.length) (,fst.list) (,fst.join (._f.find (~not.less hd) tl).join (.list hd)._f.find (~less hd) tl |hd:.head _ |tl:.tail _)) .list 1 2 5 3 2" "El [Enum 1,Enum 2,Enum 2,Enum 3,Enum 5]"
	]

{-
-}

main =
	putStr (tests_output ++ "\n" ++ (if tests_sum > 0 then "Failed: " ++ (show tests_sum) else "all passed") ++ "\n")
	where
		tests_sum = foldr1 (\a b -> a + b) (Prelude.map (\(a,_) -> case a of False -> 1; _ -> 0) tests_res)
		tests_output = foldr1 (\a b -> a ++ b)(Prelude.map ((++"\n").snd) tests_res)
		tests_res = Prelude.map call_test tests

-- comments
f1 = not
f2 a b = (>) a b
f3 = (+)

fun1 x = f1 (f2 15 (f3 10 x))
u fa fb z = fa (fb z)
fun2 = (u f1 (u (f2 15) (f3 10)))
fun3 = (u f1 (u (f2 15) (f3 10)))

{-
fun x = (f1 p1a p1b... (f2 p2a... (f3 p3a... (fn pna... x))))
(.) (f1 p1a p1b...) ((.) (f2 p2a...) (fn pna...))
flip : (a -> b) -> (c -> a) -> c -> b
-}
-- ",incr 7"
--str = ",[incr] 7"
--	",[,incr,incr _] 7"
--	",map incr ,list 1 2 3 4 5"
--str = ",map [,incr _] ,list 1 2 3 4 5"
--str = ",[incr] 7"

{-
mk:{,/{+x}'(x,a;(a:(#x)+x),x)}

,join x a ,join x,a:sum x,length x

foldr join ,map reverse ,list [,join x a] ,join (,sum [,length x] x) x

-}

-- Efun f1 [(Efun f2 [p])]
-- s = parse str


