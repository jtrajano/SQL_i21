CREATE VIEW vyuGLMulticurrencyRevalueGJ
AS
SELECT   strTransactionType		=	GJ.strTransactionType
			,strTransactionId		=	GJ.strJournalId
			,strTransactionDate		=	GJ.dtmDate
			,strTransactionDueDate	=	NULL
			,strVendorName			=	'' COLLATE Latin1_General_CI_AS 
			,strCommodity			=	'' COLLATE Latin1_General_CI_AS 
			,strLineOfBusiness		=	'' COLLATE Latin1_General_CI_AS 
			,strLocation			=	'' COLLATE Latin1_General_CI_AS 
			,strTicket				=	'' COLLATE Latin1_General_CI_AS 
			,strContractNumber		=	'' COLLATE Latin1_General_CI_AS 
			,strItemId				=	'' COLLATE Latin1_General_CI_AS 
			,dblQuantity			=	NULL 
			,dblUnitPrice			=	NULL
			,dblAmount				=	GJD.dblDebitForeign - GJD.dblCreditForeign
			,intCurrencyId			=	GJD.intCurrencyId
			,intForexRateType		=	GJD.intCurrencyExchangeRateTypeId
			,strForexRateType		=	RT.strCurrencyExchangeRateType
			,dblForexRate			=	ISNULL(GJD.dblDebitRate,GJD.dblCreditRate)
			,dblHistoricAmount		=	GJD.dblDebit - GJD.dblCredit
			,dblNewForexRate		=	0
			,dblNewAmount			=	0
			,dblUnrealizedDebitGain =	0
			,dblUnrealizedCreditGain=	0
			,dblDebit				=	0
			,dblCredit				=	0
			,intAccountId			= 	GJD.intAccountId
FROM tblGLJournal GJ JOIN tblGLJournalDetail GJD ON GJ.intJournalId = GJD.intJournalId
LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = GJD.intCurrencyExchangeRateTypeId
LEFT JOIN tblSMCompanyPreference CP on CP.intDefaultCurrencyId = GJD.intCurrencyId
LEFT JOIN tblGLAccount AC ON AC.intAccountId = GJD.intAccountId
WHERE ysnPosted = 1 
AND CP.intDefaultCurrencyId IS NULL
AND AC.ysnRevalue = 1
