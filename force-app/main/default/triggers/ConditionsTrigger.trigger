trigger ConditionsTrigger on Account (after update) {
List <Event> eventsWithAcc = [SELECT Id,subject,What.Type,whatId FROM Event
    WHERE What.Type IN ('Account') AND Subject='Meeting' AND (StartDateTime = TODAY OR StartDateTime = TOMORROW)];
    Date todayDate = Date.TODAY();
    Date tomorrowDate = Date.TODAY()+1;
    Id salesRepId;
    String salesRepEmail;
    
    List<Id> accountsIdTodayEvents = EventManager.getRelatedAccountsByEventDate (eventsWithAcc, todayDate);
    List<Id> accountsIdTomorrowEvents = EventManager.getRelatedAccountsByEventDate (eventsWithAcc, tomorrowDate);
   
    List<Account> accountsDetailsWithTodayEvents = [SELECT Id, SalesRepId__c, CurrentWeatherDescription__c, CurrentWeatherTemp__c, ForecastWeatherDescription__c,ForecastWeatherTemp__c FROM Account WHERE Id IN :accountsIdTodayEvents];
    List<Account> accountsDetailsWithTomorrowEvents = [SELECT Id, SalesRepId__c, CurrentWeatherDescription__c, CurrentWeatherTemp__c, ForecastWeatherDescription__c,ForecastWeatherTemp__c FROM Account WHERE Id IN :accountsIdTomorrowEvents];

    List<User> salesRepList = [SELECT Id, Email, UserRole.Name FROM User WHERE UserRole.Name='Sales Representative'];

    for (Account a : accountsDetailsWithTodayEvents){
        if((a.CurrentWeatherDescription__c.contains('thunderstorm') || a.CurrentWeatherDescription__c.contains('heavy')) || (a.CurrentWeatherTemp__c > 30 || a.CurrentWeatherTemp__c <-10)){
            salesRepId = a.SalesRepId__c;
            salesRepEmail = UserDetail.getUserEmailById(salesRepId, salesRepList);
            if(!salesRepEmail.equals(' ')){
            EmailManager.sendMail (salesRepEmail, 'Weather warning', 'Please be careful with your today meeting with client: ' +a.Name + 'Bad weather conditions may occurs');
            }
        }
    }
    
    for(Account c : accountsDetailsWithTomorrowEvents){
        if((c.ForecastWeatherDescription__c.contains('thunderstorm') || c.ForecastWeatherDescription__c.contains('heavy')) || (c.ForecastWeatherTemp__c >30 || c.ForecastWeatherTemp__c <-10)){
            salesRepId = c.SalesRepId__c;
          salesRepEmail = UserDetail.getUserEmailById(salesRepId, salesRepList);
          if(!salesRepEmail.equals(' ')){
            EmailManager.sendMail (salesRepEmail, 'Weather warning', 'Please be careful with your tomorrow meeting with client: ' +c.Name + 'Bad weather conditions may occurs');
          }
        }
    }
}