CREATE VIEW vyuFAFixedAsset      
AS      
SELECT       
FA.intAssetId, 
FA.strAssetId, 
FA.strAssetDescription,
FA.intCompanyLocationId,
FA.strSerialNumber,
FA.strNotes,
FA.dtmDateAcquired,
FA.dtmDateInService,
FA.dblCost,
FA.dblForexRate,
FA.intCurrencyId,
FA.dblMarketValue,
FA.dblInsuranceValue,
FA.dblSalvageValue,
FA.strBasisDescription,
FA.dtmDispositionDate,
FA.intDispositionNumber,
FA.strDispositionNumber,
FA.strDispositionComment,
FA.dblDispositionAmount,
FA.strPoolId,
FA.intAccuitent,
FA.intAssetAccountId,
FA.intExpenseAccountId,
FA.intDepreciationAccountId,
FA.intAccumulatedAccountId,
FA.intGainLossAccountId,
FA.strManufacturerName,
FA.strModelNumber,
FA.ysnAcquired,
FA.ysnImported,
FA.dtmImportedDepThru,
FA.dblImportGAAPDepToDate,
FA.dblImportTaxDepToDate,
ysnTaxDepreciated = ISNULL(FA.ysnTaxDepreciated,0),
ysnDepreciated = ISNULL(FA.ysnDepreciated, 0) | ISNULL(FA.ysnTaxDepreciated, 0),
FA.ysnDisposed,     
FA.dblCost - FA.dblSalvageValue dblBasis,      
DM.intDepreciationMethodId,      
DM.strDepreciationMethodId,      
DM.strConvention,      
DM.strDepreciationType,      
GLAsset.strAccountId strAssetAccountId,      
GLExpense.strAccountId strExpenseAccountId,      
GLDepreciation.strAccountId strDepreciationAccountId,      
GLAccumulation.strAccountId strAccumulatedAccountId,      
GLGainLoss.strAccountId strGainLossAccountId,      
Company.strLocationName strCompanyLocation,      
Currency.strCurrency,
ysnFullyDepreciated = 
 CASE WHEN (BDFD.Cnt > 0 AND BDCnt.Cnt > 0) OR BDCnt.Cnt = 0
 THEN CAST(0 AS BIT)
 
 ELSE 
    CAST(1 AS BIT)
    END,
FA.intConcurrencyId
from tblFAFixedAsset FA     
LEFT JOIN tblGLAccount GLAsset ON GLAsset.intAccountId = FA.intAssetAccountId      
LEFT JOIN tblGLAccount GLExpense ON GLExpense.intAccountId = FA.intExpenseAccountId      
LEFT JOIN tblGLAccount GLDepreciation ON GLDepreciation.intAccountId = FA.intDepreciationAccountId      
LEFT JOIN tblGLAccount GLAccumulation ON GLAccumulation.intAccountId = FA.intAccumulatedAccountId      
LEFT JOIN tblGLAccount GLGainLoss ON GLGainLoss.intAccountId = FA.intGainLossAccountId      
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID=FA.intCurrencyId      
LEFT JOIN tblSMCompanyLocation Company ON Company.intCompanyLocationId = FA.intCompanyLocationId      
OUTER APPLY(  
 SELECT TOP 1 intDepreciationMethodId
 FROM tblFABookDepreciation  
 WHERE intAssetId = FA.intAssetId
 AND intBookId = 1
)BD  
OUTER APPLY(  
 SELECT TOP 1 dm.intDepreciationMethodId,
 strDepreciationMethodId,strConvention,strDepreciationType  
 FROM tblFADepreciationMethod dm JOIN 
 tblFABookDepreciation bd ON dm.intDepreciationMethodId=bd.intDepreciationMethodId
 WHERE bd.intDepreciationMethodId  = BD.intDepreciationMethodId  
)DM
OUTER APPLY(
    SELECT COUNT(*)Cnt FROM tblFABookDepreciation 
    WHERE intAssetId = FA.intAssetId
)BDCnt
OUTER APPLY(
    SELECT COUNT(*)Cnt  FROM tblFABookDepreciation 
    WHERE intAssetId = FA.intAssetId
    AND ISNULL(ysnFullyDepreciated,0) = 0
)BDFD
