#include <hn/lib.hpp>

struct hnMain_impl
{
	static int main(int z)
	{
		int a = ff::incr(z);
		int y = a;
		return a;
	};
};

ff::IO<void> hnMain()
{
	typedef hnMain_impl local;
	return ff::print(local::main(2));
};
