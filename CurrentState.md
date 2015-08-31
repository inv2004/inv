# HN #

Euler 5 in HN0 (euler5.hn):

```
hnMain = {
	f xx rr = {
		not_divisable x = {
			natfind pred n = {
				ff nn found = _if found found (pred nn)
				natrec ff (eq 0 1) n
			}
			g divisor = _if (eq 0 (mod x (incr divisor))) (eq 0 1) (eq 0 0)
			natfind g 20
		}
		xxx = mul 60 (mul 19 (incr xx))
		_if (eq rr 0) (_if (not_divisable xxx) rr xxx) rr
	}
	print (natrec f 0 1000000)
}
```

The corresponding generated C++ code is in trunk/spl2/hn\_tests/euler5.cpp :

```
#include <hn/lib.hpp>

struct hnMain_impl
{
	struct f_impl
	{
		struct not_divisable_impl
		{
			int x;

			struct natfind_impl
			{
				boost::function<bool (int)> pred;

				bool ff(int nn, bool found)
				{
					return found ? found : pred(nn);
				};
			};

			static bool natfind(boost::function<bool (int)> pred, int n)
			{
				typedef natfind_impl local;
				local impl = { pred };
				return ff::natrec<bool>(hn::bind(impl, &local::ff), 0 == 1, n);
			};
			bool g(int divisor)
			{
				return 0 == x % divisor + 1 ? 0 == 1 : 0 == 0;
			};
		};

		static bool not_divisable(int x)
		{
			typedef not_divisable_impl local;
			local impl = { x };
			return local::natfind(hn::bind(impl, &local::g), 20);
		};
	};

	static int f(int xx, int rr)
	{
		typedef f_impl local;
		int xxx = 60 * 19 * xx + 1;
		return rr == 0 ? local::not_divisable(xxx) ? rr : xxx : rr;
	};
};

ff::IO<void> hnMain()
{
	typedef hnMain_impl local;
	return ff::print(ff::natrec<int>(&local::f, 0, 1000000));
};
```

Note that identifiers are preserved, types are reconstructed (even the explicit template argument for natrec), but the output code is higher-order, polymorphic and obviously written either by a machine or an idiot. The code will improve as our implementation matures.

# SPL #

SPL is a strictly, statically and implicitly typed functional universal language with translator into C++ language. Parser, typechecker, interpreter and rudimentary standard library have been implemented. In the future HN and SPL will share the same backend. Some time ago they shared type checker, but now HN0 uses an attribute-grammar reimplementation of type checker that makes it completely independent of SPL.

Euler 5 in SPL (but using another algorithm than the HN example above):

```
foldr mul 1,map max_power,filter (n*is_prime,bn.int n),range 3 19
is_prime:(n*
	('x*
		if (bn.lt x,bn.div n,bn.int 2) {
			if (bn.eq bn.zero,bn.mod n x) {
				0b
			}#_f,bn.incr x
		}#1b
	),bn.int 2
)
max_power:('s*n*
	if (less ss 20) {
		_f ss n
	}{
		s
	}
	ss:mul s n
)/1
range:(f*t*
  range f,incr t
  range:('i*l*
    if (less i l) {
      join1 i,_f incr/i l
    }#elist
  )
)
```