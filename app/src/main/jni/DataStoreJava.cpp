#include "DataStoreImpl.h"
#include <jni.h>
#include <android/log.h>
#include<string>
#include<vector>

#define LOG_TAG "native_log"
#define LOGD(x...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG,x)

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _JNI_POSREC {
    jclass cls;
    jmethodID ctorID;
    //---data fields--->
    jfieldID nameID;
    jfieldID idID;
    jfieldID descriptionID;
    jfieldID countID;
    jfieldID locationID;
} JNI_POSREC;


JNI_POSREC * LoadJniPosRec(JNIEnv * env) {

    JNI_POSREC * jniPosRec = new JNI_POSREC;

    jniPosRec->cls = env->FindClass("kolyakov/com/play1c/WordItem");

    if (jniPosRec->cls != NULL) {
        LOGD("created class WordItem");
    }

    jniPosRec->ctorID = env->GetMethodID(jniPosRec->cls, "<init>", "()V");
    if (jniPosRec->ctorID != NULL){
        LOGD("WordItem - found ctorID");
    }

    jniPosRec->nameID = env->GetFieldID(jniPosRec->cls, "name", "Ljava/lang/String;");
    jniPosRec->idID = env->GetFieldID(jniPosRec->cls, "idObject", "I");
    jniPosRec->descriptionID = env->GetFieldID(jniPosRec->cls, "description", "Ljava/lang/String;");
    jniPosRec->locationID = env->GetFieldID(jniPosRec->cls, "location", "Ljava/lang/String;");
    jniPosRec->countID = env->GetFieldID(jniPosRec->cls, "count", "I");

    return jniPosRec;
}

JNIEXPORT jobjectArray JNICALL Java_kolyakov_com_play1c_DataStore_findWordsNative
  (JNIEnv *env, jclass, jstring jDataFolder, jstring jTerm, jstring jAfter, jint jOffset, jint jMax)
{
    try
    {
        JNI_POSREC * jniPosRec = LoadJniPosRec(env);

        const char *constDataFolder = env->GetStringUTFChars(jDataFolder, 0);
        std::string dataFolder(constDataFolder);
        LOGD("\nconstDataFolder '%s'", constDataFolder);
        env->ReleaseStringUTFChars(jDataFolder, constDataFolder);

        const char *constTerm = env->GetStringUTFChars(jTerm, 0);
        std::string term(constTerm);
        LOGD("\n\nconstTerm '%s'", constTerm);
        env->ReleaseStringUTFChars(jTerm, constTerm);

        const char *constAfter = env->GetStringUTFChars(jAfter, 0);
        std::string after(constAfter);
        LOGD("\n\nconstconstAfter '%s'", constAfter);
        env->ReleaseStringUTFChars(jAfter, constAfter);

        std::set<DataStoreImpl::WordStruct> words;
        int count = DataStoreImpl::findWords(dataFolder, words, term, after, (int)jMax);

        int max = words.size();

        std::set<DataStoreImpl::WordStruct>::iterator it;
        LOGD("\ncount= %d", max);

        jobjectArray jPosRecArray = env->NewObjectArray(max, jniPosRec->cls, NULL);

        int i=0;
        for (it = words.begin(); it != words.end(); ++it)
        {
            DataStoreImpl::WordStruct word = *it;

            jobject jPosRec = env->NewObject(jniPosRec->cls, jniPosRec->ctorID);
            jstring jName = env->NewStringUTF(word.value.c_str());
            env->SetObjectField(jPosRec, jniPosRec->nameID, jName);
            env->DeleteLocalRef(jName);

            jstring jDescr = env->NewStringUTF(word.value.c_str());
            env->SetObjectField(jPosRec, jniPosRec->descriptionID, jDescr);
            env->DeleteLocalRef(jDescr);

            jstring jLoc = env->NewStringUTF(word.location.c_str());
            env->SetObjectField(jPosRec, jniPosRec->locationID, jLoc);
            env->DeleteLocalRef(jLoc);

            env->SetIntField(jPosRec, jniPosRec->idID, (jint)word.order);

            env->SetObjectArrayElement(jPosRecArray, i, jPosRec);
            env->DeleteLocalRef(jPosRec);
            i ++ ;
        }

        return jPosRecArray;
    }
    catch (std::exception& e)
    {
        std::string err(e.what());
        LOGD("======>!!!!!!exception: %s", err.c_str());
        jclass Exception = env->FindClass("java/lang/Exception");
        env->ThrowNew(Exception, err.c_str());
    }
}

}
