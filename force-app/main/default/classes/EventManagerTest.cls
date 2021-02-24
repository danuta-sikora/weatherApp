@isTest
public class EventManagerTest {

    @isTest static void relatedAccountsByEventDate(){
        Account acc = new Account ();
        acc.Name= 'test1';
        List<Event> events = new List<Event>();
        Event event = new Event();
        event.StartDateTime = Date.today();
        event.WhatId = acc.Id;
        Event event2 = new Event();
        event2.StartDateTime = Date.today()+1;
        events.add(event);
        events.add(event2);
        
        List<Id> accountsId = EventManager.getRelatedAccountsByEventDate(events, Date.today());
        System.assertEquals(1, accountsId.size());
    }
}