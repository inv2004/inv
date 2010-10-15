{-

���� - ������������ Hoopl ��� ��������� ������������ ������������� ������,
� �� ������ "������������ ����� � Goto", ��� ������� � ������

-}
{-# LANGUAGE GADTs, ScopedTypeVariables, TypeFamilies #-}
module HN.Optimizer.Inliner2 (runB) where

import Compiler.Hoopl
import HN.Optimizer.Intermediate
import HN.Optimizer.Node
import HN.Optimizer.Pass
{-
���������:

����:

foo x = {
	bar x = incr x
	bar x
}

�����:

bar -> 1

����� (��� ����� ������ �����������):

foo x = {
	bar x = incr x
	incr x
}

������ Hoopl - ������� �����, ���������� ����� - ���������� ������� �������� �� �����.

�������� ������������ ������� ��������, ���������� ����� - ���������� �������

��� ������ ����� ����������� ������������� ���� ��� ������. � �����
���� ����� ����������� ����� ����. ������������ ���� ����������
��� ���������: ��� ���� � ����� �����, � ������� ���� ����.

���� ������, ��� ��������� ����� ����� ������ ��� ������������ ������������������� ����������
-}

--data Node0 e x where
--	Node0 :: Label -> [Label] -> Node0 C �

-- ��� ������ �� ������ ��-���� ��� ��������������� �������

type ListFact = WithTopAndBot DefinitionNode

listLattice = addPoints' "ListFact" $ \_ (OldFact _) (NewFact new) -> error "Join" (SomeChange, PElem new)

-- BACKWARD pass

transferBL :: BwdTransfer Node ListFact
transferBL = mkBTransfer bt where
  bt :: Node e x -> Fact x ListFact -> ListFact
  bt (Entry _)  f = f
  bt (Exit dn) _ = PElem dn

-- Rewriting: inline definition - rewrite Exit nodes ("call sites") to
-- remove references to the definition being inlined

rewriteBL :: FuelMonad m => BwdRewrite m Node ListFact
rewriteBL = mkBRewrite cp where
	cp ::  FuelMonad m => Node e x -> Fact x ListFact -> m (Maybe (Graph Node e x))
	cp (Entry _) _ = return Nothing
	cp (Exit xll) f = return $ rewriteExitL xll f

rewriteExitL dn f = fmap (nodeToG . Exit) $ case dn of
	LibNode -> Nothing
	ArgNode -> Nothing
	LetNode l expr -> fmap (LetNode l) $ rewriteExpression expr f

rewriteApplication (Atom a) b f = case lookupFact a f of
	Nothing -> error "rapp.Atom.Nothing"
	Just x -> rewriteAtomApplication x where
		rewriteAtomApplication :: ListFact -> Maybe (Expression Label)
		rewriteAtomApplication x = case x of
			Top -> error "rapp.top"
			Bot -> error "rapp.bot"
			PElem x -> case x of
				LetNode args expr -> rewriteExpression expr $ flip mapUnion f $ mapFromList $ zip args $ map (PElem . LetNode []) b
				_ -> error "rapp.pelem._"


rewriteApplication a b f = case rewriteExpression a f of
	Nothing -> fmap (Application a) $ rewriteArgs b f
	Just _ -> error "rapp.Just"

rewriteArgs [] _ = Nothing
rewriteArgs (a : at) f = case (rewriteArgs at f, rewriteExpression a f) of
	(Nothing , Nothing) -> Nothing
	(Nothing , Just a') -> Just $ a' : at
	(Just at', Nothing) -> Just $ a : at'
	(Just at', Just a') -> Just $ a' : at'

rewriteExpression expr f =  case expr of
	Constant _ -> Nothing
	Atom a -> case lookupFact a f of
		Nothing -> error "rewriteExpression.Nothing"
		Just x -> processAtom x
	Application a b -> rewriteApplication a b f

processAtom :: ListFact -> Maybe (Expression Label)
processAtom x = case x of
 	Top -> Nothing
 	Bot -> error "rewriteExitL.Bot"
 	PElem e -> case e of
		ArgNode -> error "processFact.ArgNode"
		LetNode [] e -> Just e
		LetNode _ _ -> Nothing
		_ -> error "processAtom._"

passBL = BwdPass
	{ bp_lattice = listLattice
	, bp_transfer = transferBL
	, bp_rewrite = rewriteBL
	}

runB
  :: (map (Pointed C C a1) ~ Fact x (Pointed C C DefinitionNode),
      Num a,
      IsMap map) =>
     (Graph Node C x,
         map a,
         t2)
     -> CheckingFuelMonad
          SimpleUniqueMonad
          (Graph Node C x,
           FactBase (Pointed C C DefinitionNode),
           MaybeO C (Pointed C C DefinitionNode))

runB = runPass (analyzeAndRewriteBwd passBL) $ const . mapMap int2list where
	int2list 1 = Bot
	int2list _ = Top



-- Utilities
--
--
nodeToG :: Node e x -> Graph Node e x
nodeToG (Entry el) = mkFirst (Entry el)
nodeToG (Exit xll) = mkLast (Exit xll)


-- TODO ���������� �� ������ ������� � AST
--

{-
foo x = {
	bar x = incr x
	bar x
}

�������� ���� ��������� �������:

�� ���� �������� FactBase ListFact, ���������� � ���������� ������� �������,
� ������� ��� �������, ������� ����� ���������, ������� Bot, � ��� �������,
������� �� ����� ��������� - Top.

�������� ���������� ��� ������ ������� ���������� [...]. ��������������:

Top `join` [...] = Top
Bottom `join` [...] = [...]

	-}
