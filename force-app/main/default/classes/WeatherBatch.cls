global class WeatherBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

global Database.QueryLocator start(Database.BatchableContext bc){
    String query = 'SELECT Id, BillingCity, WeatherCity__c, CurrentWeatherDescription__c, CurrentWeatherTemp__c, CurrentWeatherIcon__c, ForecastWeatherDescription__c, ForecastWeatherTemp__c, ForecastWeatherIcon__c FROM Account WHERE BillingCity != null';
    return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext bc, List<Account> scope) {
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
            request.setEndpoint('callout:forecast_endpoint'+location);
            request.setHeader('x-rapidapi-key', '{!$Credential.Password}');
            request.setHeader('x-rapidapi-host', '{!$Credential.UserName}');
            request.setMethod('GET');
            HttpResponse response = http.send(request);

Map<String,Object> weatherData = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());

List<Object> dataList = (List<Object>) weatherData.get('list');
Map<String,Object> currentWeatherData = (Map<String,Object>) dataList[2];

Map<String,Object> cities = (Map<String,Object>) weatherData.get('city');
cityName  = (String)cities.get('name');

Map<String,Object> currentMainData = (Map<String,Object>) currentWeatherData.get('main');
currentTemp = (Decimal) currentMainData.get('temp');

List<Object> currentWeath = (List<Object>) currentWeatherData.get('weather');
Map<String,Object> currentDesc = (Map<String,Object>) currentWeath[0];
currentDescription = (String) currentDesc.get('description');
currentIcon = (String) currentDesc.get('icon');

currentIconUrl = 'http://openweathermap.org/img/wn/' + currentIcon +'@2x.png';
Map<String,Object> forecastWeatherData = (Map<String,Object>) dataList[10];
Map<String,Object> forecastMainData = (Map<String,Object>) forecastWeatherData.get('main');
forecastTemp = (Decimal) forecastMainData.get('temp');
List<Object> forecastWeath = (List<Object>) forecastWeatherData.get('weather');
Map<String,Object> forecastDesc = (Map<String,Object>) forecastWeath[0];
forecastDescription = (String) forecastDesc.get('description');
forecastIcon = (String) forecastDesc.get('icon');

forecastIconUrl = 'http://openweathermap.org/img/wn/' + forecastIcon +'@2x.png';

            acc.WeatherCity__c = cityName;
            acc.CurrentWeatherDescription__c = currentDescription;
            acc.CurrentWeatherTemp__c = currentTemp;
            acc.CurrentWeatherIcon__c = currentIconUrl;
            acc.ForecastWeatherDescription__c = forecastDescription;
            acc.ForecastWeatherTemp__c = forecastTemp;
            acc.ForecastWeatherIcon__c = forecastIconUrl;
            
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
            
        }
    }
}
updatedAcc.add(acc);
}

update updatedAcc;
}
    
global void finish (Database.BatchableContext bc){
    
}

}