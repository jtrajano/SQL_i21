CREATE PROCEDURE uspFAFiscalAsset
  @intAssetId INT,
  @intBookDepreciationId INT
AS
DECLARE 
	@intDepMethodId INT, 
	@dtmPlacedInService DATETIME,
	@totalMonths INT,
	@intBookId INT


SELECT 
	  @intDepMethodId =intDepreciationMethodId
	, @dtmPlacedInService =dtmPlacedInService
	, @intBookId = intBookId
FROM tblFABookDepreciation WHERE @intAssetId = intAssetId AND intBookDepreciationId = @intBookDepreciationId

DELETE FROM  tblFAFiscalAsset WHERE intAssetId = @intAssetId AND intBookDepreciationId = @intBookDepreciationId


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
	 INSERT INTO tblFAFiscalAsset (intFiscalYearId, intFiscalPeriodId, intAssetId, intBookId, intBookDepreciationId )
	 SELECT  intFiscalYearId, intGLFiscalYearPeriodId , @intAssetId, @intBookId, @intBookDepreciationId
	 FROM tblGLFiscalYearPeriod WHERE @dtmDep BETWEEN dtmStartDate AND dtmEndDate
	SET @i = @i+1
END



