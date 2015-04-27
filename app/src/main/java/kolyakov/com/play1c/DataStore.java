package kolyakov.com.play1c;


public class DataStore {

    static {
      System.loadLibrary("DataStore");
    }

    private DataStore() {
        throw new UnsupportedOperationException();
    }

    private static native WordItem[] findWordsNative(final String dataFolder, final String term, final String after, int offset, int max) throws Exception;

    public static WordItem[] findWords(final String filePath, final String term, final String after, int offset, int max) throws Exception {
        return findWordsNative(filePath, term, after, offset, max);
    }

}
