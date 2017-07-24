CREATE PROCEDURE uspMFGetInventoryByParentLot @strPeriod NVARCHAR(50) = NULL
AS
DECLARE @intLotSnapshotId INT
	,@dtmCurrentDate DATETIME
	,@dtmStartDate DATETIME

SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))

IF @strPeriod IS NULL
BEGIN
	SELECT @dtmStartDate = dtmStartDate
	FROM dbo.tblGLFiscalYearPeriod
	WHERE dtmEndDate IN (
			SELECT dtmStartDate - 1
			FROM dbo.tblGLFiscalYearPeriod
			WHERE @dtmCurrentDate BETWEEN dtmStartDate
					AND dtmEndDate
			)

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


DECLARE @tblMFMultipleLotCode TABLE (
	strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblLotQty NUMERIC(24, 10)
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblWOQty NUMERIC(24, 10)
	,dblWOTotalQty NUMERIC(24, 10)
	)
INSERT INTO @tblMFMultipleLotCode (
	strLotNumber
	,dblLotQty
	,strParentLotNumber
	,dblWOQty
	,dblWOTotalQty
	)
EXEC uspMFGetLotCodeByProduction

SELECT Item
	,[Item Desc]
	,[Lot No]
	,(IsNULl([Active], 0) + IsNULl([PR Hold], 0) + IsNULl([QA Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Bond Damaged], 0) + IsNULl([Damaged], 0)) AS [On Hand]
	,[UOM]
	,[Active]
	,[PR Hold]
	,[QA Hold]
	,[Quarantine]
	,[Bond]
	,[Bond Damaged]
	,[Damaged]
	,intUnitsPerCase AS [Units/Case]
	,dbo.fnRemoveTrailingZeroes(Ceiling((IsNULl([Active], 0) + IsNULl([PR Hold], 0) + IsNULl([QA Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Bond Damaged], 0) + IsNULl([Damaged], 0)) / intUnitsPerCase)) AS Pallets
FROM (
	SELECT I.strItemNo AS [Item]
		,I.strDescription AS [Item Desc]
		,ISNULL(MLC.strParentLotNumber, PL.strParentLotNumber) AS [Lot No]
		,Convert(DECIMAL(24, 0), ROUND(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU.intItemUOMId, ISNULL(MLC.dblLotQty, SD.dblQty)), IsNULL((
							SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU1.intItemUOMId, ISNULL(MLC.dblLotQty, SD.dblQty))
							FROM tblICItemUOM IU1
							JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
								AND IU1.intItemId = I.intItemId
								AND UM1.strUnitType <> 'Weight'
							), SD.dblQty)), 0)) AS [Quantity]
		,Isnull(I.strExternalGroup, IsNULL((
					SELECT TOP 1 UM1.strUnitMeasure
					FROM tblICItemUOM IU1
					JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
						AND IU1.intItemId = I.intItemId
						AND UM1.strUnitType <> 'Weight'
					), UM2.strUnitMeasure)) AS [UOM]
		,CASE 
			WHEN LS1.strSecondaryStatus = 'Bond'
				AND LS.strSecondaryStatus LIKE '%Damaged'
				THEN 'Bond Damaged'
			WHEN LS1.strSecondaryStatus = 'Bond'
				THEN LS1.strSecondaryStatus
			WHEN LS.strSecondaryStatus = 'On Hold'
				THEN 'PR Hold'
			WHEN LS.strSecondaryStatus LIKE '%Damaged'
				THEN 'Damaged'
			ELSE LS.strSecondaryStatus
			END AS [Lot Status]
		,(
			CASE 
				WHEN I.intUnitPerLayer * I.intLayerPerPallet = 0
					THEN NULL
				ELSE (I.intUnitPerLayer * I.intLayerPerPallet)
				END
			) AS intUnitsPerCase
	FROM dbo.tblICLot L
	JOIN tblMFLotSnapshotDetail SD ON SD.intLotId = L.intLotId
	AND SD.intLotSnapshotId = @intLotSnapshotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = SD.intParentLotId
		AND SD.intStorageLocationId <> 6
	JOIN dbo.tblICItem I ON I.intItemId = SD.intItemId
		AND I.strType = 'Finished Good'
	JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = SD.intLotStatusId
	LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = SD.intBondStatusId
	LEFT JOIN @tblMFMultipleLotCode MLC ON MLC.strLotNumber = L.strLotNumber
	JOIN dbo.tblICItemUOM IU2 ON IU2.intItemUOMId = SD.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
	) AS SourceTable
PIVOT(SUM(Quantity) FOR [Lot Status] IN (
			[Active]
			,[PR Hold]
			,[QA Hold]
			,[Quarantine]
			,[Bond]
			,[Bond Damaged]
			,[Damaged]
			)) AS PivotTable;
