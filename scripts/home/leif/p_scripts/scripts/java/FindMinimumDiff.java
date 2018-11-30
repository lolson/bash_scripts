public class FindMinimumDiff {

    private void run() {
       print("running");
       int[] a1 = {4,5,6};
       int[] a2 = {1,2,4};
        int diff = a1[0] - a2[0];
        int[] diffArr = {0,0};
        int eaDiff;
        for(int i=0; i<a1.length-1; i++) {
            for(int x=0; x<a2.length-1; x++) {
                eaDiff = a1[i] - a2[x];
                if(eaDiff < diff) {
                    diff = eaDiff;
                    diffArr[0] = i;
                    diffArr[1] = x;
                }
            }
        }
        print(diff+"");
        print(String.valueOf(diffArr[0])+String.valueOf(diffArr[1]));
        print("Pair "+String.valueOf(a1[diffArr[0]])+ " and " +
                String.valueOf(a2[diffArr[1]]));
    }

    public static void main(String[] args) {
        FindMinimumDiff fDiff = new FindMinimumDiff();
        fDiff.run();
    }

    public static void print(String st) {
        System.out.println(st);
    }
}
