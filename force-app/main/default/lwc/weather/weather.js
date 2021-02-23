import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import COUNTRY_FIELD from '@salesforce/schema/Account.BillingCountry';
import POSTAL_CODE_FIELD from '@salesforce/schema/Account.BillingPostalCode'
import STATE_FIELD from '@salesforce/schema/Account.BillingState';
import STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import CURRENT_TEMP_FIELD from '@salesforce/schema/Account.CurrentWeatherTemp__c';
import CURRENT_DESC_FIELD from '@salesforce/schema/Account.CurrentWeatherDescription__c';
import CURRENT_ICON_FIELD from '@salesforce/schema/Account.CurrentWeatherIcon__c';
import FORECAST_TEMP_FIELD from '@salesforce/schema/Account.ForecastWeatherTemp__c';
import FORECAST_DESC_FIELD from '@salesforce/schema/Account.ForecastWeatherDescription__c';
import FORECAST_ICON_FIELD from '@salesforce/schema/Account.ForecastWeatherIcon__c';

const accountFields = [NAME_FIELD, CITY_FIELD, COUNTRY_FIELD, POSTAL_CODE_FIELD, STATE_FIELD, STREET_FIELD, CURRENT_TEMP_FIELD,CURRENT_DESC_FIELD,CURRENT_ICON_FIELD,FORECAST_TEMP_FIELD,FORECAST_DESC_FIELD,FORECAST_ICON_FIELD];
export default class Weather extends LightningElement {

    @api recordId;
    data
    error
    cityName
    currentTemp
    currentIcon
    currentDesc
    forecastTemp
    forecastIcon
    forecastDesc
    name
    
    mapMarkers = [];
    accountObject = ACCOUNT_OBJECT;
    fields = [CURRENT_TEMP_FIELD,CITY_FIELD]
    @wire(getRecord, { recordId: '$recordId', fields: accountFields })
    wiredAccount({data,error}){
        if(data){
            this.data = data;
            this.error = error;
        
            this.name = getFieldValue(data, NAME_FIELD)
            const City = getFieldValue(data, CITY_FIELD)
            this.cityName = City
            const Country = getFieldValue(data, COUNTRY_FIELD);
            const PostalCode = getFieldValue(data, POSTAL_CODE_FIELD);
            const State = getFieldValue(data, STATE_FIELD);
            const Street = getFieldValue(data, STREET_FIELD);
            this.currentTemp = getFieldValue(data,CURRENT_TEMP_FIELD)
            this.currentIcon = getFieldValue(data,CURRENT_ICON_FIELD)
            this.currentDesc = getFieldValue(data,CURRENT_DESC_FIELD)
            this.forecastTemp = getFieldValue(data,FORECAST_TEMP_FIELD)
            this.forecastIcon = getFieldValue(data,FORECAST_ICON_FIELD)
            this.forecastDesc = getFieldValue(data,FORECAST_DESC_FIELD)
           
            this.mapMarkers = [{
                location: { City, Country, PostalCode, State, Street },
                title: this.name,
                description: `<b>Address:</b> ${City}, ${PostalCode}, ${Street}`
              }];
           
        } else if (error){
            this.error = error;
            this.data = undefined;
        }
    }

    get celciusCurrentTemp() {
        if(this.currentTemp){
        return Math.round((this.currentTemp - 273.15)) + ' °C';
        }else{
            return '---'
        }
      }

    get celciusForecastTemp(){
          if(this.forecastTemp){
              return Math.round((this.forecastTemp - 273.15))  + ' °C';
          }else{
            return '---'
        }
      }
      
    get getCurrentDesc(){
        if (this.currentDesc){
            return this.currentDesc;
        } else {
            return '--'
        }
    }
    get getCityName(){
        if (this.cityName){
            return this.cityName;
        } else {
            return '--'
        }
        }
    get getForecastDesc(){
        if (this.forecastDesc){
            return this.forecastDesc;
        } else {
            return '--'
        }
        }
}