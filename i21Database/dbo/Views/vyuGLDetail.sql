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
            CASE WHEN ISNULL(U.dblLbsPerUnit,0) > 0 THEN CAST((A.dblDebitUnit/ U.dblLbsPerUnit) AS numeric(18,6)) ELSE 0 END dblDebitUnit,
			CASE WHEN ISNULL(U.dblLbsPerUnit,0) > 0 THEN CAST((A.dblCreditUnit/ U.dblLbsPerUnit) AS numeric(18,6)) ELSE 0 END dblCreditUnit,
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
		SELECT TOP 1 strComments, strDocument FROM tblGLJournalDetail WHERE intJournalDetailId = A.intJournalLineNo
	 ) J
	 OUTER APPLY (
		SELECT TOP 1 dblLbsPerUnit,strUOMCode FROM tblGLAccountUnit WHERE intAccountUnitId = B.intAccountUnitId
	 )U
	 OUTER APPLY(
		SELECT TOP 1 intEntityId,strUserName FROM [tblEMEntityCredential] WHERE intEntityId = A.intEntityId
	 )E
	 OUTER APPLY(
		SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = A.intCurrencyId
	 )D