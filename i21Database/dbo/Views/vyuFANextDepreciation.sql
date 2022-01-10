CREATE VIEW vyuFANextDepreciation  
AS  
WITH GetNextForDepreciate AS(  
 SELECT 
    B.intAssetId, 
    dtmNextDepreciation = dbo.fnFAGetNextDepreciationDate(B.intAssetId, BD.intBookId)
 FROM tblFAFixedAssetDepreciation A
 RIGHT JOIN tblFAFixedAsset B ON A.intAssetId = B.intAssetId  
 JOIN tblFABookDepreciation BD on BD.intAssetId = B.intAssetId  
 WHERE 
    ISNULL(BD.ysnFullyDepreciated,0) = 0  
    AND ISNULL(ysnDisposed,0) = 0  
    AND ISNULL(ysnAcquired,0) = 1  
),  
Ordered AS(  
 SELECT 
    intAssetId,  
    dtmNextDepreciation ,  
    ROW_NUMBER() OVER (PARTITION BY intAssetId ORDER BY dtmNextDepreciation DESC ) rowId  
 FROM GetNextForDepreciate  
)  
  
SELECT 
    intAssetId,  
    dtmNextDepreciation dtmDate,  
    F.intGLFiscalYearPeriodId 
FROM Ordered A   
OUTER APPLY(  
    SELECT TOP 1 intGLFiscalYearPeriodId 
    FROM tblGLFiscalYearPeriod   
    WHERE dtmNextDepreciation BETWEEN dtmStartDate AND dtmEndDate  
) F  
WHERE rowId = 1
