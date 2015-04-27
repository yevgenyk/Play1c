package kolyakov.com.play1c;

import android.content.Intent;
import android.os.Handler;
import android.text.Html;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.os.Bundle;
import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.TextView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AbsListView;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.List;
import java.util.ArrayList;

public class MainActivity extends Activity implements OnQueryTextListener {
    private SearchView              mSearch;
    private ListView                mList;
    private StableArrayAdapter      mAdapter;
    private String                  mFilePath;
    private String                  mLastBottomMark;

    private final String dbFile = "words.sqlite";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        try {

            File file = new File(getFilesDir() + File.separator + dbFile);

            if (file.exists() == false) {
                FileOutputStream out = this.openFileOutput(dbFile, Context.MODE_PRIVATE);
                InputStream in = getAssets().open(dbFile);
                byte[] buff = new byte[1024];
                int read = 0;
                while ((read = in.read(buff)) > 0) {
                    out.write(buff, 0, read);
                }
                in.close();
                out.close();
            }
            this.mFilePath = file.getAbsolutePath();
        }
        catch (Exception e) {
            //===>some failure locating or copying DB file
        }

        mList = (ListView)findViewById(R.id.listView);
        final StableArrayAdapter adapter = new StableArrayAdapter(this,
                android.R.layout.simple_list_item_1, new ArrayList<WordItem>());
        mList.setAdapter(adapter);
        this.mAdapter = adapter;
        mList.setTextFilterEnabled(true);


        mList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                WordItem w = mAdapter.getItem(position);
            }
        });

        mSearch = (SearchView)findViewById(R.id.searchView);
        mSearch.setIconifiedByDefault(false);
        mSearch.setQueryHint("Search");
        mSearch.setOnQueryTextListener(this);

        mList.setOnScrollListener(new OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
            }
            @Override
            public void onScroll(AbsListView view, int firstVisibleItem,
                                 int visibleItemCount, int totalItemCount) {
                int lastInScreen = firstVisibleItem + visibleItemCount;
                if (lastInScreen >= totalItemCount) {

                    if (totalItemCount <= 0) {
                        return;
                    }

                    final WordItem w = mAdapter.getItem(totalItemCount - 1);
                    final String q = mSearch.getQuery().toString();

                    if (w.name.equalsIgnoreCase(mLastBottomMark)) {
                        return;
                    }
                    mLastBottomMark = w.name;
                    Handler handler=new Handler();
                    handler.postDelayed(new Runnable() {
                        public void run() {
                            loadAndRefresh(q, false, w.name, 10);
                        }}, 10);
                }
            }
        });
    }

    private void loadAndRefresh(String query, boolean clear, String after, int max) {
        if (mFilePath != null) {
            try {
                if (clear) {
                    mAdapter.clear();
                }
                int prevCount = mAdapter.getCount();
                WordItem [] arr = DataStore.findWords(mFilePath, query, after, prevCount, max);
                System.out.print("findWords returned " + arr.length + " items for: " + query);
                mAdapter.addAll(arr);
            }
            catch (Exception e) {
                //===>data exception
            }
        }
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onQueryTextSubmit(String query) {
        return false;
    }

    @Override
    public boolean onQueryTextChange(String newText) {

        mLastBottomMark = null;

        final String newT = newText;
        Handler handler=new Handler();

        handler.postDelayed(new Runnable() {
            public void run() {
                loadAndRefresh(newT, true, "", 25);
            }}, 20);

        return true;
    }

    private class StableArrayAdapter extends ArrayAdapter<WordItem> {

        public StableArrayAdapter(Context context, int textViewResourceId, List<WordItem> objects) {
            super(context, textViewResourceId, objects);
        }
        protected class ViewHolder {
            TextView word;
            TextView order;
            TextView location;
        }
        @Override
        public View getView(int position, View cv, ViewGroup parent) {
            ViewHolder holder = null;
            if (cv == null) {
                LayoutInflater vi = (LayoutInflater)getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                cv = vi.inflate(R.layout.wordtem, null);
                holder = new ViewHolder();
                holder.word = (TextView) cv.findViewById(R.id.name);
                holder.order = (TextView) cv.findViewById(R.id.order);
                holder.location = (TextView)cv.findViewById(R.id.location);
                cv.setTag(holder);
            } else {
                holder = (ViewHolder) cv.getTag();
            }

            WordItem w = this.getItem(position);
            holder.word.setText(Html.fromHtml(w.name));
            holder.order.setText(""+w.idObject);
            holder.location.setText(w.location);
            return cv;
        }
    }

}
