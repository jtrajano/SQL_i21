CREATE VIEW [dbo].[vyuPATCompanyPreference]
	AS
SELECT   CP.intCompanyPreferenceId,
         CP.intGrainDiscountId, 
         CP.intGrainStorageId, 
         CP.intServiceChargeId, 
         CP.intDebitMemoId, 
         CP.intDiscountGivenId, 
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
         CP.intFWTLiabilityAccountId, 
         CP.intDividendsGLAccount,
		 strDividendsGLAccount = DA.strAccountId, 
         CP.intTreasuryGLAccount, 
		 strTreasuryGLAccount = TA.strAccountId,
         CP.intAPClearingGLAccount,
		 CP.intConcurrencyId
FROM tblPATCompanyPreference CP
LEFT JOIN tblGLAccount DA
	ON DA.intAccountId = CP.intDividendsGLAccount
LEFT JOIN tblGLAccount TA
	ON TA.intAccountId = CP.intTreasuryGLAccount