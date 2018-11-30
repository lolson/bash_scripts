$countdown = 10;
while($countdown !=0) {
    print "countdown...\n";
    sleep 1;    # wait one sec
    --$countdown;
} 
print "BOOM!\n";
