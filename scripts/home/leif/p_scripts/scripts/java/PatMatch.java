import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PatMatch {
    public static void main(String[] args) {
        PatMatch p = new PatMatch();
        p.run();
        p.rplc();
    }

    private void run() {
        Pattern pat = Pattern.compile("QSService");
       // Matcher match = pat.matcher("SPADOCServiceSOAPBindingQSService");
        Matcher match = pat.matcher("QSService");
        if(match.matches()) {
            print("yes");
        } else {
            print("no");
        }
    }

    private void rplc() {
        String stubClassName = "SPADOCServiceSOAPBindingQSServiceStub";
        print("Stub class: "+stubClassName);
        String str = stubClassName.replace("Stub", "");
        print("WS Service: "+str);
    }

    public static void print(String s) {
        System.out.println(s);
    }
}
