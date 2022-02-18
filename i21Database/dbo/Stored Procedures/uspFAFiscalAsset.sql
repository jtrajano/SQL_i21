CREATE PROCEDURE uspFAFiscalAsset
  @intAssetId INT,
  @intBookId INT
AS
DECLARE 
@intDepMethodId INT, 
@dtmPlacedInService DATETIME,
@totalMonths INT 

DELETE FROM  tblFAFiscalAsset where intAssetId = @intAssetId and @intBookId = intBookId

SELECT @intDepMethodId =intDepreciationMethodId,
@dtmPlacedInService =dtmPlacedInService

FROM tblFABookDepreciation WHERE @intAssetId = intAssetId AND intBookId = @intBookId

IF @intDepMethodId IS NULL RETURN

SELECT @totalMonths= isnull(intServiceYear,0) * 12 + isnull( intMonth,0) +
CASE 
WHEN strConvention = 'Actual Days' OR strConvention = 'Mid Month' THEN 1
WHEN strConvention = 'Full Month' THEN 0 
ELSE 0 END FROM tblFADepreciationMethod
WHERE intDepreciationMethodId = @intDepMethodId

DECLARE @i INT = 0
DECLARE @dtmDep DATETIME 
DECLARE @Rows INT
WHILE @i < @totalMonths
BEGIN
	 SELECT @dtmDep = CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(MONTH,1, @dtmPlacedInService)) + @i,0)) AS DATE)
	 INSERT INTO tblFAFiscalAsset (intFiscalYearId, intFiscalPeriodId, intAssetId, intBookId )
	 SELECT  intFiscalYearId, intGLFiscalYearPeriodId , @intAssetId, @intBookId
	 FROM tblGLFiscalYearPeriod WHERE @dtmDep BETWEEN dtmStartDate AND dtmEndDate
	SET @i = @i+1
END



