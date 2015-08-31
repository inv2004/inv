# Development #

The compiler is in alpha stage, completely unusable (however, quite a few tiny programs including Project Euler solutions are runnable). Check our [Development](Development.md) page for development status. Check [CurrentState](CurrentState.md) to see an example of what already works.

<wiki:gadget border="0" url="http://stefansundin.com/stuff/flattr/google-project-hosting.xml" width="110" height="20" up\_url="http://code.google.com/p/inv/" />

# Our “Elevator Pitch” #
  1. A programmer writes a short typeless program in a modern concise Javascript-like language;
  1. The HNC compiler inlines all control abstractions and polymorphism into the usual non-template spaghetti loops he is supposed to write as a mainstream C++ developer;
  1. The programmer gives this C++ source to his boss and fellows and they don’t suspect that the code was machine-generated.
Getting generated C++ similar to code written by humans is our primary goal.
For a broader perspective on enslaving the world using Haskell, see our [Manifesto](Manifesto.md).

# Integration into C++ codebase #
HNC is designed with incremental re-engineering of legacy C++ projects in mind:
  * Native C++ allocations  – no garbage collection, boxing, tagging or reference counting;
  * Native C++ types, calling conventions and memory model – no marshalling during function calls across the language boundary;
  * A separate HNI language to import C++ functions;
  * C++ preprocessing to inject generated functions in the middle of legacy C++ files;
  * Support for generation of both free functions and methods;
  * But let classes remain declared in C++.

# KLOCs matter #
Contrary to intuition, in 1990s several attempts to replace custom machine code generators with compilation into C caused twofold slowdown instead of expected speedup. While modern implementations such as ATS seem to overcome this limitation, such compilers are far from trivial – they are hundreds of KLOCs in size.

Our approach is different. We don’t help functional programmers by inventing yet another language. We help C++ programmers to improve productivity. We sacrifice features of the input language if they prove difficult to compile. Our goal is not to find a compiler for a language but to find a language given the constraints on compiler size and output code quality. We search for a language that can be compiled into fast idiomatic C++ within 10 KLOC budget by using existing advanced frameworks for compilers.

Our current incomplete prototype shows that a minimalistic statically typed polymorphic higher-order imperative language without recursion and memory safety can be fit within 4 KLOC.

# Theoretical background #

## Motivation and Terminology ##

  * Harsu, 2000. Re-engineering Legacy Software through Language Conversion.
  * Van De Vanter, 2002. The Documentary Structure of Source Code.
  * Bianchi, Caivano, Marengo, 2003. Iterative Reengineering of Legacy Systems.
  * Jones, 1995. Translating C to Ada.

## Design ##

  * Tolmach, Oliva, 1993. From ML to Ada: Strongly Typed Language Interoperability via Source Translation.
  * Walker, Crary, Morrisett, 2000. Typed Memory Management in a Calculus of Capabilities.

# The languages #
The compiler supports two essentially the same languages with different syntaxes: HN language is syntactically similar to Javascript, SPL language is similar to APL.
The languages are the bare minimum needed in an imperative setting. There are only 6 constructs:
  * Uniform function/variable declaration,
  * Scope,
  * Function application,
  * Conditional,
  * While loop,
  * Assignment.
Type declarations are not available in any way: you can only use the types declared in C++ modules in the spirit of Lua, and you cannot annotate your code with explicit types, in the spirit of dynamically typed languages.
We believe that these constructs are already enough to get an advantage of Hindley-Milner polymorphic type inference and higher-order functions and to become a more productive language than C++.
But once we reach our goal of human-maintainable C++, the languages will be extended to form a simple and coherent subset of C++ in the spirit of C. Targets other than C++ will also be supported, in the spirit of haXe.

# Our current plan #

  1. Parse the syntax - Parsec;
  1. Typecheck the code to detect errors - UUAG;
  1. Perform [PartialDefunctionalization](PartialDefunctionalization.md) (inline most high-order functions) – HOOPL;
  1. Perform [PartialMonomorphization](PartialMonomorphization.md) (specialize most polymorphic functions but not polymorphic data)
  1. Typecheck again to infer the C++ types - UUAG.
  1. Perform [ClosureConversion](ClosureConversion.md) (compile residual local functions into C++ classes generated for each scope) - UUAG;
  1. Pretty print C++ code – a pretty printing combinators library or by hand.

See [FoldExample](FoldExample.md) for an illustration that this approach to get human-maintainable generated C++ might work.