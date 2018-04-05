CREATE PROCEDURE uspMFGetStockHistory (
	@dtmFromDate DATETIME = NULL
	,@dtmToDate DATETIME = NULL
	,@strCustomerName NVARCHAR(50) = ''
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

SELECT strItemNo
	,strDescription
	,strParentLotNumber
	,strVendor
	,strWarehouseRefNo
	,strVendorRefNo
	,dtmReceiptDate
	,strTranType
	,strUnitMeasure
	,dbo.fnRemoveTrailingZeroes(SUM(dblReceiptQty)) dblReceiptQty
	,dbo.fnRemoveTrailingZeroes(SUM(dblAdjustQty)) dblAdjustQty
	,dbo.fnRemoveTrailingZeroes(SUM(dblShipQty)) dblShipQty
FROM (
	SELECT I.strItemNo
		,I.strDescription
		,IRL.strParentLotNumber
		,E.strName AS strVendor
		,IR.strWarehouseRefNo
		,IR.strVendorRefNo
		,IR.dtmReceiptDate
		,'Receipts' AS strTranType
		,UM.strUnitMeasure
		,IRL.dblQuantity AS dblReceiptQty
		,0 AS dblAdjustQty
		,0 AS dblShipQty
	FROM dbo.tblICInventoryReceipt IR
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
	JOIN dbo.tblICInventoryReceiptItemLot IRL ON IRL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	JOIN dbo.tblICItem I ON I.intItemId = IRI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = IRL.intItemUnitMeasureId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblEMEntity E ON E.intEntityId = IR.intEntityVendorId
	JOIN dbo.tblICLot L on L.intLotId=IRL.intLotId
	JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = L.intItemOwnerId
	WHERE IR.dtmReceiptDate BETWEEN @dtmFromDate
			AND @dtmToDate
			AND IO1.intOwnerId = @intOwnerId
	
	UNION
	
	SELECT I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,E.strName AS strVendor
		,LI.strWarehouseRefNo AS strWarehouseRefNo
		,LI.strVendorRefNo AS strVendorRefNo
		,IA.dtmBusinessDate
		,'Adjustments' AS strTranType
		,(
			SELECT TOP 1 UM.strUnitMeasure
			FROM tblICItemUOM IU
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				AND IU.intItemId = I.intItemId
				AND UM.strUnitType <> 'Weight'
			)
		,0 AS dblReceiptQty
		,ROUND((
			SELECT TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(IA.intItemUOMId, IU.intItemUOMId, IA.dblQty)
			FROM tblICItemUOM IU
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				AND IU.intItemId = I.intItemId
				AND UM.strUnitType <> 'Weight'
			),0) AS dblAdjustQty
		,0 AS dblShipQty
	FROM tblMFInventoryAdjustment IA
	JOIN dbo.tblICLot L ON L.intLotId = IA.intSourceLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICItem I ON I.intItemId = IA.intItemId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = L.intEntityVendorId
	JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = L.intItemOwnerId
	WHERE IA.intTransactionTypeId = 10
		AND IA.dtmBusinessDate BETWEEN @dtmFromDate
			AND @dtmToDate
			AND IO1.intOwnerId = @intOwnerId
	
	UNION
	
	SELECT I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,E.strName
		,InvS.strReferenceNumber
		,(
			SELECT TOP 1 FV.strValue
			FROM tblSMTabRow TR
			JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
			JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
				AND LOWER(TD.strControlName) = 'customer po no'
			JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
			JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
				AND S.strNamespace = 'Inventory.view.InventoryShipment'
			WHERE T.intRecordId = InvS.intInventoryShipmentId
			) AS strCustomerPO
		,InvS.dtmShipDate
		,'Shipment' AS strTranType
		,UM.strUnitMeasure
		,0 AS dblReceiptQty
		,0 AS dblAdjustQty
		,InvSL.dblQuantityShipped AS dblShipQty
	FROM dbo.tblICInventoryShipment InvS
	JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
	JOIN dbo.tblICInventoryShipmentItemLot InvSL ON InvSL.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
	JOIN dbo.tblICLot L ON L.intLotId = InvSL.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICItem I ON I.intItemId = InvSI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
	JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = L.intItemOwnerId
	WHERE InvS.dtmShipDate BETWEEN @dtmFromDate
			AND @dtmToDate
			AND IO1.intOwnerId = @intOwnerId
	) AS DT
GROUP BY strItemNo
	,strDescription
	,strParentLotNumber
	,strVendor
	,strWarehouseRefNo
	,strVendorRefNo
	,dtmReceiptDate
	,strTranType
	,strUnitMeasure
ORDER BY DT.strItemNo
	,DT.strParentLotNumber
	,DT.dtmReceiptDate

