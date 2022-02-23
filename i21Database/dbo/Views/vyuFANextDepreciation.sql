CREATE VIEW vyuFANextDepreciation  
AS  
WITH GetNextForDepreciate AS(  
 SELECT B.intAssetId, 
 dtmNextDepreciation = 
 CASE 
   WHEN dtmDepreciationToDate IS NULL 
      THEN 
        CASE WHEN(ISNULL(B.ysnImported, 0) = 1 AND B.dtmCreateAssetPostDate IS NOT NULL)
            THEN B.dtmCreateAssetPostDate
            ELSE B.dtmDateInService 
        END
   WHEN dtmDepreciationToDate = B.dtmDateInService   
      THEN  DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(MONTH,1 , B.dtmDateInService)),0))
   ELSE DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(MONTH,1 , dtmDepreciationToDate))+1,0))
 END  
 FROM tblFAFixedAssetDepreciation A RIGHT JOIN  
    tblFAFixedAsset B ON A.intAssetId = B.intAssetId  
 JOIN tblFABookDepreciation BD on BD.intAssetId = B.intAssetId  
 WHERE ISNULL(BD.ysnFullyDepreciated,0) = 0  
 AND ISNULL(ysnDisposed,0) = 0  
 AND ISNULL(ysnAcquired,0) = 1  
),  
Ordered AS(  
 SELECT intAssetId ,  
 dtmNextDepreciation ,  
 ROW_NUMBER() OVER (PARTITION BY intAssetId ORDER BY dtmNextDepreciation DESC ) rowId  
 FROM   
 GetNextForDepreciate  
)  
  
SELECT intAssetId,  
dtmNextDepreciation dtmDate,  
 F.intGLFiscalYearPeriodId FROM Ordered A   
OUTER APPLY(  
 SELECT TOP 1 intGLFiscalYearPeriodId FROM tblGLFiscalYearPeriod   
    WHERE dtmNextDepreciation BETWEEN dtmStartDate AND dtmEndDate  
)F  
WHERE rowId = 1
