    /**
     * Opens the specified web page in the user's default browser
     * Code for this method taken from http://www.centerkey.com/java/browser/
     * @param url A web address (URL) of a web page (ex: "http://www.google.com/")
     */
    private static void openURL(String url) {
        String osName = System.getProperty("os.name");
        try {
            if (osName.startsWith("Mac OS")) {
                Class.forName("com.apple.eio.FileManager").getDeclaredMethod("openURL",
                        new Class[]{String.class}).invoke(null, new Object[]{url});
                
            } else if (osName.startsWith("Windows")) {
                Runtime.getRuntime().exec("rundll32 url.dll,FileProtocolHandler " + url);
                
            } else {
                // assume Unix or Linux
                String[] browsers = {"google-chrome", "firefox", "opera", "epiphany",
                    "konqueror", "conkeror", "midori", "kazehakase", "mozilla"};
                String browser = null;
                for (String b : browsers) {
                    if (browser == null && Runtime.getRuntime().exec(new String[]{"which", b}).getInputStream().read() != -1) {
                        Runtime.getRuntime().exec(new String[]{browser = b, url});
                    }
                }
                
                if (browser == null) {
                    logger.warning(Txt.get("App.webBrowserNotFound"));
                }
            }
            
        } catch (Exception e) {
            logger.warning(Txt.get("App.openUrlError", e.toString()));
        }
    }
//Works from groovy console also
