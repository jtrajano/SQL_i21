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
         CP.intNonVotingStockId, 
         CP.intFractionalShareId, 
         CP.intServiceFeeIncomeId, 
         CP.intDividendsGLAccount,
		 strDividendsGLAccount = DA.strAccountId, 
         CP.intAPClearingGLAccount,
		 CP.intConcurrencyId
FROM tblPATCompanyPreference CP
LEFT JOIN tblGLAccount DA
	ON DA.intAccountId = CP.intDividendsGLAccount
CROSS APPLY (SELECT intCompanyLocationId,dblWithholdPercent FROM tblSMCompanyLocation) ComLoc