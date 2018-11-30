public class tryMath {
    public static void main(String[] args){
int totalSaved =1079;
int totalProcessed =4289;
float prc = Math.round( ((float)totalSaved / (float)totalProcessed)*100);
int prc2 = Integer.valueOf(Math.round( ((float)totalSaved / (float)totalProcessed)*100));
//float prc2 = Math.round( (float)(totalSaved / totalProcessed)*100);
//float prc3 = Math.round(( (float)totalSaved / totalProcessed)*100);
        System.out.println("Percent "+prc);
        System.out.println("Ast int "+prc2);
  //      System.out.println("Percent 2"+prc2);
    //    System.out.println("Percent 3"+prc3);
    }
}
