#include "DataStoreImpl.h"
#include <SQLiteCpp/SQLiteCpp.h>

#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <cstdlib>
#include <vector>
#include <set>

#define DEBUG_SQL 0


    namespace DataStoreImpl {

    bool operator<(const WordStruct& left, const WordStruct& right)
    {
        return left.order < right.order;
    }

        int findWords(std::string dbFullPath, std::set<WordStruct> &words, std::string termSrc, std::string after000, int limit)
        {
            SQLite::Database db(dbFullPath);  // SQLITE_OPEN_READONLY
#if DEBUG_SQL
            std::cout << "SQLite database file '" << db.getFilename().c_str() << "' opened successfully\n";
#endif
            std::string term = "%"+ termSrc +"%";
            SQLite::Statement   query(db, "select word from wordz where word like ? and word > ?  order by word limit ?");
#if DEBUG_SQL
            std::cout << "SQLite statement '" << query.getQuery().c_str() << "' compiled (" << query.getColumnCount () << " columns in the result)\n";
#endif
            query.bind(1, term);
            query.bind(2, after000);
            query.bind(3, limit);
            
            int i=0;
            while (query.executeStep())
            {
                std::string value2  = query.getColumn(0);
                WordStruct w;
                w.order = i ++;
                w.value = value2;
                words.insert(words.end(), w);
            }
            
            return (int)words.size();
        }
        
    }
