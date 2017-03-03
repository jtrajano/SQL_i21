CREATE PROCEDURE uspMFGetReceivingSummary (
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

SELECT DT.strReceiptNumber AS [Receipt Number]
	,DT.strBillOfLading AS [BOL]
	,ROW_NUMBER() OVER (
		PARTITION BY DT.strReceiptNumber ORDER BY DT.strReceiptNumber
			,DT.strItemNo
		) [Line No]
	,DT.strItemNo AS [Item No]
	,DT.strDescription AS [Item Desc]
	,DT.strVendorLotId [Vendor Lot No]
	,DT.strParentLotNumber AS [Lot No]
	,SUM(DT.dblQuantity) AS Quantity
	,DT.strUnitMeasure AS [UOM]
	,DT.dtmCreated AS [Created Date]
	,DT.dtmReceiptDate AS [Receipt Date]
	,IsNULL(DT.strPutawayDate,DT.dtmReceiptDate) AS [Putaway Date]
	,IsNULL(DT.strCompletedDate,DT.dtmReceiptDate) AS [Completed Date]
FROM (
	SELECT IR.strReceiptNumber
		,IR.strBillOfLading
		,I.strItemNo
		,I.strDescription
		,IRL.strVendorLotId
		,IRL.strParentLotNumber
		,IRL.dblQuantity
		,UM.strUnitMeasure
		,IR.dtmCreated
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
	LEFT JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
	WHERE IR.dtmReceiptDate BETWEEN @dtmFromDate
			AND @dtmToDate
				--AND IO1.intOwnerId = @intOwnerId
	) AS DT
GROUP BY DT.strReceiptNumber
	,DT.strBillOfLading
	,DT.strItemNo
	,DT.strDescription
	,DT.strVendorLotId
	,DT.strParentLotNumber
	,DT.strUnitMeasure
	,DT.dtmCreated
	,DT.dtmReceiptDate
	,DT.strPutawayDate
	,DT.strCompletedDate
