CREATE VIEW vyuFAFixedAsset
AS
SELECT 
FA.*,
DM.intDepreciationMethodId,
DM.strDepreciationMethodId,
DM.strConvention,
DM.strDepreciationType,
GLAsset.strAccountId strAssetAccountId,
GLExpense.strAccountId strExpenseAccountId,
GLDepreciation.strAccountId strDepreciationAccountId,
GLAccumulation.strAccountId strAccumulatedAccountId,
GLGainLoss.strAccountId strGainLossAccountId,
D.dblDepreciationToDate,
Company.strLocationName strCompanyLocation,
Currency.strCurrency
from tblFAFixedAsset FA
LEFT JOIN tblFADepreciationMethod DM ON FA.intAssetId = DM.intAssetId
LEFT JOIN tblGLAccount GLAsset ON GLAsset.intAccountId = FA.intAssetAccountId
LEFT JOIN tblGLAccount GLExpense ON GLExpense.intAccountId = FA.intExpenseAccountId
LEFT JOIN tblGLAccount GLDepreciation ON GLDepreciation.intAccountId = FA.intDepreciationAccountId
LEFT JOIN tblGLAccount GLAccumulation ON GLAccumulation.intAccountId = FA.intAccumulatedAccountId
LEFT JOIN tblGLAccount GLGainLoss ON GLGainLoss.intAccountId = FA.intGainLossAccountId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID=FA.intCurrencyId
LEFT JOIN tblSMCompanyLocation Company ON Company.intCompanyLocationId = FA.intCompanyLocationId
OUTER APPLY(
	SELECT TOP 1 dblDepreciationToDate FROM tblFAFixedAssetDepreciation WHERE intDepreciationMethodId = DM.intDepreciationMethodId ORDER BY intAssetDepreciationId DESC
)D




