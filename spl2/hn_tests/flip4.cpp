#include <hn/lib.hpp>

struct foo_impl
{
	template <typename t1, typename t2, typename t5>
	struct flip_impl
	{
		boost::function<t5 (t2, t1)> f;

		t5 flipped(t1 x, t2 y)
		{
			return f(y, x);
		};
	};

	template <typename t1, typename t2, typename t5>
	static boost::function<t5 (t1, t2)> flip(boost::function<t5 (t2, t1)> f)
	{
		typedef flip_impl<t1, t2, t5> local;
		local impl = { f };
		return hn::bind(impl, &local::flipped);
	};
	static int flipped(int x)
	{
		return x + 5;
	};
};

int foo()
{
	typedef foo_impl local;
	return local::flipped((local::flip<int, int, int>(&ff::sum))(3, 2));
};