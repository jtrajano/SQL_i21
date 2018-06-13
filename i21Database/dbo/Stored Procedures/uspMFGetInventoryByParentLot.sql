CREATE PROCEDURE uspMFGetInventoryByParentLot @strPeriod NVARCHAR(50) = NULL
	,@ysnIgnoreProdStageLocation BIT = 0
	,@strCustomerName NVARCHAR(50)=''
AS
DECLARE @intLotSnapshotId INT
	,@dtmCurrentDate DATETIME
	,@dtmStartDate DATETIME
	,@intPMStageLocationId INT
	,@intProdStageLocationId INT

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
	SELECT @dtmStartDate = dtmEndDate + 1
	FROM dbo.tblGLFiscalYearPeriod
	WHERE strPeriod = @strPeriod

	SELECT @dtmStartDate = Convert(DATETIME, Convert(CHAR, @dtmStartDate, 101))

	SELECT @intLotSnapshotId = intLotSnapshotId
	FROM tblMFLotSnapshot
	WHERE dtmDate = @dtmStartDate
END

SELECT @intProdStageLocationId = strAttributeValue
FROM tblMFManufacturingProcessAttribute
WHERE intAttributeId = 75
	AND strAttributeValue <> ''

SELECT @intPMStageLocationId = strAttributeValue
FROM tblMFManufacturingProcessAttribute
WHERE intAttributeId = 90
	AND strAttributeValue <> ''

DECLARE @tblMFMultipleLotCode TABLE (
	intLotId int
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblLotQty NUMERIC(24, 10)
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblWOQty NUMERIC(24, 10)
	,dblWOTotalQty NUMERIC(24, 10)
	)

DECLARE @intOwnerId INT

SELECT @intOwnerId = E.intEntityId
FROM tblEMEntity E
JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId
	AND ET.strType = 'Customer'
WHERE strName = @strCustomerName
	AND strEntityNo <> ''

INSERT INTO @tblMFMultipleLotCode (
	intLotId
	,strLotNumber
	,dblLotQty
	,strParentLotNumber
	,dblWOQty
	,dblWOTotalQty
	)
EXEC uspMFGetLotCodeByProduction @intLotSnapshotId

IF @ysnIgnoreProdStageLocation = 1
BEGIN
	SELECT Item
		,[Item Desc]
		,[Lot No]
		,(IsNULl([Active], 0) + IsNULl([PR Hold], 0) + IsNULl([QA Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Bond Damaged], 0) + IsNULl([Damaged], 0) + IsNULl([Other Status], 0)) AS [On Hand]
		,[UOM]
		,[Active]
		,[PR Hold]
		,[QA Hold]
		,[Quarantine]
		,[Bond]
		,[Bond Damaged]
		,[Damaged]
		,[Other Status]
		,intUnitsPerCase AS [Units/Case]
		,dbo.fnRemoveTrailingZeroes(Ceiling((IsNULl([Active], 0) + IsNULl([PR Hold], 0) + IsNULl([QA Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Bond Damaged], 0) + IsNULl([Damaged], 0) + IsNULl([Other Status], 0)) / intUnitsPerCase)) AS Pallets
	FROM (
		SELECT I.strItemNo AS [Item]
			,I.strDescription AS [Item Desc]
			,ISNULL(MLC.strParentLotNumber, PL.strParentLotNumber) AS [Lot No]
			,Convert(DECIMAL(24, 0), ROUND(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU.intItemUOMId, ISNULL(MLC.dblWOQty, SD.dblQty)), IsNULL((
								SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU1.intItemUOMId, ISNULL(MLC.dblWOQty, SD.dblQty))
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
				WHEN LS.strSecondaryStatus = 'PR HOLD'
					THEN 'PR Hold'

				WHEN LS.strSecondaryStatus LIKE '%Damaged'
					THEN 'Damaged'
				WHEN LS.strSecondaryStatus = 'Active'
					THEN 'Active'
				WHEN LS.strSecondaryStatus = 'Quarantine'
					THEN LS.strSecondaryStatus
				WHEN LS.strSecondaryStatus = 'QA Hold'
					THEN LS.strSecondaryStatus
				ELSE 'Other Status'
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
		JOIN dbo.tblICItem I ON I.intItemId = SD.intItemId
		LEFT JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
		LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = SD.intLotStatusId
		LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = SD.intBondStatusId
		LEFT JOIN @tblMFMultipleLotCode MLC ON MLC.intLotId = L.intLotId
		JOIN dbo.tblICItemUOM IU2 ON IU2.intItemUOMId = SD.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
		JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = L.intItemOwnerId
		WHERE L.intStorageLocationId NOT IN (
			@intProdStageLocationId
			,@intPMStageLocationId
			) AND IO1.intOwnerId = @intOwnerId
		) AS SourceTable
	PIVOT(SUM(Quantity) FOR [Lot Status] IN (
				[Active]
				,[PR Hold]
				,[QA Hold]
				,[Quarantine]
				,[Bond]
				,[Bond Damaged]
				,[Damaged]
				,[Other Status]
				)) AS PivotTable;
END
ELSE
BEGIN
	SELECT Item
		,[Item Desc]
		,[Lot No]
		,(IsNULl([Active], 0) + IsNULl([PR Hold], 0) + IsNULl([QA Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Bond Damaged], 0) + IsNULl([Damaged], 0) + IsNULl([Other Status], 0)) AS [On Hand]
		,[UOM]
		,[Active]
		,[PR Hold]
		,[QA Hold]
		,[Quarantine]
		,[Bond]
		,[Bond Damaged]
		,[Damaged]
		,[Other Status]
		,intUnitsPerCase AS [Units/Case]
		,dbo.fnRemoveTrailingZeroes(Ceiling((IsNULl([Active], 0) + IsNULl([PR Hold], 0) + IsNULl([QA Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Bond Damaged], 0) + IsNULl([Damaged], 0) + IsNULl([Other Status], 0)) / intUnitsPerCase)) AS Pallets
	FROM (
		SELECT I.strItemNo AS [Item]
			,I.strDescription AS [Item Desc]
			,ISNULL(MLC.strParentLotNumber, PL.strParentLotNumber) AS [Lot No]
			,Convert(DECIMAL(24, 0), ROUND(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU.intItemUOMId, ISNULL(MLC.dblWOQty, SD.dblQty)), IsNULL((
								SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU1.intItemUOMId, ISNULL(MLC.dblWOQty, SD.dblQty))
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
				WHEN LS.strSecondaryStatus = 'PR HOLD'
					THEN 'PR Hold'
				WHEN LS.strSecondaryStatus LIKE '%Damaged'
					THEN 'Damaged'
				WHEN LS.strSecondaryStatus = 'Active'
					THEN 'Active'
				WHEN LS.strSecondaryStatus = 'Quarantine'
					THEN LS.strSecondaryStatus
				WHEN LS.strSecondaryStatus = 'QA Hold'
					THEN LS.strSecondaryStatus
				ELSE 'Other Status'
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
		JOIN dbo.tblICItem I ON I.intItemId = SD.intItemId
		LEFT JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
		LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = SD.intLotStatusId
		LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = SD.intBondStatusId
		LEFT JOIN @tblMFMultipleLotCode MLC ON MLC.intLotId = L.intLotId
		JOIN dbo.tblICItemUOM IU2 ON IU2.intItemUOMId = SD.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
		JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = L.intItemOwnerId AND IO1.intOwnerId = @intOwnerId
		) AS SourceTable
	PIVOT(SUM(Quantity) FOR [Lot Status] IN (
				[Active]
				,[PR Hold]
				,[QA Hold]
				,[Quarantine]
				,[Bond]
				,[Bond Damaged]
				,[Damaged]
				,[Other Status]
				)) AS PivotTable;
END
