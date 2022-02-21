CREATE VIEW vyuCMBTNotifyPosting    
AS    
SELECT 
BT.intEntityId, 
BT.intTransactionId, 
BT.strTransactionId 
FROM tblCMCompanyPreferenceOption o    
CROSS APPLY(  
    SELECT intTransactionId, intEntityId, strTransactionId  
    FROM tblCMBankTransfer       
    WHERE ysnPostedInTransit = 1 AND ysnPosted = 0  
    and intBankTransferTypeId in(2,3) 
    AND DATEDIFF( DAY, dbo.fnRemoveTimeOnDate(GETDATE()), dtmInTransit  ) 
    BETWEEN 0 AND ISNULL(intBTPostReminderDays,0)  
) BT