#ifndef tests_DataStoreImpl_h
#define tests_DataStoreImpl_h

#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstdlib>
#include <vector>
#include <set>




    namespace DataStoreImpl {

    struct WordStruct
    {
        std::string value;
        std::string location;
        int order;
        int count;
    };


        int findWords(std::string dbFullPath, std::set<WordStruct> &words, std::string term000, std::string after000, int limit);

    }
#endif
