CREATE VIEW vyuFAUndepreciatedAssetAllPeriods  
AS  
SELECT   
A.intFiscalAssetId,  
A.intAssetId,  
A.intFiscalPeriodId,  
A.intFiscalYearId,  
FP.strPeriod,  
FP.dtmEndDate,  
FY.strFiscalYear,  
B.intBookDepreciationId,  
B.intBookId,  
strBook= CASE WHEN B.intBookId = 1 THEN 'GAAP' WHEN B.intBookId = 2 THEN 'Tax' ELSE '' END COLLATE Latin1_General_CI_AS,  
B.dblCost,  
B.dblSalvageValue,  
B.dtmPlacedInService,  
DM.strConvention,  
DM.strDepreciationType,  
DM.strDepreciationMethodId,
AssetGroup.strGroupCode,
AssetGroup.strGroupDescription
FROM   
tblFAFiscalAsset A  
JOIN tblFABookDepreciation B  
ON B.intAssetId = A.intAssetId  
AND B.intBookId = A.intBookId  
JOIN tblFAFixedAsset C   
ON C.intAssetId = A.intAssetId  
JOIN tblGLFiscalYearPeriod FP ON FP.intGLFiscalYearPeriodId  
= A.intFiscalPeriodId  
JOIN tblGLFiscalYear FY ON FY.intFiscalYearId=FP.intFiscalYearId  
JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = B.intDepreciationMethodId  
LEFT JOIN tblFAFixedAssetGroup AssetGroup ON AssetGroup.intAssetGroupId = C.intAssetGroupId
OUTER APPLY(  
    SELECT COUNT(*) cnt  
    FROM tblFAFixedAssetDepreciation  
    WHERE intBookId = B.intBookId  
    AND intAssetId = B.intAssetId  
    AND CONVERT(nvarchar(10) , dtmDepreciationToDate,101)=   
    CONVERT(nvarchar(10) , FP.dtmEndDate,101)  
)FAD  
WHERE ISNULL(B.ysnFullyDepreciated,0) = 0  
AND ISNULL(C.ysnAcquired,0) = 1  
AND ISNULL(C.ysnDisposed,0) = 0  
AND FAD.cnt = 0