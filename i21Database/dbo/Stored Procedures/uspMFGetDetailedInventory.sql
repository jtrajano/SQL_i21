CREATE PROCEDURE uspMFGetDetailedInventory
AS
DECLARE @intOwnerId INT
	,@dtmToDate DATETIME
	,@strCustomerName NVARCHAR(50)

IF @dtmToDate IS NULL
	SELECT @dtmToDate = DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1) + 1 --Last Day of previous month

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

SELECT I.strItemNo AS [Item No]
	,I.strDescription AS [Item Desc]
	,ISNULL(MLC.strParentLotNumber, PL.strParentLotNumber) AS [Lot No]
	,L.dtmDateCreated AS [Created Date]
	,strVendorLotNo AS [Vendor Lot No]
	,L.dtmManufacturedDate AS [Manufactured Date]
	,L.dtmExpiryDate AS [Expiry Date]
	,L.strLotNumber AS [Pallet No]
	,Convert(DECIMAL(24, 0), ROUND(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, IU.intItemUOMId, ISNULL(MLC.dblLotQty, L.dblQty)), IsNULL((
						SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, IU1.intItemUOMId, ISNULL(MLC.dblLotQty, L.dblQty))
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
	,SL.strName AS [Storage Location]
	,CASE 
		WHEN LS1.strSecondaryStatus = 'Bond'
			AND LS.strSecondaryStatus LIKE '%Damaged'
			THEN 'Bond Damaged'
		WHEN LS1.strSecondaryStatus = 'Bond'
			THEN LS1.strSecondaryStatus
		WHEN LS.strSecondaryStatus LIKE '%Damaged'
			THEN 'Damaged'
		WHEN LS.strSecondaryStatus = 'On Hold'
			THEN 'PR Hold'
		ELSE LS.strSecondaryStatus
		END AS [Lot Status]
	,Convert(DECIMAL(24, 0), L.dblWeight) AS Weight
FROM dbo.tblICLot L
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	AND L.intStorageLocationId <> 6
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
	AND UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = LI.intBondStatusId
LEFT JOIN @tblMFMultipleLotCode MLC ON MLC.strLotNumber = L.strLotNumber
JOIN dbo.tblICItemUOM IU2 ON IU2.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
WHERE dblQty > 0
	AND L.dtmDateCreated < @dtmToDate
