public class SolvePi {
private static long num_rects=200000;
public static void main(String[] args ){
    int i;
    double mid, height, width, sum = 0.0;
    double area;
    width = 1.0 /(double)num_rects;
    for(i=0; i<num_rects; i++) {
        mid=(i+0.5) * width;
        height = 4.0 / (1.0 + mid*mid);
        sum += height;
    }
    area = width * sum;
    System.out.printf("Coputed pi = %f\n",area);
}
}
