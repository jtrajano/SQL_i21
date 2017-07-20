CREATE PROCEDURE uspMFGetInventoryByItem
AS
DECLARE @intOwnerId INT
	,@dtmToDate DATETIME
	,@strCustomerName NVARCHAR(50)

IF @dtmToDate IS NULL
	SELECT @dtmToDate = DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1) + 1 --Last Day of previous month

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
		,Convert(DECIMAL(24, 0), ROUND(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, IU.intItemUOMId, L.dblQty), IsNULL((
							SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, IU1.intItemUOMId, L.dblQty)
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
		,Convert(DECIMAL(24, 0), L.dblWeight) AS Weight
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
		,C.strCategoryCode
	FROM dbo.tblICLot L
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		AND L.intStorageLocationId <> 6
	JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = LI.intBondStatusId
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	JOIN dbo.tblICItemUOM IU2 ON IU2.intItemUOMId = L.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
	WHERE dblQty > 0
		AND L.dtmDateCreated < @dtmToDate
	) AS DT
GROUP BY [Item No]
	,[Item Desc]
	,[UOM]
	,[Lot Status]
	,strCategoryCode
