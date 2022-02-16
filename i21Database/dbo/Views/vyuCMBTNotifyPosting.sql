CREATE VIEW vyuCMBTNotifyPosting  
AS  
 SELECT BT.intEntityId, BT.intTransactionId, BT.strTransactionId
FROM tblCMCompanyPreferenceOption o  
CROSS APPLY(
SELECT intTransactionId, intEntityId, strTransactionId  from tblCMBankTransfer     
WHERE ysnPostedInTransit = 1 AND ysnPosted = 0
and intBankTransferTypeId in(1,2,3)
AND datediff( DAY,dbo.fnRemoveTimeOnDate(GETDATE()), dtmDate  ) BETWEEN 0 AND isnull(intBTPostReminderDays,0)

) BT