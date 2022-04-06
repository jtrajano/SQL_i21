CREATE VIEW vyuCMBTNotifyPosting
AS
  SELECT BT.intEntityId,
         BT.intTransactionId,
         BT.strTransactionId
  FROM   tblCMCompanyPreferenceOption o
         CROSS APPLY(SELECT intTransactionId,
                            intEntityId,
                            strTransactionId,
                            dtmInTransit
                     FROM   tblCMBankTransfer
                     WHERE  ysnPostedInTransit = 1
                            AND ysnPosted = 0
                            AND intBankTransferTypeId IN( 2, 3 )
                            AND Datediff(DAY, dbo.fnRemoveTimeOnDate(Getdate()),
                                dtmInTransit)
                                BETWEEN CASE
                                WHEN
                                    ISNULL(intBTPostReminderDays, 0) < 0 THEN
                                    ISNULL(intBTPostReminderDays, 0) ELSE 0 END
                                AND
                                    CASE
                                      WHEN 0 > ISNULL(intBTPostReminderDays, 0) THEN 
                                      0 ELSE ISNULL(intBTPostReminderDays, 0)
                                    END
                    ) BT 