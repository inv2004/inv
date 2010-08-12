module MilnerTools where
import qualified Data.Map as M
import qualified Data.Set as S
import SPL.Top
import Utils
import SPL.Visualise
import Test.HUnit
import Debug.Trace
import HN.Intermediate
import CPP.TypeProducer
import SPL.Types


instantiateLibrary m = M.map (\x -> TLib x) m

freshAtoms :: [String] -> Int -> (Int, [(String, T)])

freshAtoms [] counter = (counter, [])
freshAtoms a counter = (counter + length a, zipWith (\a i -> (a, tv i)) a [counter..])

substituteType :: [Substitution] -> T -> T
substituteType [] b = b
substituteType a b = result where -- trace ("substituteType:" ++ show a ++ " ===> " ++ show result) result where
	result = substituteSingle (composeSubstitutions a) b

substituteSingle a b = substituteTypeVars  b a


symTrace m t = trace (m ++ " = " ++ show ( M.difference t SPL.Top.get_types)) t

substitute :: [Substitution] -> M.Map String T -> M.Map String T
substitute [] b = b
substitute a b = xtrace "substitute.result: " $ M.map (substituteType a) b

unify :: T -> T -> [Substitution]
unify a b = xtrace ("unify-trace: " ++ makeType a ++ " ~ " ++ makeType b) c where
	c = xunify a b
	xunify (TT (a:at @ (_:_))) (TT (b:bt @ (_:_))) = [xunify a b `xcompose` unify (TT at) (TT bt)]

 	xunify (TT [a]) b = xunify a b
 	xunify a (TT [b]) = xunify a b

	xunify (TD a a1) (TD b b1) | a == b = [composeSubstitutions $ concat $ zipWith xunify a1 b1]
	xunify (T a) (T b) | a == b = []
	xunify (TU a) (TU b) | a == b = []
	xunify (TU a) (TV b) | a == b = []

	xunify (TU a) b = [M.singleton a b]
	xunify b (TU a) = [M.singleton a b]
	xunify (TV a) b = xunify (TU a) b
	xunify b (TV a) = xunify (TU a) b
	xunify a b = error $ "cannot unify: " ++ show a ++ " ~ " ++ show b

envPolyVars e = M.fold f S.empty e where
	f el acc = S.union acc $ typePolyVars el

mapTypeTU f t = subst t where
	subst t = case t of
		TU a -> f (TU a)
		TT a -> TT $ map subst a
  		TD a b -> TD a (map subst b)
		_ -> t


closure env t = TLib tt where
	tpv = typePolyVars t
	epv = xtrace "closure.epv" $ envPolyVars env
	varsToSubst = xtrace "closure.varsToSubst" $ tpv `subtractSet` epv
	tt = mapTypeTU mapper t
	mapper (TU a) = if S.member a varsToSubst then TU a else TV a

replace k v m = M.insert k v m

lookupAndInstantiate :: String -> M.Map String T -> Int -> (Int, T)
lookupAndInstantiate name table counter = let t = uncondLookup name table in case t of
	TLib x -> instantiatedType x counter
	_ -> (counter, t)

tv x = TU $ "t" ++ show x

constantType x = case x of
	ConstInt _ -> T "num"
	ConstString _ -> T "string"

lookupAtom name visibleAtoms freshVar = case M.lookup name visibleAtoms of
	Nothing -> error "foo" -- $ (freshVar + 1, tv freshVar)
	Just t -> error "lookupAtom" -- instantiatedType freshVar t

xcompose :: [Substitution] -> [Substitution] -> Substitution
xcompose a b = composeSubstitutions (a ++ b)

xcompose2 :: Substitution -> Substitution -> Substitution
xcompose2 a b | M.null a = b
xcompose2 a b | M.null b = a

xcompose2 a b = xtrace ("MilnerTools.xcompose2: " ++ show a ++ " # " ++ show b) $ M.fold xcompose2 (M.union a b') $ M.intersectionWith (\a b -> composeSubstitutions $ unify a b) a b' where
	b' = M.map (\x -> substituteTypeVars x a) b

composeSubstitutions a = xtrace ("composeSubstitutions: " ++ show a ++ " ====> " ++ show b) b where
	b = foldr xcompose2 M.empty a

instantiatedTypeTest t e = TestLabel "instantiatedTypeTest" $ TestCase $ assertEqual "" e  $ makeType $ snd $ instantiatedType (libType t) 10

instantiatedTypeTests = [
		instantiatedTypeTest "print" "?t10 -> IO void"
	,	instantiatedTypeTest "bind" "IO ?t10 -> (?t10 -> IO ?t11) -> IO ?t11"
	]

libType name = uncondLookup name SPL.Top.get_types

instantiatedType :: T -> Int -> (Int, T)
instantiatedType t counter = (nextCounter, substituteTypeVars t substitutions) where
	foo = zip (S.toList $ typePolyVars t) [counter..]
   	nextCounter = counter + (length $ S.toList $ typePolyVars t)
	substitutions = M.fromList $ map (\(x,y) -> (x, tv y)) foo

substituteTypeVars t substitutions = subst t where
	subst t = case t of
		TU a -> (case M.lookup a substitutions of
			Nothing -> TU a
			Just b -> b)
		TT a -> TT $ map subst a
  		TD a b -> TD a (map subst b)
		_ -> t

type Substitution = M.Map String T
