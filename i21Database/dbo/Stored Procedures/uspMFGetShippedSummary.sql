CREATE PROCEDURE uspMFGetShippedSummary (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@strCustomerName NVARCHAR(50)
	)
AS
DECLARE @intOwnerId INT

IF @dtmFromDate IS NULL
	SELECT @dtmFromDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) --First day of previous month

IF @dtmToDate IS NULL
	SELECT @dtmToDate = DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1) --Last Day of previous month

SELECT @intOwnerId = E.intEntityId
FROM tblEMEntity E
JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId
	AND ET.strType = 'Customer'
WHERE strName = @strCustomerName
	AND strEntityNo <> ''

SELECT DT.strReferenceNumber AS [Reference Number]
	,DT.strShipmentNumber AS [Shipment Number]
	,DT.strName AS Customer
	,DT.strProNumber [Tracking No]
	,DT.strItemNo AS Item
	,DT.strDescription AS ItemDesc
	,DT.strParentLotNumber AS [Lot No]
	,SUM(DT.dblQuantityShipped) dblQuantityShipped
	,DT.strUnitMeasure AS UOM
	,DT.dtmCreated AS [Created Date]
	,IsNULL(DT.strCompletedDate,DT.dtmShipDate) AS [Completed Date]
	,DT.dtmShipDate AS [Ship Date]
FROM (
	SELECT InvS.strReferenceNumber
		,InvS.strShipmentNumber
		,E.strName
		,InvS.strProNumber
		,I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,InvSL.dblQuantityShipped dblQuantityShipped
		,UM.strUnitMeasure
		,InvS.dtmCreated
		,(
			SELECT MAX(IA.dtmDate)
			FROM tblMFInventoryAdjustment IA
			WHERE IA.intTransactionTypeId = 20
				AND IA.intSourceLotId = InvSL.intLotId
			) AS strCompletedDate
		,InvS.dtmShipDate
	FROM dbo.tblICInventoryShipment InvS
	JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
	JOIN dbo.tblICInventoryShipmentItemLot InvSL ON InvSL.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
	JOIN dbo.tblICLot L ON L.intLotId = InvSL.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICItem I ON I.intItemId = InvSI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	LEFT JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
	WHERE InvS.dtmShipDate BETWEEN @dtmFromDate
			AND @dtmToDate
				--AND IO1.intOwnerId = @intOwnerId
	) AS DT
GROUP BY DT.strReferenceNumber
	,DT.strShipmentNumber
	,DT.strName
	,DT.strProNumber
	,DT.strItemNo
	,DT.strDescription
	,DT.strParentLotNumber
	,DT.strUnitMeasure
	,DT.dtmCreated
	,DT.strCompletedDate
	,DT.dtmShipDate
