CREATE VIEW [dbo].[vyuFAClosedPeriodAsset]
AS
SELECT 
B.intAssetId,
B.strAssetId,
intGLFiscalYearPeriodId,
strPeriod,
C.intFiscalYearId
FROM tblFAFiscalAsset
A JOIN
tblFAFixedAsset B  ON A.intAssetId = B.intAssetId  JOIN
tblGLFiscalYearPeriod C on C.intGLFiscalYearPeriodId =  A.intFiscalPeriodId
JOIN tblFABookDepreciation D ON D.intAssetId = A.intAssetId AND D.intBookId= A.intBookId
WHERE ISNULL(ysnFAOpen,0) = 0 OR ISNULL(ysnOpen,0) = 0

