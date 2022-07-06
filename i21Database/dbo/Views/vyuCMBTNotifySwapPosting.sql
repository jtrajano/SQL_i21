CREATE VIEW vyuCMBTNotifySwapPosting
AS
  SELECT BTS.intEntityId,
         intBankSwapId
  FROM   tblCMCompanyPreferenceOption o
         CROSS APPLY(SELECT S.intBankSwapId,
                            intEntityId,
                            dtmInTransit
                     FROM   tblCMBankSwap S
                            CROSS APPLY(SELECT intEntityId,
                                               dtmInTransit
                                        FROM   tblCMBankTransfer B
                                        WHERE  ( S.intSwapLongId =
                                                 B.intTransactionId
                                                  OR S.intSwapShortId =
                                                     B.intTransactionId )
                                               AND ysnPostedInTransit = 1
                                               AND ysnPosted = 0)BT) BTS
  WHERE  DATEDIFF(DAY, dbo.fnRemoveTimeOnDate(GETDATE()), BTS.dtmInTransit)
         BETWEEN CASE
                WHEN ISNULL(intBTPostReminderDays, 0) < 0 THEN
                	 ISNULL(intBTPostReminderDays, 0) ELSE 0 END
                AND 
				CASE
                WHEN 0 > ISNULL(intBTPostReminderDays, 0) THEN 0
                    ELSE ISNULL(intBTPostReminderDays, 0) END