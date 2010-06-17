#include "hn/lib.hpp"
#include <windows.h>
namespace ff {

int incr(int i)
{
	return i + 1;
}

int sum(int x, int y)
{
	return x + y;
}

bool less(int x, int y)
{
	return x < y;
}


void printret(const char *msg, int ret)
{
	return;
	char buf[1024];
	FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError(), NULL, buf, 1024, NULL);
	printf("%s: ret=0x%08X; GLE=%s\n", msg, ret, buf);
}


IO<int> readnum = IO<int>(&read<int>);

void  UdpSocket::Send(std::string b)
{
	printret("UdpSocket::Send::send", send(s, b.data(), b.size(), 0));
};

void UdpSocket::Reply(const std::string & b)
{
	sendto(s, b.c_str(), b.size(), 0, (sockaddr*)&lastSender, sizeof(lastSender));
};


void udp_reply_impl(UdpSocket & s, std::string b)
{
	s.Reply(b);
}

UdpSocket::~UdpSocket()
{
}

RaiiSocket::~RaiiSocket()
{
//	closesocket(s);
}

IO<void> udp_reply(UdpSocket & a, std::string b)
{
	return boost::bind(&udp_reply_impl, boost::ref(a), b);
};


void forever_impl(IO<void> x)
{
	for (;;) x.value();
}

UdpSocket udp_listen(int x)
{
	return x;
};


UdpSocket::UdpSocket (int x)
{
	s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	sockaddr_in sa;
	memset((char *) &sa, 0, sizeof(sa));
	sa.sin_port = htons(x);
	sa.sin_family = AF_INET;
 	sa.sin_addr.S_un.S_addr = htonl(INADDR_ANY);
	::bind(s, (const sockaddr*)&sa, sizeof(sa));
}

std::string UdpSocket::Receive()
{
	printthis();
	char buf[2048];
	int sz = sizeof(lastSender);
	memset(&lastSender, sizeof(lastSender), 0);
	lastSender.sin_family = AF_INET;
	int r = recvfrom(s, buf, 1500, 0, (sockaddr*)&lastSender, &sz);
	std::string ret;
	if (r > 0 && r < 1500)
	{
		ret.assign(buf, r);
	}
	else
	{
		printret("recvfrom", r);
	}
	return ret;
}

std::string udp_receive_impl(UdpSocket &s)
{
	return s.Receive();
}

IO<std::string> udp_receive(UdpSocket &s)
{
	return boost::bind(&udp_receive_impl, boost::ref(s));
}

IO<void> forever(IO<void> x)
{
	return boost::bind(&forever_impl, x);
};

RaiiSocket::RaiiSocket()
{
}

struct WinSockInit
{
	WinSockInit()
	{
		WSADATA wsa_data;
		WSAStartup(MAKEWORD(2,2), &wsa_data);
	}
};

WinSockInit init;
};

int main(int, const char*[])
{
	hnMain().value();
	return 0;
}
