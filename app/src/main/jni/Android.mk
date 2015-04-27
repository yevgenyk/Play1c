LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := DataStore

LOCAL_C_INCLUDES := $(LOCAL_PATH)/DataStore/include/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/DataStore/sqlite3/

LOCAL_SRC_FILES := DataStoreJava.cpp ./DataStore/DataStoreImpl.cpp ./DataStore/sqlite3/sqlite3.c ./DataStore/sqlite3-wrapper/Column.cpp ./DataStore/sqlite3-wrapper/Database.cpp ./DataStore/sqlite3-wrapper/Statement.cpp ./DataStore/sqlite3-wrapper/Transaction.cpp

LOCAL_STATIC_LIBRARIES := cpufeatures

LOCAL_LDLIBS := -llog
LOCAL_CFLAGS := -g

include $(BUILD_SHARED_LIBRARY)