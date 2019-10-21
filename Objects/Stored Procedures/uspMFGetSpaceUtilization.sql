CREATE PROCEDURE uspMFGetSpaceUtilization @strPeriod NVARCHAR(50) = NULL
AS
DECLARE @intLotSnapshotId INT
	,@dtmCurrentDate DATETIME
	,@dtmStartDate DATETIME

SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))

IF @strPeriod IS NULL
BEGIN
	SELECT @dtmStartDate = dtmStartDate
	FROM dbo.tblGLFiscalYearPeriod
	WHERE @dtmCurrentDate BETWEEN dtmStartDate
					AND dtmEndDate

	SELECT @intLotSnapshotId = intLotSnapshotId
	FROM tblMFLotSnapshot
	WHERE dtmDate = @dtmStartDate
END
ELSE
BEGIN
	SELECT @dtmStartDate = dtmStartDate
	FROM dbo.tblGLFiscalYearPeriod
	WHERE strPeriod = @strPeriod

	SELECT @intLotSnapshotId = intLotSnapshotId
	FROM tblMFLotSnapshot
	WHERE dtmDate = @dtmStartDate
END
SELECT UT.strStorageUnitType
	,Count(*) AS NoOfLocations
	,SUM(IsNULL(NoOfUsedLocations, 0)) AS NoOfUsedLocations
	,SUM(IsNULL(strOpenLocations, 0)) AS strOpenLocations
	,Convert(DECIMAL(24, 0), (SUM(IsNULL(NoOfUsedLocations, 0)) / Convert(DECIMAL(24, 0), Count(*))) * 100) strPercentageUsed
FROM tblICStorageLocation SL
JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
LEFT JOIN (
	SELECT DISTINCT SL.intStorageLocationId
		,CASE 
			WHEN SD.intLotId IS NULL
				THEN 0
			ELSE 1
			END AS NoOfUsedLocations
		,CASE 
			WHEN SD.intLotId IS NULL
				THEN 1
			ELSE 0
			END AS strOpenLocations
	FROM tblICStorageLocation SL
	Left JOIN tblMFLotSnapshotDetail SD ON SD.intStorageLocationId = SL.intStorageLocationId
	AND SD.intLotSnapshotId = @intLotSnapshotId
	) L1 ON L1.intStorageLocationId = SL.intStorageLocationId
GROUP BY UT.strStorageUnitType
