CREATE PROCEDURE uspMFGetInventoryByItem @strPeriod NVARCHAR(50) = NULL
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

DECLARE @intOwnerId INT

SELECT @intOwnerId = E.intEntityId
FROM tblEMEntity E
JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId
	AND ET.strType = 'Customer'
WHERE strName = @strCustomerName
	AND strEntityNo <> ''

IF @ysnIgnoreProdStageLocation = 1
BEGIN
	SELECT [Item No]
		,[Item Desc]
		,SUM([Quantity]) AS Quantity
		,[UOM]
		,SUM(Weight) AS Weight
		,[Lot Status]
		,strCategoryCode AS [Item Category]
	FROM (
		SELECT I.strItemNo AS [Item No]
			,I.strDescription AS [Item Desc]
			,Convert(DECIMAL(24, 0), ROUND(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU.intItemUOMId, SD.dblQty), IsNULL((
								SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU1.intItemUOMId, SD.dblQty)
								FROM tblICItemUOM IU1
								JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
									AND IU1.intItemId = I.intItemId
									AND UM1.strUnitType <> 'Weight'
								), L.dblQty)), 0)) AS [Quantity]
			,Isnull(I.strExternalGroup, IsNULL((
						SELECT TOP 1 UM1.strUnitMeasure
						FROM tblICItemUOM IU1
						JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
							AND IU1.intItemId = I.intItemId
							AND UM1.strUnitType <> 'Weight'
						), UM2.strUnitMeasure)) AS [UOM]
			,Convert(DECIMAL(24, 0), SD.dblWeight) AS Weight
			,CASE 
				WHEN LS1.strSecondaryStatus = 'Bond'
					AND LS.strSecondaryStatus LIKE '%Damaged'
					THEN 'Bond Damaged'
				WHEN LS1.strSecondaryStatus = 'Bond'
					THEN LS1.strSecondaryStatus
				WHEN LS.strSecondaryStatus LIKE '%Damaged'
					THEN 'Damaged'
				ELSE LS.strSecondaryStatus
				END AS [Lot Status]
			,C.strCategoryCode
		FROM dbo.tblICLot L
		JOIN tblMFLotSnapshotDetail SD ON SD.intLotId = L.intLotId
			AND SD.intLotSnapshotId = @intLotSnapshotId
		JOIN dbo.tblICItem I ON I.intItemId = SD.intItemId
		LEFT JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
		LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = SD.intLotStatusId
		LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = SD.intBondStatusId
		JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
		JOIN dbo.tblICItemUOM IU2 ON IU2.intItemUOMId = SD.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
		JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = L.intItemOwnerId
		WHERE L.intStorageLocationId NOT IN (
				@intProdStageLocationId
				,@intPMStageLocationId
				) AND IO1.intOwnerId = IsNULL(@intOwnerId,IO1.intOwnerId)
		) AS DT
	GROUP BY [Item No]
		,[Item Desc]
		,[UOM]
		,[Lot Status]
		,strCategoryCode
END
ELSE
BEGIN
	SELECT [Item No]
		,[Item Desc]
		,SUM([Quantity]) AS Quantity
		,[UOM]
		,SUM(Weight) AS Weight
		,[Lot Status]
		,strCategoryCode AS [Item Category]
	FROM (
		SELECT I.strItemNo AS [Item No]
			,I.strDescription AS [Item Desc]
			,Convert(DECIMAL(24, 0), ROUND(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU.intItemUOMId, SD.dblQty), IsNULL((
								SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(SD.intItemUOMId, IU1.intItemUOMId, SD.dblQty)
								FROM tblICItemUOM IU1
								JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
									AND IU1.intItemId = I.intItemId
									AND UM1.strUnitType <> 'Weight'
								), L.dblQty)), 0)) AS [Quantity]
			,Isnull(I.strExternalGroup, IsNULL((
						SELECT TOP 1 UM1.strUnitMeasure
						FROM tblICItemUOM IU1
						JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
							AND IU1.intItemId = I.intItemId
							AND UM1.strUnitType <> 'Weight'
						), UM2.strUnitMeasure)) AS [UOM]
			,Convert(DECIMAL(24, 0), SD.dblWeight) AS Weight
			,CASE 
				WHEN LS1.strSecondaryStatus = 'Bond'
					AND LS.strSecondaryStatus LIKE '%Damaged'
					THEN 'Bond Damaged'
				WHEN LS1.strSecondaryStatus = 'Bond'
					THEN LS1.strSecondaryStatus
				WHEN LS.strSecondaryStatus LIKE '%Damaged'
					THEN 'Damaged'
				ELSE LS.strSecondaryStatus
				END AS [Lot Status]
			,C.strCategoryCode
		FROM dbo.tblICLot L
		JOIN tblMFLotSnapshotDetail SD ON SD.intLotId = L.intLotId
			AND SD.intLotSnapshotId = @intLotSnapshotId
		JOIN dbo.tblICItem I ON I.intItemId = SD.intItemId
		LEFT JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
		LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = SD.intLotStatusId
		LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = SD.intBondStatusId
		JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
		JOIN dbo.tblICItemUOM IU2 ON IU2.intItemUOMId = SD.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
		JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = L.intItemOwnerId AND IO1.intOwnerId = IsNULL(@intOwnerId,IO1.intOwnerId)
		) AS DT
	GROUP BY [Item No]
		,[Item Desc]
		,[UOM]
		,[Lot Status]
		,strCategoryCode
END
