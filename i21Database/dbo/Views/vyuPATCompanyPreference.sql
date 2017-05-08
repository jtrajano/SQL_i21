CREATE VIEW [dbo].[vyuPATCompanyPreference]
	AS
SELECT   CP.intCompanyPreferenceId,
		 ComLoc.intCompanyLocationId,
		 ComLoc.dblWithholdPercent,
         CP.strRefund, 
         CP.dblMinimumRefund, 
         CP.dblServiceFee, 
         CP.dblCutoffAmount, 
         CP.strCutoffTo, 
         CP.strPayOnGrain, 
         CP.strPrintCheck, 
         CP.intPaymentItemId, 
         CP.dblMinimumDividends, 
         CP.ysnProRatedDividends, 
         CP.dtmCutoffDate, 
         CP.intVotingStockId, 
		 strVotingStockId = VA.strAccountId,
         CP.intNonVotingStockId, 
		 strNonVotingStockId = NVA.strAccountId,
         CP.intFractionalShareId, 
		 strFractionalShareId = FSA.strAccountId,
         CP.intServiceFeeIncomeId,
		 strServiceFeeIncomeId = SA.strAccountId,
         CP.intDividendsGLAccount,
		 strDividendsGLAccount = DA.strAccountId, 
         CP.intAPClearingGLAccount,
		 strAPClearingGLAccount = ACA.strAccountId,
		 CP.intConcurrencyId
FROM tblPATCompanyPreference CP
LEFT JOIN tblGLAccount DA
	ON DA.intAccountId = CP.intDividendsGLAccount
LEFT JOIN tblGLAccount VA
	ON VA.intAccountId = CP.intVotingStockId
LEFT JOIN tblGLAccount NVA
	ON NVA.intAccountId = CP.intNonVotingStockId
LEFT JOIN tblGLAccount FSA
	ON FSA.intAccountId = CP.intFractionalShareId
LEFT JOIN tblGLAccount SA 
	ON SA.intAccountId = CP.intServiceFeeIncomeId
LEFT JOIN tblGLAccount ACA
	ON ACA.intAccountId = CP.intAPClearingGLAccount
CROSS APPLY (SELECT intCompanyLocationId,dblWithholdPercent FROM tblSMCompanyLocation) ComLoc
