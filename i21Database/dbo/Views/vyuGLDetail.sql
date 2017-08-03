CREATE VIEW [dbo].[vyuGLDetail]
AS
        SELECT 
		  A.intGLDetailId,
		  A.intAccountId,
		  A.dtmDate,
            A.strBatchId,
            B.strAccountId,
            B.strDescription strAccountDescription,
            C.strAccountGroup,
            C.strAccountType,
            A.dblDebit,
            A.dblCredit,
            dblDebitUnit,
			dblCreditUnit,
            A.strDescription,
            A.strCode,
            A.strReference,
            D.strCurrency,
            A.dblExchangeRate,
            A.dtmDateEntered,
            A.dtmTransactionDate,
            A.strJournalLineDescription,
              CASE
                  WHEN A.ysnIsUnposted = 0
                  THEN 'Posted'
                  ELSE 'Audit Record '
              END AS 'strStatus',
            E.strUserName,
            A.strTransactionId,
            A.strTransactionType,
            A.strTransactionForm,
            A.strModuleName,
            A.dblDebitForeign,
            A.dblDebitReport,
            A.dblCreditForeign,
            A.dblCreditReport,
            A.dblReportingRate,
            A.dblForeignRate,
			A.intJournalLineNo,
			J.strDocument,
			A.ysnIsUnposted,
			A.intTransactionId,
			E.intEntityId,
			J.strComments,
			U.strUOMCode
     FROM tblGLDetail AS A
	 LEFT JOIN tblGLAccount AS B ON A.intAccountId = B.intAccountId
	 LEFT JOIN tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId
	 OUTER APPLY(
		SELECT TOP 1 strComments,strDocument FROM tblGLJournalDetail B JOIN tblGLJournal C
		ON B.intJournalId = C.intJournalId WHERE
		 A.intJournalLineNo = B.intJournalDetailId AND
		 C.intJournalId = A.intTransactionId AND C.strJournalId = A.strTransactionId
	 ) J
	 OUTER APPLY (
		SELECT TOP 1 strUOMCode FROM tblGLAccountUnit WHERE intAccountUnitId = B.intAccountUnitId
	 )U
	 OUTER APPLY(
		SELECT TOP 1 intEntityId,strUserName FROM [tblEMEntityCredential] WHERE intEntityId = A.intEntityId
	 )E
	 OUTER APPLY(
		SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = A.intCurrencyId
	 )D