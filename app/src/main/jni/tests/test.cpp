#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstdlib>
#include <vector>
#include <set>

#include <SQLiteCpp/SQLiteCpp.h>

#include "DataStoreImpl.h"

using namespace DataStoreImpl;

#ifdef SQLITECPP_ENABLE_ASSERT_HANDLER
namespace SQLite
{
/// definition of the assertion handler enabled when SQLITECPP_ENABLE_ASSERT_HANDLER is defined in the project (CMakeList.txt)
void assertion_failed(const char* apFile, const long apLine, const char* apFunc, const char* apExpr, const char* apMsg)
{
    // Print a message to the standard error output stream, and abort the program.
    std::cerr << apFile << ":" << apLine << ":" << " error: assertion failed (" << apExpr << ") in " << apFunc << "() with message \"" << apMsg << "\"\n";
    std::abort();
}
}
#endif


int main()
{
    try
    {
        std::string db = "words.sqlite";
        std::string term = "ous";
        
        std::set<WordStruct> words;
        
        words.clear();
        findWords(db, words, term, "", 10000);
        
        std::cout << "=====> Found " << words.size() << " matches for '" << term << "'\n";
        
        //...more tests...
        
    }
    catch (std::exception& e)
    {
        std::cout << "SQLite exception: " << e.what() << std::endl;
        return EXIT_FAILURE; // unexpected error : exit the example program
    }

    return EXIT_SUCCESS;
}
