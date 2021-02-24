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
        Account ac = new Account(Name='test');
       
        String email = UserDetail.getUserEmailById(user.Id);
        String emptyEmail = UserDetail.getUserEmailById(ac.Id);
        System.assertEquals('smith@gmail.com', email);
        System.assertEquals(' ', emptyEmail);
    }
}