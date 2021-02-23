public class EventManager {

public static List<Id> getRelatedAccountsByEventDate (List <Event> events, Date eventDate){
 List<Id> relatedAccountsIdByEventDate = new List<Id> ();
 for (Event ev : events){
     Id accountId = ev.WhatId;
     if(ev.StartDateTime == eventDate){
         relatedAccountsIdByEventDate.add(accountId);
     }
 }
 return relatedAccountsIdByEventDate;
 
}
}