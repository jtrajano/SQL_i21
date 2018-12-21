CREATE VIEW [dbo].[vyuGLSearchGJ]
AS
SELECT strJournalType,
           strTransactionType,
           strSourceType,
           j.strJournalId,
           j.strDescription,
           j.intJournalId,
           ysnPosted,
           dtmDate,
           dtmReverseDate,
           dtmDateEntered,
           e.strName strUserName,
           total.dblCredit,
           total.dblDebit,
		   strCurrency,
		   ysnRecurringTemplate
   FROM tblGLJournal j
   OUTER APPLY (SELECT  j.strJournalId,
          SUM(ISNULL(d.dblCredit,0.0)) dblCredit,
          SUM(ISNULL(d.dblDebit,0.0)) dblDebit
   FROM tblGLJournalDetail d WHERE j.intJournalId = d.intJournalId) total
   LEFT JOIN tblEMEntity e ON e.intEntityId = j.intEntityId
   LEFT JOIN tblSMCurrency C ON C.intCurrencyID = j.intCurrencyId
   where  strTransactionType IN ('General Journal','Recurring')
   and  ISNULL(strSourceType,'') <> 'AA'
GO
CREATE NONCLUSTERED INDEX [_dta_index_tblEMEntity_9_2007079032__K1_2] ON [dbo].[tblEMEntity]
(
	[intEntityId] ASC
)
INCLUDE ( 	[strName]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_600545373_4_19_15] ON [dbo].[tblGLJournal]([strTransactionType], [strSourceType], [intEntityId])
GO
CREATE STATISTICS [_dta_stat_600545373_7_15_1_19] ON [dbo].[tblGLJournal]([intCurrencyId], [intEntityId], [intJournalId], [strSourceType])
GO
CREATE STATISTICS [_dta_stat_600545373_7_4_19_15] ON [dbo].[tblGLJournal]([intCurrencyId], [strTransactionType], [strSourceType], [intEntityId])
GO
CREATE STATISTICS [_dta_stat_600545373_19_7_15] ON [dbo].[tblGLJournal]([strSourceType], [intCurrencyId], [intEntityId])
GO
CREATE NONCLUSTERED INDEX [_dta_index_tblGLJournal_9_600545373__K15_K4_K19_K7_K1_2_3_5_10_11_13_17] ON [dbo].[tblGLJournal]
(
	[intEntityId] ASC,
	[strTransactionType] ASC,
	[strSourceType] ASC,
	[intCurrencyId] ASC,
	[intJournalId] ASC
)
INCLUDE ( 	[dtmReverseDate],
	[strJournalId],
	[dtmDate],
	[strDescription],
	[ysnPosted],
	[dtmDateEntered],
	[strJournalType]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_600545373_1_4_19_7_15] ON [dbo].[tblGLJournal]([intJournalId], [strTransactionType], [strSourceType], [intCurrencyId], [intEntityId])
GO
CREATE STATISTICS [_dta_stat_600545373_19_4] ON [dbo].[tblGLJournal]([strSourceType], [strTransactionType])
GO
CREATE NONCLUSTERED INDEX [_dta_index_tblGLJournalDetail_9_691598348__K3_6_8] ON [dbo].[tblGLJournalDetail]
(
	[intJournalId] ASC
)
INCLUDE ( 	[dblDebit],
	[dblCredit]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO