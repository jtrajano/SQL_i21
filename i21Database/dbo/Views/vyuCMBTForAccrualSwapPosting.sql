CREATE VIEW vyuCMBTForAccrualSwapPosting
AS
SELECT 
S.intBankSwapId,u.intEntityId
FROM 
tblCMBankSwap S 
OUTER APPLY(
	select intEntityId, dtmDate,ysnPostedInTransit FROM tblCMBankTransfer WHERE intTransactionId in(S.intSwapLongId, S.intSwapShortId)
)u
OUTER APPLY(SELECT TOP 1 ISNULL(intBTPostReminderDays,0) _days   
FROM tblCMCompanyPreferenceOption)o    
WHERE DATEDIFF( DAY, dtmDate, dbo.fnRemoveTimeOnDate(GETDATE()) ) BETWEEN 0 AND o._days
AND  ISNULL(ysnPostedInTransit,0) = 0 
