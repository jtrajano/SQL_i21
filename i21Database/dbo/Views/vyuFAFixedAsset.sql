CREATE VIEW vyuFAFixedAsset        
AS        
SELECT         
FA.intAssetId,   
FA.strAssetId,   
FA.strAssetDescription,  
FA.intCompanyLocationId,  
FA.strSerialNumber,
FA.strDepartment,
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
FA.dtmCreateAssetPostDate,
dblGAAPDepToDate = ISNULL(GAAPDepreciation.dblDepreciationToDate,0),
dblTaxDepToDate = ISNULL(TaxDepreciation.dblDepreciationToDate,0),
ysnTaxDepreciated = ISNULL(FA.ysnTaxDepreciated,0),  
ysnDepreciated = ISNULL(FA.ysnDepreciated, 0) | ISNULL(FA.ysnTaxDepreciated, 0),  
FA.ysnDisposed,       
FA.dblCost - FA.dblSalvageValue dblBasis,        
DM.intDepreciationMethodId,        
DM.strDepreciationMethodId,        
DM.strConvention,        
DM.strDepreciationType,
AssetGroup.intAssetGroupId,
AssetGroup.strGroupCode,
AssetGroup.strGroupDescription,
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
LEFT JOIN tblFADepreciationMethod DM on DM.intDepreciationMethodId = FA.intDepreciationMethodId
LEFT JOIN tblFAFixedAssetGroup AssetGroup ON AssetGroup.intAssetGroupId = FA.intAssetGroupId
OUTER APPLY(  
    SELECT COUNT(*)Cnt FROM tblFABookDepreciation   
    WHERE intAssetId = FA.intAssetId  
)BDCnt  
OUTER APPLY(  
    SELECT COUNT(*)Cnt  FROM tblFABookDepreciation   
    WHERE intAssetId = FA.intAssetId  
    AND ISNULL(ysnFullyDepreciated,0) = 0  
)BDFD
OUTER APPLY (
    SELECT 
    MAX(dblDepreciationToDate) dblDepreciationToDate
    FROM tblFAFixedAssetDepreciation
    WHERE intAssetId = FA.intAssetId
    AND intBookId =1
    
)GAAPDepreciation
OUTER APPLY (
    SELECT 
    MAX(dblDepreciationToDate) dblDepreciationToDate
    FROM tblFAFixedAssetDepreciation
    WHERE intAssetId = FA.intAssetId
    AND intBookId =2
    
)TaxDepreciation