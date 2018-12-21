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
			CASE WHEN strModuleName = 'General Ledger' THEN
				CASE WHEN ISNULL(U.dblLbsPerUnit,0) > 0 THEN CAST((A.dblDebitUnit/ U.dblLbsPerUnit) AS numeric(18,6)) ELSE 0 END
			ELSE
				dblDebitUnit END dblDebitUnit,
			CASE WHEN strModuleName = 'General Ledger' THEN
				CASE WHEN ISNULL(U.dblLbsPerUnit,0) > 0 THEN CAST((A.dblCreditUnit/ U.dblLbsPerUnit) AS numeric(18,6)) ELSE 0 END
			ELSE
				dblCreditUnit END dblCreditUnit,
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
			A.strDocument,
			A.ysnIsUnposted,
			A.intTransactionId,
			E.intEntityId,
			A.strComments,
			U.strUOMCode,

            Loc.strLocationName,
            ICUOM.strUnitMeasure strSourceUOMId,
            ICCom.strCommodityCode,
            ISNULL(dblSourceUnitDebit,0) dblSourceUnitDebit,
            ISNULL(dblSourceUnitCredit,0) dblSourceUnitCredit,
			F.strUserName strSourceEntity,
			strSourceDocumentId

     FROM tblGLDetail AS A
	 LEFT JOIN tblGLAccount AS B ON A.intAccountId = B.intAccountId
	 LEFT JOIN tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId
     LEFT JOIN tblSMCompanyLocation Loc ON A.intSourceLocationId = Loc.intCompanyLocationId
     LEFT JOIN tblICUnitMeasure ICUOM ON ICUOM.intUnitMeasureId = A.intSourceUOMId
     LEFT JOIN tblICCommodity ICCom ON ICCom.intCommodityId = A.intCommodityId
	 OUTER APPLY (
		SELECT TOP 1 dblLbsPerUnit,strUOMCode FROM tblGLAccountUnit WHERE intAccountUnitId = B.intAccountUnitId
	 )U
	 OUTER APPLY(
		SELECT TOP 1 intEntityId,strName strUserName FROM [tblEMEntity] WHERE intEntityId = A.intEntityId
	 )E
	 OUTER APPLY(
		SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = A.intCurrencyId
	 )D
	  OUTER APPLY(
		SELECT TOP 1 strName strUserName FROM [tblEMEntity] WHERE intEntityId = A.intSourceEntityId
	 )F
	 
GO


