module SPL.Check4 where

import Data.Map as M

import SPL.Types

data P = P (C, M.Map [Char] T, T) | N Int [Char]
	deriving Show

check (CDebug _ c) et sv =
	check c et sv

check c@(CNum _) et _ =
	P (CTyped (T "num") c, M.empty, T "")

check c@(CBool _) et _ =
	P (CTyped (T "boolean") c, M.empty, T "")

check c@(CStr _) et _ =
	P (CTyped (T "string") c, M.empty, T "")

check c@(CVal s) et sv =
	case M.lookup s et of
		Just v -> check v et sv
		Nothing -> N (-1) (s++" not found")

check o et _ =
	error ("check4: "++show o)

check_with_rename o t b =
	check o t 0

