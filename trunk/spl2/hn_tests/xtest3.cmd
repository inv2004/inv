@call hnc %1.hn > tmp-%1.cpp && call cpp2 tmp-%1.cpp && move tmp-%1.cpp %1.cpp