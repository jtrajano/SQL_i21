CREATE PROCEDURE uspMFGetInventoryByParentLot AS
SELECT Item
	,[Item Desc]
	,[Lot No]
	,(IsNULl([Active], 0) + IsNULl([On Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Damaged], 0)) AS [On Hand]
	,[UOM]
	,[Active]
	,[On Hold]
	,[Quarantine]
	,[Bond]
	,[Damaged]
	,intUnitsPerCase AS [Units/Case]
	,dbo.fnRemoveTrailingZeroes(Ceiling((IsNULl([Active], 0) + IsNULl([On Hold], 0) + IsNULl([Quarantine], 0) + IsNULl([Bond], 0) + IsNULl([Damaged], 0)) / intUnitsPerCase)) AS Pallets
FROM (
	SELECT I.strItemNo AS [Item]
		,I.strDescription AS [Item Desc]
		,PL.strParentLotNumber AS [Lot No]
		,Convert(decimal(24,0),ROUND(IsNULL((
			SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, IU.intItemUOMId, L.dblQty)
			FROM tblICItemUOM IU
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				AND IU.intItemId = I.intItemId
				AND UM.strUnitType <> 'Weight'
			),L.dblQty),0)) AS [Quantity]
		,IsNULL((
			SELECT TOP 1 UM.strUnitMeasure
			FROM tblICItemUOM IU
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				AND IU.intItemId = I.intItemId
				AND UM.strUnitType <> 'Weight'
			),UM1.strUnitMeasure) AS [UOM]
		,CASE 
			WHEN LS1.strSecondaryStatus = 'Bond'
				THEN LS1.strSecondaryStatus
			WHEN LS.strSecondaryStatus LIKE '%Damaged'
				THEN 'Damaged'
			WHEN LS.strPrimaryStatus = 'On Hold'
				THEN LS.strPrimaryStatus
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
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = LI.intBondStatusId
	WHERE dblQty > 0
	) AS SourceTable
PIVOT(SUM(Quantity) FOR [Lot Status] IN (
			[Active]
			,[On Hold]
			,[Quarantine]
			,[Bond]
			,[Damaged]
			)) AS PivotTable;
