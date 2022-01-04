CREATE VIEW vyuFAFixedAsset        
AS        
SELECT         
FA.intAssetId,   
FA.strAssetId,   
FA.strAssetDescription,  
FA.intCompanyLocationId,
FA.intParentAssetId,
FA.strSerialNumber,  
FA.strNotes,  
FA.dtmDateAcquired,  
FA.dtmDateInService,  
FA.dblCost,
FA.dblFunctionalCost,
FA.dblForexRate,  
FA.intCurrencyId,  
FA.intFunctionalCurrencyId,
FA.intCurrencyExchangeRateTypeId,
FA.dblMarketValue,  
FA.dblInsuranceValue,  
FA.dblSalvageValue,
FA.dblFunctionalSalvageValue,
FA.strBasisDescription,  
FA.dtmDispositionDate,  
FA.intDispositionNumber,  
FA.strDispositionNumber,  
FA.strDispositionComment,  
FA.dblDispositionAmount,  
FA.strPoolId,  
FA.intLegacyId,  
FA.intAssetAccountId,  
FA.intExpenseAccountId,  
FA.intDepreciationAccountId,  
FA.intAccumulatedAccountId,  
FA.intGainLossAccountId,  
FA.intSalesOffsetAccountId,
FA.strManufacturerName,  
FA.strModelNumber,  
FA.ysnAcquired,  
FA.ysnImported,  
FA.dtmImportedDepThru,  
FA.dblImportGAAPDepToDate,  
FA.dblImportTaxDepToDate,  
dblGAAPDepToDate = ISNULL(GAAPDepreciation.dblDepreciationToDate,0),
dblFunctionalGAAPDepToDate = ISNULL(GAAPDepreciation.dblFunctionalDepreciationToDate,0),
dblTaxDepToDate = ISNULL(TaxDepreciation.dblDepreciationToDate,0),
dblFunctionalTaxDepToDate = ISNULL(TaxDepreciation.dblFunctionalDepreciationToDate,0),
dblNetBookValue =ISNULL(FA.dblCost - ISNULL(GAAPDepreciation.dblDepreciationToDate, 0), 0),
dblFunctionalNetBookValue =ISNULL(FA.dblCost - ISNULL(GAAPDepreciation.dblFunctionalDepreciationToDate, 0), 0),
ysnTaxDepreciated = ISNULL(FA.ysnTaxDepreciated,0),  
ysnDepreciated = ISNULL(FA.ysnDepreciated, 0) | ISNULL(FA.ysnTaxDepreciated, 0),  
FA.ysnDisposed,       
ISNULL(FA.dblCost - FA.dblSalvageValue, 0) dblBasis,        
ISNULL(FA.dblFunctionalCost - FA.dblFunctionalSalvageValue, 0) dblFunctionalBasis,        
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
GLARAccount.strAccountId strSalesOffsetAccountId,
Company.strLocationName strCompanyLocation,        
Currency.strCurrency,  
FunctionalCurrency.strCurrency strFunctionalCurrency,  
RateType.strCurrencyExchangeRateType,
ysnFullyDepreciated =   
 CASE WHEN (BDFD.Cnt > 0 AND BDCnt.Cnt > 0) OR BDCnt.Cnt = 0  
 THEN CAST(0 AS BIT)  
   
 ELSE   
    CAST(1 AS BIT)  
    END,
ParentAssetDetails.strAssetId strParentAssetId,
ysnParentAsset = CAST( 
    CASE WHEN ISNULL(ParentAsset.intChildAsset, 0) > 0
    THEN 1 ELSE 0 END
    AS BIT),
ysnChildAsset = CAST( 
    CASE WHEN ChildAsset.strAssetId IS NULL
    THEN 0 ELSE 1 END
    AS BIT),
FA.intConcurrencyId  
FROM tblFAFixedAsset FA       
LEFT JOIN tblGLAccount GLAsset ON GLAsset.intAccountId = FA.intAssetAccountId        
LEFT JOIN tblGLAccount GLExpense ON GLExpense.intAccountId = FA.intExpenseAccountId        
LEFT JOIN tblGLAccount GLDepreciation ON GLDepreciation.intAccountId = FA.intDepreciationAccountId        
LEFT JOIN tblGLAccount GLAccumulation ON GLAccumulation.intAccountId = FA.intAccumulatedAccountId        
LEFT JOIN tblGLAccount GLGainLoss ON GLGainLoss.intAccountId = FA.intGainLossAccountId        
LEFT JOIN tblGLAccount GLARAccount ON GLARAccount.intAccountId = FA.intSalesOffsetAccountId        
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID=FA.intCurrencyId        
LEFT JOIN tblSMCurrency FunctionalCurrency ON FunctionalCurrency.intCurrencyID = FA.intFunctionalCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType RateType ON RateType.intCurrencyExchangeRateTypeId = FA.intCurrencyExchangeRateTypeId
LEFT JOIN tblSMCompanyLocation Company ON Company.intCompanyLocationId = FA.intCompanyLocationId        
LEFT JOIN tblFADepreciationMethod DM on DM.intDepreciationMethodId = FA.intDepreciationMethodId
LEFT JOIN tblFAFixedAssetGroup AssetGroup ON AssetGroup.intAssetGroupId = FA.intAssetGroupId
OUTER APPLY(  
    SELECT COUNT(*) Cnt FROM tblFABookDepreciation   
    WHERE intAssetId = FA.intAssetId  
)BDCnt  
OUTER APPLY(  
    SELECT COUNT(*) Cnt  FROM tblFABookDepreciation   
    WHERE intAssetId = FA.intAssetId  
    AND ISNULL(ysnFullyDepreciated,0) = 0  
)BDFD
OUTER APPLY (
    SELECT TOP 1 dblDepreciationToDate, dblFunctionalDepreciationToDate
    FROM tblFAFixedAssetDepreciation
    WHERE intAssetId = FA.intAssetId
    AND intBookId = 1
    ORDER BY dtmDepreciationToDate DESC
    
)GAAPDepreciation
OUTER APPLY (
    SELECT TOP 1 dblDepreciationToDate, dblFunctionalDepreciationToDate
    FROM tblFAFixedAssetDepreciation
    WHERE intAssetId = FA.intAssetId
    AND intBookId = 2
    ORDER BY dtmDepreciationToDate DESC
    
)TaxDepreciation
OUTER APPLY (
    SELECT strAssetId
    FROM tblFAFixedAsset 
    WHERE intAssetId = FA.intParentAssetId
) ParentAssetDetails
OUTER APPLY (
    SELECT COUNT(1) intChildAsset
    FROM tblFAFixedAsset 
    WHERE intParentAssetId = FA.intAssetId
) ParentAsset
OUTER APPLY (
    SELECT strAssetId
    FROM tblFAFixedAsset 
    WHERE intAssetId = FA.intAssetId AND intParentAssetId IS NOT NULL
) ChildAsset
