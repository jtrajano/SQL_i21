CREATE VIEW vyuGLMulticurrencyRevalueGJ
AS
SELECT   strTransactionType		    
			,strTransactionId		--=	COA.strAccountId + '_' + SM.strCurrency + '_' + substring(convert(nvarchar(10),  GJ.dtmDate , 102),1,7)
			,strTransactionDate		=	CONVERT(nvarchar(10),  GJ.dtmDate , 102)
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
			,dblAmount				=	ISNULL(GJ.dblDebitForeign,0) - ISNULL(GJ.dblCreditForeign,0)
			,intCurrencyId			=	GJ.intCurrencyId
			,intForexRateType		=	NULL
			,strForexRateType		=	''--SMC.strCurrencyExchangeRateType
			,dblForexRate			=	ISNULL(dblExchangeRate, CASE WHEN (GJ.dblDebitForeign - GJ.dblCreditForeign)<> 0 THEN (GJ.dblDebit - GJ.dblCredit)/(GJ.dblDebitForeign - GJ.dblCreditForeign) ELSE 0 END)
			,dblHistoricAmount		=	GJ.dblDebit - GJ.dblCredit
			,dblNewForexRate		=	0
			,dblNewAmount			=	0
			,dblUnrealizedDebitGain =	0
			,dblUnrealizedCreditGain=	0
			,dblDebit				=	0
			,dblCredit				=	0
			,intAccountId			= 	GJ.intAccountId
			,GJ.dtmDate	
			,SM.strCurrency		
FROM tblGLDetail GJ JOIN vyuGLAccountDetail COA ON COA.intAccountId = GJ.intAccountId
LEFT JOIN tblSMCompanyPreference CP on CP.intDefaultCurrencyId = GJ.intCurrencyId
JOIN tblSMCurrency SM ON SM.intCurrencyID = GJ.intCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType SMC ON SMC.intCurrencyExchangeRateTypeId = GJ.intCurrencyExchangeRateTypeId
WHERE ysnIsUnposted = 0
AND CP.intDefaultCurrencyId IS NULL
AND ISNULL(COA.ysnRevalue,0) = 1
AND GJ.dblDebit - GJ.dblCredit > 0
--GROUP BY intCurrencyId, SM.strCurrency ,GJ.intAccountId, COA.strAccountId,substring(convert(nvarchar(10), dtmDate , 102),1,7)
--,COA.intAccountCategoryId

