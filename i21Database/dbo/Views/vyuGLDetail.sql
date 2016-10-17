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
            CASE WHEN ISNULL(U.dblLbsPerUnit,0) > 0 THEN A.dblDebitUnit/ U.dblLbsPerUnit ELSE 0 END dblDebitUnit,
			CASE WHEN ISNULL(U.dblLbsPerUnit,0) > 0 THEN A.dblCreditUnit/ U.dblLbsPerUnit ELSE 0 END dblCreditUnit,
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
		  LEFT JOIN tblGLJournalDetail J ON A.intJournalLineNo = J.intJournalDetailId
          LEFT JOIN tblGLAccount AS B ON A.intAccountId = B.intAccountId
		  LEFT JOIN tblGLAccountUnit AS U ON B.intAccountUnitId = U.intAccountUnitId
          LEFT JOIN tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId
          LEFT JOIN tblSMCurrency AS D ON D.intCurrencyID = A.intCurrencyId
          LEFT JOIN [tblEMEntityCredential] AS E ON E.intEntityId = A.intEntityId