package kolyakov.com.play1c;

public class WordItem {

    public String   name;
    public int      idObject;
    public String   description;
    public int      count;
    public String   location;

    public WordItem() {
        name = "";
        idObject = 0;
        description = "";
        count = 0;
        location = "";
    }

    public String toString() {   

        return "[" + name+ ", "+ idObject + ", " + description +" count=" + count +  " ]";
     }
}