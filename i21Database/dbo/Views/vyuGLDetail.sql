CREATE VIEW [dbo].[vyuGLDetail]
AS
        SELECT 
		A.intGLDetailId,
		A.intAccountId,
		A.dtmDate,
        A.strBatchId COLLATE Latin1_General_CI_AS strBatchId,
        B.strAccountId COLLATE Latin1_General_CI_AS strAccountId,
        RTRIM(LTRIM(ISNULL(B.strDescription,''))) COLLATE Latin1_General_CI_AS strAccountDescription,
        C.strAccountGroup COLLATE Latin1_General_CI_AS strAccountGroup,
        C.strAccountType COLLATE Latin1_General_CI_AS strAccountType,
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
        A.strDescription COLLATE Latin1_General_CI_AS strDescription,
        A.strCode COLLATE Latin1_General_CI_AS strCode,
        A.strReference COLLATE Latin1_General_CI_AS strReference,
        D.strCurrency COLLATE Latin1_General_CI_AS strCurrency,
        A.dblExchangeRate,
        A.dtmDateEntered,
        A.dtmTransactionDate,
        RTRIM(LTRIM(ISNULL(A.strJournalLineDescription,''))) COLLATE Latin1_General_CI_AS strJournalLineDescription,
            CASE
                WHEN A.ysnIsUnposted = 0
                THEN 'Posted'
                ELSE 'Audit Record '
            END COLLATE Latin1_General_CI_AS strStatus,
        E.strUserName COLLATE Latin1_General_CI_AS strUserName,
        A.strTransactionId COLLATE Latin1_General_CI_AS strTransactionId,
        A.strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,
        A.strTransactionForm COLLATE Latin1_General_CI_AS strTransactionForm,
        A.strModuleName COLLATE Latin1_General_CI_AS strModuleName,
        A.dblDebitForeign,
        A.dblDebitReport,
        A.dblCreditForeign,
        A.dblCreditReport,
        A.dblReportingRate,
        A.dblForeignRate,
		A.intJournalLineNo,
		A.strDocument COLLATE Latin1_General_CI_AS strDocument,
		A.ysnIsUnposted,
		A.intTransactionId,
		E.intEntityId,
		A.strComments COLLATE Latin1_General_CI_AS strComments,
		U.strUOMCode COLLATE Latin1_General_CI_AS strUOMCode, 
        Loc.strLocationName COLLATE Latin1_General_CI_AS strLocationName,
        ICUOM.strUnitMeasure COLLATE Latin1_General_CI_AS strSourceUOMId,
        ICCom.strCommodityCode COLLATE Latin1_General_CI_AS strCommodityCode,
        ISNULL(dblSourceUnitDebit,0) dblSourceUnitDebit,
        ISNULL(dblSourceUnitCredit,0) dblSourceUnitCredit,
		F.strUserName COLLATE Latin1_General_CI_AS strSourceEntity,
		strSourceDocumentId COLLATE Latin1_General_CI_AS strSourceDocumentId,
        A.ysnPostAction,
        A.dtmDateEnteredMin
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


