  * Writing maintainable code has been largely an art.
  * There are a few informal works on “code smell” and refactoring.
  * The “high cohesion and low coupling” principle is widely accepted but is again informal.
  * Computers can write “small” or “fast” programs, but not “good” ones.
  * Removal of code duplication can be automated but such a transformation is not enough and can even make code “worse”. In several mainstream languages such as C++ and Java complete removal of duplication bloats the code and thus is not practiced by human developers.
  * The ideal solution is to let programmers enter any code that works and let a compiler transform spaghetti into good high-level design and low-level loops.
  * Such automatic code improvers are known since early days of rewriting GOTOs into structured control statements, but they have been largely unsuccessful.
  * Thus we must limit the scope of our research to get a more practical approximation.
  * We chose to research transformations preserving human-maintainability.
  * Alpha-conversion does not preserve maintainability.
  * Eta-reduction followed by eta expansion is not the identity.
  * We cannot use any identifier when a fresh identifier is needed during a transformation. Identifiers must carry useful information. We can collect this information from code shape and nearby identifiers.
  * We cannot forget human-supplied identifiers during transformations. An identifier can be eliminated from source code, but human-supplied information it carries cannot.
  * We cannot mix boilerplate code (e.g. runtime initialization) with application code.