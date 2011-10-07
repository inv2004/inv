module Test.Optimizer.WithParsing (tests, main) where
import Test.HUnit hiding (test)

import HN.Parser2
import HN.Optimizer.WithGraph

realTest inFile = TestCase $ do
	x <- parseAndProcessFile inFile id
	x @=? withGraph id ["print", "sub", "mul", "natrec", "sum", "incr"] x

tests = "WithParsing" ~:  map (\x -> realTest ("hn_tests/" ++ x ++ ".hn"))
	[
-- "locals14"
	 "where2"
 	, "where"
	, "plusX"
	--, "locals2"
	--, "euler6"
	]

main = runTestTT tests
