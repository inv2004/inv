#include <hn/lib.hpp>

struct hnMain_impl
{
	template <typename t1, typename t2, typename t5>
	struct flip_impl
	{
		boost::function<boost::function<t5 (t1)> (t2)> f;

		template <typename t1, typename t2, typename t5>
		t5 flipped(t1 x, t2 y)
		{
			return f(y, x);
		};
	};

	template <typename t1, typename t2, typename t5, typename t6, typename t7, typename t8>
	static boost::function<t8 (t6, t7)> flip(boost::function<boost::function<t5 (t1)> (t2)> f)
	{
		typedef flip_impl<t1, t2, t5> local;
		local impl = { f };
		return hn::bind(impl, &local::flipped);
	};
};

ff::IO<void> hnMain()
{
	typedef hnMain_impl local;
	return ff::print((local::flip(&ff::sum))(3, 2));
};