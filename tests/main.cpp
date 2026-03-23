#ifndef ABC_HAS_IMPORT_STD
    #include <iostream>
#else
import std;
#endif

import library_a;

int main() { std::cout << library_a::describe() << "\n"; }
