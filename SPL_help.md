
```
help
  interactive commands
    \ - interpretator internal commands
     h - help
     e - examples
     t exp - type
     q - quit
  apply
    f p - apply p to f
    f,expr - f (expr)
    a1*a2*...expr - define function with aX parameters
    expr*a1:v1*a2:v2... - (a1*a2*...expr) v1 v2 ...
    a1*a2*expr*a3:v3*a4:v4 - both ^ and ^^
  lazy/rec
    f#expr - f {expr}
    {expr} - lazy, eval: {expr} go
    ('..._f p1 p2...) - save current lambda to _f (recursion)
  base functions
    _if _or bind bn concat debug div elist eq filter foldr go head if iff incr join1 length less load map mod mul natrec
 not or out pair print readnum reverse str sub sum tail to to_string voidbind
  structures
    struct.field - field from structure
    struct^field - import struct env
    .field - from top level
  web
    wiki http://code.google.com/p/inv/w/
```