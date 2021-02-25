public class UserDetail {

public static String getUserEmailById(Id userId, List<User> salesRepList){
    String userEmail;

    for(User user : salesRepList){
        if (userId == user.Id){
            userEmail = user.Email;
        } else {
            userEmail = ' ';
        }
    }
    return userEmail;

//     List <User> userById = [SELECT Id, Email FROM User WHERE id=:userId];
//     if(userById.size()==1){
//        userEmail = userById.get(0).Email;
//     } else{
//     userEmail = ' ';
//     }
//     return userEmail;
// }
}
}