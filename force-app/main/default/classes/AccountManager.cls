public class AccountManager {

public static List<Account> getAccountsDetails (List<Account> allAccounts, List<Id> accountsId){
    List<Account> accountsDetails = new List<Account> ();
    for(Integer i = 0; i < accountsId.size(); i++){
        Id accountId = accountsId.get(i);
    
           for(Integer j = 0; j < allAccounts.size(); j++){
              Account ac = allAccounts.get(j);
              Id acId = ac.Id;
              if(accountId == acId ){
                accountsDetails.add(ac);
              }
           }   
       }
       return accountsDetails;
}
}