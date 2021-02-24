@isTest
public class UserDetailTest {

    @isTest public static void getUserEmailById(){
        User user = new User ();
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr = [SELECT Id, TimeZoneSidKey, LocaleSidKey,LanguageLocaleKey,EmailEncodingKey FROM User LIMIT 1];
      	user.LastName='Smith';
        user.Email = 'smith@gmail.com';
        user.Alias = 'smt';
        user.TimeZoneSidKey = usr.TimeZoneSidKey;
        user.LocaleSidKey = usr.LocaleSidKey;
        user.EmailEncodingKey = usr.EmailEncodingKey;
        user.Username = 'smith76452@gmail.com';
        user.ProfileId = prof.Id;
        user.LanguageLocaleKey = usr.LanguageLocaleKey;
        
        insert user;
        String usrEmail = UserDetail.getUserEmailById(user.Id);
        System.assertEquals('smith@gmail.com', user.Email);
    }
}