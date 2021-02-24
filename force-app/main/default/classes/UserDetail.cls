public class UserDetail {

public static String getUserEmailById(Id userId){
    String userEmail;
    List <User> userById = [SELECT Id, Email FROM User WHERE id=:userId];
    if(userById.size()==1){
       userEmail = userById.get(0).Email;
    } else{
    userEmail = ' ';
    }
    return userEmail;
}
}