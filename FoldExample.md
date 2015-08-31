# Introduction #

This is a motivating example of getting idiomatic C++ from a concise specification in a “functional” language. We tried several such examples and got some anecdotal evidence that our approach might work.

# Details #

A non-trivial list folding takes 3 logical lines of code in Haskell:
```
foldList l = foldl (\x y -> x * y + c) 4 l where c = 2
```

The logical units are two bindings and one lambda-abstraction.
A puristic C++ solution conforming to the spirit of the C++ standard is in [iter.cpp](http://code.google.com/p/inv/source/browse/trunk/spl2/experiments/iter/iter.cpp). It takes 10 logical LOC. Curly braces, import declarations and empty lines are not counted and `c(_c)` is considered a separate LOC.

The solution can be shortened by using tricks: [iter2.cpp](http://code.google.com/p/inv/source/browse/trunk/spl2/experiments/iter/iter2.cpp) has 8 LOC, iter3.cpp has 7.
An idiomatic standard-conformant solution is listed in iter5.cpp. There are just 6 LOC. Moreover, the code is:

  * Simple,
  * Linear,
  * Straightforward.

Despite the longest line with “for” statement seems to be complicated, it’s a typical pattern that requires less brain power to comprehend than fold and map in functional code. Programmers are taught to recognize and generate such patterns mechanically early in the career.

In the Haskell sample control flow makes dives into the fold and back into the lambda. I call such control flow “non-linear” and believe it complicates comprehension, requiring more effort from a programmer. The connections of `x` and `y` with the return value of the fold and with the elements of the list are also “non-linear”. In the purist C++ code there is an identical connection between `std::accumulate` and its `f` argument and between the two initializers and the class body.

The purist code is not straightforward because `F` is not encapsulated and to refactor this code a programmer must check that `F` not used elsewhere. The idiomatic code, in contrast, can be completely comprehended by looking locally at the body of `foldList`.
The purist code can be shortened to the same 6 LOC as the idiomatic example at the cost of the local anonymous structure trick (see `iter6.cpp`). We consider `struct { … } var = {…}` clause not two LOCs but one.

STL has a reputation of complicating tuning the code for best performance, so in production STL tends to be avoided. Production-quality code is usually neither standard, nor puristic or tricky. But, of course, it still avoids non-portable constructs. Most probably, something along the lines of iter6.h will be used. The OurList class of course will be bigger and the fields will be partially encapsulated, but the general interface of a list will most likely be this (value, next) tuple.
So, now we know what production code might look like. Now we are going to figure out what we need to generate such code. We must take this:
```
foldList l = foldl (\x y -> x * y + c) 4 l where c = 2 
```
and generate this:
```
inline int foldList(OurList<int> *l)
{
	int c = 2;
	int acc = 4;
	while (l != NULL)
	{
		acc = l->value * acc + c;
		l = l->next;
	}
	return acc;
}
```
We will proceed by gradually transforming the source and the destination code so they eventually meet.

In the absence of overloading and other complicated aspects of C++ name resolution, the C++ types are easily inferred by a minor modification of Milner algorithm W, for example. And purely syntactic transformations are trivial to implement. So we can reformulate our goal in a simpler syntax and without types:
```
foldList l = {
	c = 2
	acc = 4
	while (l != NULL)
	{
		acc := l->value * acc + c
		l := l->next
	}
	acc
}
```
Next, it’s trivial to convert, for example, tail l into l->next. So now we can get rid of operators and use only prefix alphanumeric notation for everything.

```
foldList l = {
	c = 2
	acc = 4
	while (neq l null)
	{
		acc := add (mul (head l) acc) c
		l := tail l
	}
	acc
}
```
So far we simplified our goal. Let’s look at our source specification now:

```
foldList l = foldl (\x y -> x * y + c) 4 l where c = 2
```

Let’s convert it from Haskell to the “restricted C++ syntax” we have just invented above. It’s also obvious that lambdas can be merely syntactic sugar – so function declarations such as `foldlist l = {` above are enough and lambdas are redundant:
```
foldList l = {
	c = 2
	f x y = add (mul x y) c
	foldl f 4 l
}
```

Note that this program requires non-trivial work to transform it into C++ as C++ lacks local functions and lexical closures (c variable is captured). For example, we could represent closures in C++ as functors and use namespaces or something to emulate scopes for functions. The HN0 stage is merely a compiler for such programs as this and can already compile foldList into C++ given the HNI declarations for foldl (add and mul are currently primitives as they are compiled into their infix counterparts).

But this translation into functors is obviously far from our production quality ideal, so we now are going to understand how to convert this source code:
```
foldList l = {
	c = 2
	f x y = add (mul x y) c
	foldl f 4 l
}
```
Into this target code:
```
foldList l = {
	c = 2
	acc = 4
	while (not (null l))
	{
		acc := add (mul (head l) acc) c
		l := tail l
	}
	acc
}
```
Once we have solved this problem, the rest of compilation is straightforward as previously we have seen that all simplifications we ;have made can be easily reverted.
Parts of source and target code turn out to coincide, so the problem is reduced further to a transformation of
```
f x y = add (mul x y) c
foldl f 4 l
```
into
```
	acc = 4
	while (not (null l))
	{
		acc := add (mul (head l) acc) c
		l := tail l
	}
	acc
```

Let formal parameters of `foldl` be `a0`, `a1`, `a2`. It can easily be seen that if we substitute `4` for `a1`, `add (mul (head l) acc) c` for `a0 (head a2) acc` and `l` for `a2`, the only work a compiler should do to get our ultimate code is to inline `foldl` and `f` in the following code:
```
foldl a0 a1 a2 = {
	acc = a1
	while (not (null l))
	{
		acc := a0 (head a2) acc
		a2 := tail a2
	}
	acc
}

foldList l = {
	c = 2
	f x y = add (mul x y) c
	foldl f 4 l
}
```

The code we get after the inlining can be trivially transferred into the production-quality C++ example.