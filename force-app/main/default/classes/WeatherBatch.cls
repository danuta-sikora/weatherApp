public class WeatherBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    String falseValue='false';
private final String query = 'SELECT Id, BillingCity, WeatherCity__c, CurrentWeatherDescription__c, CurrentWeatherTemp__c, CurrentWeatherIcon__c, ForecastWeatherDescription__c, ForecastWeatherTemp__c, ForecastWeatherIcon__c FROM Account WHERE BillingCity != null AND isUpdatedToday__c LIKE :falseValue LIMIT 10';

public Database.QueryLocator start(Database.BatchableContext bc){
  
    return Database.getQueryLocator(query);
}

public void execute(Database.BatchableContext bc, List<Account> scope) {
    String location = '';
    String cityName;
    Decimal currentTemp;
    String currentDescription;
    String currentIcon;
    String currentIconUrl;
    Decimal forecastTemp;
    String forecastDescription;
    String forecastIcon;
    String forecastIconUrl;
    String locationToUrl;
    

    Set<String> citiesInSet = new Set<String>();
    List<Account> updatedAcc = new List<Account>();
    
    for (Account acc : scope){
        location = acc.BillingCity;

        if(!citiesInSet.contains(location)){
   
        citiesInSet.add(location);

        if(location.contains(' ')) {
            location = location.replace(' ','%20');
        }

        try {
        HttpRequest request = new HttpRequest();
            Http http = new Http();
            request.setEndpoint('callout:forecast_endpoint/'+location);
            request.setHeader('x-rapidapi-key', '{!$Credential.Password}');
            request.setHeader('x-rapidapi-host', '{!$Credential.UserName}');
            request.setMethod('GET');
            HttpResponse response = http.send(request);

JSONParser parser = JSON.createParser(response.getBody());
JSON2Apex jsonResult = new JSON2Apex (parser);

cityName = jsonResult.city.name;

currentTemp = jsonResult.list_Z.get(2).Main.temp;
currentDescription = jsonResult.list_Z.get(2).Weather.get(0).description;
currentIcon = jsonResult.List_Z.get(2).Weather.get(0).icon;

forecastTemp = jsonResult.list_Z.get(10).Main.temp;
forecastDescription = jsonResult.list_Z.get(10).Weather.get(0).description;
forecastIcon = jsonResult.List_Z.get(10).Weather.get(0).icon;

currentIconUrl = 'http://openweathermap.org/img/wn/' + currentIcon +'@2x.png';
forecastIconUrl = 'http://openweathermap.org/img/wn/' + forecastIcon +'@2x.png';

            acc.WeatherCity__c = cityName;
            acc.CurrentWeatherDescription__c = currentDescription;
            acc.CurrentWeatherTemp__c = currentTemp;
            acc.CurrentWeatherIcon__c = currentIconUrl;
            acc.ForecastWeatherDescription__c = forecastDescription;
            acc.ForecastWeatherTemp__c = forecastTemp;
            acc.ForecastWeatherIcon__c = forecastIconUrl;
            //should we change isUpdatedToday__C value to 'true' here?
            // acc.isUpdatedToday__C = 'true';
            }catch (Exception e){
                    System.debug(''+e);
            }
                 
    } else {

    for(Account upd: updatedAcc){
        if(acc.BillingCity == upd.BillingCity){
            acc.WeatherCity__c = upd.WeatherCity__c;
            acc.CurrentWeatherDescription__c = upd.CurrentWeatherDescription__c;
            acc.CurrentWeatherTemp__c = upd.CurrentWeatherTemp__c;
            acc.CurrentWeatherIcon__c = upd.CurrentWeatherIcon__c;
            acc.ForecastWeatherDescription__c = upd.ForecastWeatherDescription__c;
            acc.ForecastWeatherTemp__c = upd.ForecastWeatherTemp__c;
            acc.ForecastWeatherIcon__c = upd.ForecastWeatherIcon__c;
            // acc.isUpdatedToday__C = upd.isUpdatedToday__C;
        }
    }
}
updatedAcc.add(acc);
}

update updatedAcc;
}
    
public void finish (Database.BatchableContext bc){
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

}