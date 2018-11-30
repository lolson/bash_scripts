
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class CheckTime {
    public static void main(String[] args) {
//        DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
        DateFormat dateFormat = new SimpleDateFormat("yyyy-DDD-HH:mm:ss.SSS");
        Date date = new Date();
        System.out.println(dateFormat.format(date));
       System.out.println(TimeZone.getDefault().getDisplayName());
        System.out.println(TimeZone.getDefault().getID());
    }
}
