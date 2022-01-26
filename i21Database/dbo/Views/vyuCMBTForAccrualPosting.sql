CREATE VIEW vyuCMBTForAccrualPosting
AS
SELECT intTransactionId, intEntityId from tblCMBankTransfer   
OUTER APPLY(SELECT TOP 1 (intBankTransferPostReminderDays * -1 )_days 
FROM tblCMCompanyPreferenceOption)o  
WHERE dtmDate BETWEEN DATEADD(day, isnull(o._days,0),dbo.fnRemoveTimeOnDate(getdate()))
AND dbo.fnRemoveTimeOnDate(getdate())
AND o._days IS NOT NULL AND  ysnPostedInTransit = 0
AND intBankTransferTypeId in(2,3)

