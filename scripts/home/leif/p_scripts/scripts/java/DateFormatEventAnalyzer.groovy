//    String someDate = "2013-280-08:44:14";
String someDate = "2013-280-15:12:10 UTC";
java.text.DateFormat origFormat = new java.text.SimpleDateFormat("yyyy-ddd-hh:mm:ss z");
Date date = origFormat.parse(someDate);

java.text.DateFormat targetFormat = new java.text.SimpleDateFormat("yyyy-MM-dd hh:mm:ss z");
String fDate = targetFormat.format(date);
println(fDate);
