CREATE VIEW vyuCMBTNotifySwapPosting
AS
SELECT BTS.intEntityId, intBankSwapId
FROM tblCMCompanyPreferenceOption o  
CROSS APPLY(
SELECT 
S.intBankSwapId,intEntityId,dtmInTransit
FROM 
tblCMBankSwap S  
	CROSS APPLY(
		SELECT intEntityId, dtmInTransit FROM tblCMBankTransfer B 
		WHERE (S.intSwapLongId = B.intTransactionId OR S.intSwapShortId = B.intTransactionId)
		AND ysnPostedInTransit = 1 AND ysnPosted = 0
	)BT
	

) BTS
WHERE datediff( DAY, BTS.dtmInTransit, dbo.fnRemoveTimeOnDate(GETDATE()) ) BETWEEN 0 AND isnull(intBTPostReminderDays,0)

