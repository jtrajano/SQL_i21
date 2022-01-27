CREATE VIEW vyuCMBTForAccrualPosting
AS
SELECT intTransactionId, intEntityId from tblCMBankTransfer   
OUTER APPLY(SELECT TOP 1 (intBTPostReminderDays * -1 )_days 
FROM tblCMCompanyPreferenceOption)o  
WHERE dtmDate BETWEEN DATEADD(day, isnull(o._days,0),dbo.fnRemoveTimeOnDate(GETDATE()))
AND dbo.fnRemoveTimeOnDate(GETDATE())
AND o._days IS NOT NULL AND  ISNULL(ysnPostedInTransit,0) = 0
AND intBankTransferTypeId in(1,2,3)

