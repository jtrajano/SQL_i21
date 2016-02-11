CREATE VIEW dbo.vyuGLDetail
AS
     SELECT 
		  A.intGLDetailId,
		  A.intAccountId,
		  A.dtmDate,
            A.strBatchId,
            B.strAccountId,
            C.strAccountGroup,
            C.strAccountType,
            A.dblDebit,
            A.dblCredit,
            A.dblDebitUnit,
            A.dblCreditUnit,
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
            A.dblForeignRate
     FROM tblGLDetail AS A
          LEFT JOIN tblGLAccount AS B ON A.intAccountId = B.intAccountId
          LEFT JOIN tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId
          LEFT JOIN tblSMCurrency AS D ON D.intCurrencyID = A.intCurrencyId
          LEFT JOIN tblEntityCredential AS E ON E.intEntityId = A.intEntityId