CREATE VIEW [dbo].[vyuFACompanyPreferenceOption]
AS
SELECT 
	C.intCompanyPreferenceOptionId,
	C.intAssetAccountId,
	AssetAccount.strAccountId strAssetAccountId,
	C.intExpenseAccountId,
	ExpenseAccount.strAccountId strExpenseAccountId,
	C.intDepreciationAccountId,
	DepreciationAccount.strAccountId strDepreciationAccountId,
	C.intAccumulatedAccountId,
	AccumulatedAccount.strAccountId strAccumulatedAccountId,
	C.intGainLossAccountId,
	GainLossAccount.strAccountId strGainLossAccountId,
	C.intSalesOffsetAccountId,
	SalesOffsetAccount.strAccountId strSalesOffsetAccountId,
	C.intConcurrencyId
FROM tblFACompanyPreferenceOption C
LEFT JOIN tblGLAccount AssetAccount
	ON AssetAccount.intAccountId = C.intAssetAccountId
LEFT JOIN tblGLAccount ExpenseAccount
	ON ExpenseAccount.intAccountId = C.intExpenseAccountId
LEFT JOIN tblGLAccount DepreciationAccount
	ON DepreciationAccount.intAccountId = C.intDepreciationAccountId
LEFT JOIN tblGLAccount AccumulatedAccount
	ON AccumulatedAccount.intAccountId = C.intAccumulatedAccountId
LEFT JOIN tblGLAccount GainLossAccount
	ON GainLossAccount.intAccountId = C.intGainLossAccountId
LEFT JOIN tblGLAccount SalesOffsetAccount
	ON SalesOffsetAccount.intAccountId = C.intSalesOffsetAccountId
