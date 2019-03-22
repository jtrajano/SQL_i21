SELECT WP.dtmProductionDate AS [Production Date]
	,I.strItemNo AS Item
	,I.strDescription AS Description
	,W.strWorkOrderNo AS [Job #]
	,PL.strParentLotNumber AS [Production Lot]
	,SUM(WP.dblPhysicalCount) AS [Quantity]
	,IUM.strUnitMeasure AS [Quantity UOM]
	,SUM(WP.dblQuantity) AS [Weight]
	,UM.strUnitMeasure AS [Weight UOM]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intPhysicalItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
WHERE WP.ysnProductionReversed = 0
	AND W.dtmPlannedDate = '2016-12-20'
GROUP BY WP.dtmProductionDate
	,I.strItemNo
	,I.strDescription
	,W.strWorkOrderNo
	,PL.strParentLotNumber
	,IUM.strUnitMeasure
	,UM.strUnitMeasure
GO

SELECT DISTINCT WI.dtmProductionDate [Dump Date]
	,I.strItemNo [Product]
	,I.strDescription [Product Description]
	,PL.strParentLotNumber AS [Production Lot]
	,MC.strCellName AS Line
	,W.strWorkOrderNo AS [Job #]
	,I1.strItemNo AS [WSI Item]
	,I1.strDescription [WSI Item Description]
	,IL.strLotNumber AS [Pallet Id]
	,IPL.strParentLotNumber AS [Lot #]
	,WI.dblIssuedQuantity AS [Quantity]
	,UM1.strUnitMeasure AS [Quantity UOM]
	,WI.dblQuantity AS [Weight]
	,UM.strUnitMeasure [Weight UOM]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = WI.intWorkOrderId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WI.intItemIssuedUOMId
JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICLot IL ON IL.intLotId = WI.intLotId
JOIN dbo.tblICParentLot IPL ON IPL.intParentLotId = IL.intParentLotId
JOIN dbo.tblICItem I1 ON I1.intItemId = IL.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = I1.intCategoryId
WHERE W.dtmPlannedDate = '2016-12-20'
	AND C.strCategoryCode = 'RM'
GO

SELECT DISTINCT WI.dtmProductionDate [Dump Date]
	,I.strItemNo [Product]
	,I.strDescription [Product Description]
	,(
		SELECT TOP 1 strParentLotNumber
		FROM dbo.tblMFWorkOrderProducedLot WP
		WHERE WP.intWorkOrderId = W.intWorkOrderId
		) AS [Production Lot]
	,MC.strCellName AS Line
	,W.strWorkOrderNo AS [Job #]
	,I1.strItemNo AS [WSI Item]
	,I1.strDescription [WSI Item Description]
	,IPL.strParentLotNumber AS [Lot #]
	,SUM(WI.dblIssuedQuantity) AS [Quantity]
	,UM1.strUnitMeasure AS [Quantity UOM]
	,SUM(WI.dblQuantity) AS [Weight]
	,UM.strUnitMeasure [Weight UOM]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WI.intItemIssuedUOMId
JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICLot IL ON IL.intLotId = WI.intLotId
JOIN dbo.tblICParentLot IPL ON IPL.intParentLotId = IL.intParentLotId
JOIN dbo.tblICItem I1 ON I1.intItemId = IL.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = I1.intCategoryId
WHERE W.dtmPlannedDate = '2016-12-20'
	AND C.strCategoryCode = 'RM'
GROUP BY WI.dtmProductionDate
	,I.strItemNo
	,I.strDescription
	,MC.strCellName
	,W.strWorkOrderNo
	,I1.strItemNo
	,I1.strDescription
	,IL.strLotNumber
	,IPL.strParentLotNumber
	,UM1.strUnitMeasure
	,UM.strUnitMeasure
	,W.intWorkOrderId
GO

SELECT DISTINCT W.dtmPlannedDate [Dump Date]
	,I.strItemNo [Product]
	,I.strDescription [Product Description]
	,(
		SELECT TOP 1 strParentLotNumber
		FROM dbo.tblMFWorkOrderProducedLot WP
		WHERE WP.intWorkOrderId = W.intWorkOrderId
		) AS [Production Lot]
	,MC.strCellName AS Line
	,W.strWorkOrderNo AS [Job #]
	,I1.strItemNo AS [WSI Item]
	,I1.strDescription [WSI Item Description]
	,SUM(WC.dblIssuedQuantity) + SUM(IsNULL(WC1.dblIssuedQuantity, 0)) AS [Total consumed]
	,SUM(WC.dblIssuedQuantity) AS [Consumed Quantity]
	,UM1.strUnitMeasure AS [Consumed Quantity UOM]
	,SUM(IsNULL(WC1.dblIssuedQuantity, 0)) AS [Damaged]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intWorkOrderId = W.intWorkOrderId
	AND intSequenceNo <> 9999
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WC.intItemIssuedUOMId
JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICItem I1 ON I1.intItemId = WC.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = I1.intCategoryId
LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC1 ON WC1.intWorkOrderId = W.intWorkOrderId
	AND WC1.intSequenceNo = 9999
	AND WC1.intItemId = WC.intItemId
WHERE W.dtmPlannedDate = '2016-12-20'
	AND C.strCategoryCode = 'PM'
GROUP BY W.dtmPlannedDate
	,I.strItemNo
	,I.strDescription
	,MC.strCellName
	,W.strWorkOrderNo
	,I1.strItemNo
	,I1.strDescription
	,UM1.strUnitMeasure
	,W.intWorkOrderId
	,WC.intItemId
GO

SELECT W.dtmPlannedDate AS [Production Date]
	,I.strItemNo AS Item
	,I.strDescription AS Description
	,W.strWorkOrderNo AS [Job #]
	,PL.strParentLotNumber AS [Production Lot]
	,SUM(WP.dblPhysicalCount * I.intInnerUnits) AS [Good produced Pouches]
	,IsNULL((
			SELECT SUM(WP.dblPhysicalCount)
			FROM tblMFWorkOrderProducedLot WP
			WHERE WP.intWorkOrderId = W.intWorkOrderId
				AND WP.intItemId <> W.intItemId
			), 0) [Total sweeps]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intPhysicalItemUOMId
WHERE WP.ysnProductionReversed = 0
	AND W.dtmPlannedDate = '2016-12-20'
GROUP BY W.dtmPlannedDate
	,W.intItemId
	,I.strItemNo
	,I.strDescription
	,W.strWorkOrderNo
	,PL.strParentLotNumber
	,W.intWorkOrderId
GO

--iGPS

GO
--Receiving Summary
DECLARE @dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intOwnerId INT

SELECT @dtmFromDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) --First day of previous month

SELECT @dtmToDate = DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1) --Last Day of previous month

SELECT @intOwnerId = intEntityId
FROM tblEMEntity
WHERE strName = 'Wholesome Sweeteners'

SELECT DT.strReceiptNumber
	,DT.strBillOfLading
	,ROW_NUMBER() OVER (
		PARTITION BY DT.strReceiptNumber ORDER BY DT.strReceiptNumber
			,DT.strItemNo
		) strLineNo
	,DT.strItemNo
	,DT.strDescription
	,DT.strVendorLotId
	,DT.strParentLotNumber
	,SUM(DT.dblQuantity) AS dblQuantity
	,DT.strUnitMeasure
	,DT.dtmReceiptDate
	,DT.strPutawayDate
	,DT.strCompletedDate
FROM (
	SELECT IR.strReceiptNumber
		,IR.strBillOfLading
		,I.strItemNo
		,I.strDescription
		,IRL.strVendorLotId
		,IRL.strParentLotNumber
		,IRL.dblQuantity
		,UM.strUnitMeasure
		,IR.dtmReceiptDate
		,(
			SELECT TOP 1 IA.dtmDate
			FROM tblMFInventoryAdjustment IA
			WHERE IA.intTransactionTypeId = 20
				AND IA.intSourceLotId = IRL.intLotId
			ORDER BY IA.dtmDate ASC
			) AS strPutawayDate
		,(
			SELECT MAX(IA.dtmDate)
			FROM tblMFInventoryAdjustment IA
			WHERE IA.intTransactionTypeId = 20
				AND IA.intSourceLotId = IRL.intLotId
			) AS strCompletedDate
	FROM dbo.tblICInventoryReceipt IR
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
	JOIN dbo.tblICInventoryReceiptItemLot IRL ON IRL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	JOIN dbo.tblICItem I ON I.intItemId = IRI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = IRL.intItemUnitMeasureId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = IRL.intLotId
	JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
	WHERE IR.dtmReceiptDate BETWEEN @dtmFromDate
			AND @dtmToDate
		AND IO1.intOwnerId = @intOwnerId
	) AS DT
GROUP BY DT.strReceiptNumber
	,DT.strBillOfLading
	,DT.strItemNo
	,DT.strDescription
	,DT.strVendorLotId
	,DT.strParentLotNumber
	,DT.strUnitMeasure
	,DT.dtmReceiptDate
	,DT.strPutawayDate
	,DT.strCompletedDate
GO

--Shipped Summary
DECLARE @dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intOwnerId INT

SELECT @intOwnerId = intEntityId
FROM tblEMEntity
WHERE strName = 'Wholesome Sweeteners'

SELECT @dtmFromDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) --First day of previous month

SELECT @dtmToDate = DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1) --Last Day of previous month

SELECT DT.strReferenceNumber
	,DT.strShipmentNumber
	,DT.strName
	,DT.strProNumber
	,DT.strItemNo
	,DT.strDescription
	,DT.strParentLotNumber
	,SUM(DT.dblQuantityShipped) dblQuantityShipped
	,DT.strUnitMeasure
	,DT.strCompletedDate
	,DT.dtmShipDate
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
	WHERE InvS.dtmShipDate BETWEEN @dtmFromDate
			AND @dtmToDate
		AND InvS.intEntityCustomerId = @intOwnerId
	) AS DT
GROUP BY DT.strReferenceNumber
	,DT.strShipmentNumber
	,DT.strName
	,DT.strProNumber
	,DT.strItemNo
	,DT.strDescription
	,DT.strParentLotNumber
	,DT.strUnitMeasure
	,DT.strCompletedDate
	,DT.dtmShipDate
GO

DECLARE @dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intOwnerId INT

SELECT @intOwnerId = intEntityId
FROM tblEMEntity
WHERE strName = 'Wholesome Sweeteners'

SELECT @dtmFromDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) --First day of previous month

SELECT @dtmToDate = DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1) --Last Day of previous month

SELECT E.strName AS strOwner
	,IT.strName AS strTransactionType
	,SL.strName AS strStorageLocation
	,L.strLotNumber AS strPalletId
	,I.strItemNo
	,PL.strParentLotNumber AS strLotId
	,IA.dblQty
	,IA.dtmBusinessDate AS dtmDate
	,US.strUserName
	,IA.strReason
	,IA.strNote
FROM tblMFInventoryAdjustment IA
JOIN dbo.tblICInventoryTransactionType IT ON IT.intTransactionTypeId = IA.intTransactionTypeId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = IA.intStorageLocationId
JOIN dbo.tblICLot L ON L.intLotId = IA.intSourceLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = IA.intItemId
LEFT JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = IA.intUserId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = IA.intSourceLotId
JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
JOIN dbo.tblEMEntity E ON E.intEntityId = IO1.intOwnerId
WHERE IT.intTransactionTypeId = 10
	AND IA.dtmBusinessDate BETWEEN @dtmFromDate
		AND @dtmToDate
	AND IO1.intOwnerId = @intOwnerId
GO

DECLARE @intOwnerId INT

SELECT @intOwnerId = intEntityId
FROM tblEMEntity
WHERE strName = 'Wholesome Sweeteners'

SELECT I.strItemNo
	,I.strDescription
	,PL.strParentLotNumber AS strLotId
	,strVendorLotNo
	,L.dblQty
	,UM.strUnitMeasure
	,SL.strName AS strStorageLocation
	,L.strLotNumber AS strPalletId
	,LS.strSecondaryStatus
FROM dbo.tblICLot L
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = I.intItemId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
WHERE dblQty > 0
	AND IO1.intOwnerId = @intOwnerId
GO

DECLARE @intOwnerId INT

SELECT @intOwnerId = intEntityId
FROM tblEMEntity
WHERE strName = 'Wholesome Sweeteners'

SELECT E.strName AS strOwner
	,I.strItemNo
	,I.strDescription
	,PL.strParentLotNumber AS strLotId
	,L.dtmDateCreated
	,strVendorLotNo
	,L.dtmManufacturedDate
	,L.dtmExpiryDate
	,L.strLotNumber AS strPalletId
	,CASE 
		WHEN L.intLotStatusId = 1
			THEN L.dblQty
		ELSE 0
		END AS dblActiveQty
	,CASE 
		WHEN L.intLotStatusId <> 1
			THEN L.dblQty
		ELSE 0
		END AS dblInactiveQty
	,UM.strUnitMeasure
	,SL.strName AS strStorageLocation
	,LS.strSecondaryStatus
	,L.dblWeight
FROM dbo.tblICLot L
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = I.intItemId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
JOIN dbo.tblEMEntity E ON E.intEntityId = IO1.intOwnerId
WHERE dblQty > 0
	AND IO1.intOwnerId = @intOwnerId
