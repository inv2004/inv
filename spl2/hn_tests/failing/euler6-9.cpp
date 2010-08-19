#include <hn/lib.hpp>

struct natr_impl
{
	boost::function<int (int)> f;

	template <typename t2>
	int g(int x, t2 total)
	{
		return f(x) + 1;
	};
};

int natr(boost::function<int (int)> f)
{
	typedef natr_impl local;
	local impl = { f };
	return ff::natrec<int>(hn::bind(impl, &local::g), 0, 100);
};
