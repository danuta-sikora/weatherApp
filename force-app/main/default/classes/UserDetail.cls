public class UserDetail {

public static String getUserEmailById(Id userId){
    User userByID = [SELECT Id, Email FROM User WHERE id=:userId];
    return userByID.Email;
}
}