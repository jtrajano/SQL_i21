CREATE VIEW vyuCMBTForAccrualSwapPosting
AS
SELECT 
S.intBankSwapId,u.intEntityId
FROM 
tblCMBankSwap S 
OUTER APPLY(
	select intEntityId, dtmDate,ysnPostedInTransit FROM tblCMBankTransfer WHERE intTransactionId in(S.intSwapLongId, S.intSwapShortId)
)u
OUTER APPLY(SELECT TOP 1 (intBTPostReminderDays * -1 )_days   
FROM tblCMCompanyPreferenceOption)o    
WHERE dtmDate BETWEEN DATEADD(day, isnull(o._days,0),dbo.fnRemoveTimeOnDate(getdate()))
AND dbo.fnRemoveTimeOnDate(getdate())  
AND o._days IS NOT NULL AND  isnull(ysnPostedInTransit,0) = 0 
