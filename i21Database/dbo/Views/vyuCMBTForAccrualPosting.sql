CREATE VIEW vyuCMBTForAccrualPosting
AS
SELECT intTransactionId, intEntityId  from tblCMBankTransfer   
OUTER APPLY(SELECT TOP 1 isnull(intBTPostReminderDays,0) _days 
FROM tblCMCompanyPreferenceOption)o  
WHERE datediff( DAY, dtmDate, dbo.fnRemoveTimeOnDate(GETDATE()) ) BETWEEN 0 AND o._days

AND  ISNULL(ysnPostedInTransit,0) = 0
AND intBankTransferTypeId in(1,2,3)

