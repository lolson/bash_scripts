// Extracts events from google calendar
// import into Google sheets and drive scheduler 
// for GSS Countdown clock
function listEvents(Calendar, sheet, startDate, stopDate) {

  
  var events = Calendar.getEvents(new Date(startDate), new Date(stopDate));
  
  var eventarray = new Array(["event-id", "start-time", "end-time", "event-name", "location"]);
  for (var i = 0; i < events.length; i++)
  {
    var line = new Array();
    line.push(events[i].getDescription());
    
    var startTime = Utilities.formatDate(events[i].getStartTime(), 'GMT',  "yyyy-MM-dd-HH:mm:ss") ;
    line.push(startTime);  
//    line.push(events[i].getStartTime().toISOString());
    var endTime = Utilities.formatDate(events[i].getEndTime(), 'GMT',  "yyyy-MM-dd-HH:mm:ss") ;
    line.push(endTime);  
//    line.push(events[i].getEndTime().toISOString());
    line.push(events[i].getTitle());
    line.push(events[i].getLocation());
    eventarray.push(line);
  }
    
  // set row data
  sheet.getRange(1, 1, eventarray.length, eventarray[0].length).setValues(eventarray);
  
  // resize columns
  for (var i = 1; i <= eventarray[0].length; i++)
  {
    sheet.autoResizeColumn(i);
  }
  
  // set width and wrap on the last column (description)
  var width = 400;
  sheet.setColumnWidth(eventarray[0].length, width);
  sheet.getRange(1, 5, eventarray.length, 1).setWrap(true);

  // freeze row 1 to make it a header
  sheet.setFrozenRows(1);
  
}

function deleteAllSheets(spreadsheet)
{
  var sheets = spreadsheet.getSheets();
  for (var i = 0; i < sheets.length-1; i++)
  {
    spreadsheet.deleteSheet(sheets[i]);
  }
}

function main() {
  
  // Change this parameters
  var Calendar  =  CalendarApp.getCalendarById("e8mc3c9a8rut4dgppibvrormv8@group.calendar.google.com");


  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  
  deleteAllSheets(spreadsheet);
  
  var sheet = spreadsheet.getActiveSheet();
  sheet.clear();
  sheet.setName('schedule');

  var startDate = new Date(new Date().getFullYear(), 0, 1);
  var stopDate = new Date(new Date().getFullYear(), 11, 31);
  listEvents(Calendar, sheet, startDate, stopDate);    
}
