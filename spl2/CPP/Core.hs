module CPP.Core where

import qualified Data.Set as S
import qualified Data.Map as M
import Data.List
import Data.Maybe

import HN.Intermediate

import CPP.Intermediate
import CPP.Visualise
import CPP.TypeProducer
import Utils
import Debug.Trace

import SPL.Types
import qualified Bar as AG

-- inherited attributes for Definition
data DefinitionInherited = DefinitionInherited {
	diLevel           :: Int
,	diSymTab          :: M.Map String CppAtomType
,	diTyped           :: C
,   diInferredType    :: T
}

-- synthesized attributes for Definition
data DefinitionSynthesized = DefinitionSynthesized {
	dsCppDef :: CppDefinition
}


sem_Definition inh self @ (Definition name args val wh)
	= DefinitionSynthesized {
		dsCppDef = AG.cppDefinition_Syn_Definition $ AG.wrap_Definition (AG.sem_Definition self) AG.Inh_Definition {
				AG.level_Inh_Definition = diLevel inh
			, 	AG.typed_Inh_Definition = diTyped inh

			-- � ���������� �++ ��������� � ������� foo ����������� ������� ���������:
			-- local::foo - ���� foo ����������� ������� � bar_impl
			-- impl.foo - ���� foo ���������� � bar_impl ��� (������������� �������, � ����������� � �����)
			-- hn::bind(impl, &local::foo) - ���� foo ������������� ������� � ����������� �������� � ����������
			-- &local::foo - ���� foo ����������� ������� � ����������� �������� � ����������
			-- foo - ���� foo ��������� ���������� ������� ��� �������� �������
			-- hn::foo - ���� foo �������� �������� ����������� ����������
			--
			-- ������� ���� �� �����������:
			-- ��� ������������ ���������� �������� hn::curry1(&local::foo) ��� hn::curry1(impl, &local::foo)
			-- ��� ������������ ��������� ���������� ������ local ��������� ������� parent::parent::foo ��� up.up.foo
			--
			-- ��� ��������� ���� ������ ��������� ������ ���� symTabTranslator, fqn, fqnTransformer
			-- fqnTransformer ����������, ����������� �� ��������� � ������� ��� �������� � ����������
			-- �.�. ���� � ��� �� ���� ������������� ��-�������, � ����������� �� ����, ���������
			-- �� � ������� ������� ��� � ������� ���������
			-- ���������� �� ����������� ���������� ������� ������������ ��������
			-- �� ������ S
			,   AG.symTab_Inh_Definition = diSymTab inh
			,   AG.inferredType_Inh_Definition = diInferredType inh
			}
	}
