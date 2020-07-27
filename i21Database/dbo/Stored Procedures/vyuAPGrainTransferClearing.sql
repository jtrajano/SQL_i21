CREATE VIEW [dbo].[vyuAPGrainTransferClearing]
AS
/*START ====>>> ***DELIVERY SHEETS*** FOR DP TO OP*/
--Receipt item
SELECT	
    receipt.intEntityVendorId
    ,receipt.dtmReceiptDate AS dtmDate
    ,receipt.strReceiptNumber AS strTransactionNumber
    ,receipt.intInventoryReceiptId
    ,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,receiptItem.intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,receiptItem.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblTransferTotal
    ,0 AS dblTransferQty
    ,ROUND(
        ISNULL(receiptItem.dblOpenReceive, 0) 
        * dbo.fnCalculateCostBetweenUOM(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId, receiptItem.dblUnitCost)
        * (
            CASE 
                WHEN receiptItem.ysnSubCurrency = 1 AND ISNULL(receipt.intSubCurrencyCents, 1) <> 0 THEN 
                    1 / ISNULL(receipt.intSubCurrencyCents, 1) 
                ELSE 
                    1 
            END 
        )
        , 2
    ) 
    *
    (
        CASE
        WHEN receipt.strReceiptType = 'Inventory Return'
        THEN -1
        ELSE 1
        END
    )
    +
    receiptItem.dblTax
    AS dblReceiptTotal
    ,ISNULL(receiptItem.dblOpenReceive, 0)
    *
    (
        CASE
        WHEN receipt.strReceiptType = 'Inventory Return'
        THEN -1
        ELSE 1
        END
    )
    AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(0 AS BIT) ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblICInventoryReceipt receipt 
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblGRStorageInventoryReceipt SIR --ONLY THOSE IRs WITH TRANSFER WILL BE PULLED
	ON SIR.intInventoryReceiptId = receipt.intInventoryReceiptId
		AND SIR.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = receipt.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId)
LEFT JOIN vyuAPReceiptClearingGL APClearing
    ON APClearing.strTransactionId = receipt.strReceiptNumber
        AND APClearing.intItemId = receiptItem.intItemId
        AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
WHERE 
    receiptItem.dblUnitCost != 0
AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
AND receipt.strReceiptType != 'Transfer Order'
AND receiptItem.intOwnershipType != 2
AND receipt.ysnPosted = 1
--AND receipt.dtmReceiptDate >= '2020-07-24'

UNION ALL
--Transfer Storages
SELECT
    CS.intEntityId AS intEntityVendorId
    ,TSR.dtmProcessDate AS dtmDate
    ,IR.strReceiptNumber
    ,IR.intInventoryReceiptId
	,TSR.intTransferStorageId
    ,TS.strTransferStorageTicket
    ,SIR.intTransferStorageReferenceId
    ,SIR.intInventoryReceiptItemId
    ,IRI.intItemId
    ,IRI.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,ISNULL(CAST((SIR.dblTransactionUnits) * (IRI.dblUnitCost)  AS DECIMAL(18,2)),0) * 1 + IRI.dblTax AS dblTransferTotal  --Orig Calculation	
    ,ISNULL(SIR.dblTransactionUnits, 0)
    AS dblTransferQty
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
    ,IR.intLocationId
    ,CL.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblGRStorageInventoryReceipt SIR
INNER JOIN tblGRTransferStorageReference TSR
	ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSR.intTransferStorageId
INNER JOIN tblICInventoryReceiptItem IRI
	ON IRI.intInventoryReceiptItemId = SIR.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt IR
	ON IR.intInventoryReceiptId = SIR.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGLDetail GL
	ON GL.intTransactionId = TSR.intTransferStorageId
		AND GL.strTransactionType = 'Transfer Storage'
		AND GL.strDescription LIKE '%Item: %' --A/P CLEARING ACCOUNT - {Location} - Grain Item: {Item}, Qty: {Units}, Cost: {Cost}
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = IR.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(IRI.intWeightUOMId, IRI.intUnitMeasureId)
/*END ====>>> ***DELIVERY SHEETS*** FOR DP TO OP*/
UNION ALL
/*START ====>>> ***SCALE TICKETS*** FOR DP TO OP*/
SELECT	
    receipt.intEntityVendorId
    ,receipt.dtmReceiptDate AS dtmDate
    ,receipt.strReceiptNumber AS strTransactionNumber
    ,receipt.intInventoryReceiptId
    ,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,receiptItem.intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,receiptItem.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblTransferTotal
    ,0 AS dblTransferQty
    ,ROUND(
        ISNULL(receiptItem.dblOpenReceive, 0) 
        * dbo.fnCalculateCostBetweenUOM(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId, receiptItem.dblUnitCost)
        * (
            CASE 
                WHEN receiptItem.ysnSubCurrency = 1 AND ISNULL(receipt.intSubCurrencyCents, 1) <> 0 THEN 
                    1 / ISNULL(receipt.intSubCurrencyCents, 1) 
                ELSE 
                    1 
            END 
        )
        , 2
    ) 
    *
    (
        CASE
        WHEN receipt.strReceiptType = 'Inventory Return'
        THEN -1
        ELSE 1
        END
    )
    +
    receiptItem.dblTax
    AS dblReceiptTotal
    ,ISNULL(receiptItem.dblOpenReceive, 0)
    *
    (
        CASE
        WHEN receipt.strReceiptType = 'Inventory Return'
        THEN -1
        ELSE 1
        END
    )
    AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblICInventoryReceipt receipt 
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN (
	SELECT intInventoryReceiptId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS.ysnTransferStorage = 0
			AND CS.intTicketId IS NOT NULL
) transfers
	ON transfers.intInventoryReceiptId = receipt.intInventoryReceiptId
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = receipt.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId)
LEFT JOIN vyuAPReceiptClearingGL APClearing
    ON APClearing.strTransactionId = receipt.strReceiptNumber
        AND APClearing.intItemId = receiptItem.intItemId
        AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
WHERE 
    receiptItem.dblUnitCost != 0
AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
AND receipt.strReceiptType != 'Transfer Order'
AND receiptItem.intOwnershipType != 2
AND receipt.ysnPosted = 1

UNION ALL
--Transfer Storages
SELECT
    CS.intEntityId AS intEntityVendorId
    ,TSR.dtmProcessDate AS dtmDate
    ,IR.strReceiptNumber
    ,IR.intInventoryReceiptId
	,TSR.intTransferStorageId
    ,TS.strTransferStorageTicket
    ,TSR.intTransferStorageReferenceId
    ,IRI.intInventoryReceiptItemId
    ,IRI.intItemId
    ,IRI.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,ISNULL(CAST((TSR.dblUnitQty) * (IRI.dblUnitCost)  AS DECIMAL(18,2)),0) * 1 + IRI.dblTax AS dblTransferTotal  --Orig Calculation	
    ,ISNULL(TSR.dblUnitQty, 0)
    AS dblTransferQty
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
    ,IR.intLocationId
    ,CL.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblGRTransferStorageReference TSR
INNER JOIN tblGRStorageHistory SH
	ON SH.intCustomerStorageId = TSR.intSourceCustomerStorageId
		AND SH.strType = 'From Scale'
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSR.intTransferStorageId
INNER JOIN tblICInventoryReceipt IR
	ON IR.intInventoryReceiptId = SH.intInventoryReceiptId
INNER JOIN tblICInventoryReceiptItem IRI
	ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGLDetail GL
	ON GL.intTransactionId = TSR.intTransferStorageId
		AND GL.strTransactionType = 'Transfer Storage'
		AND GL.strDescription LIKE '%Item: %' --A/P CLEARING ACCOUNT - {Location} - Grain Item: {Item}, Qty: {Units}, Cost: {Cost}
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = IR.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(IRI.intWeightUOMId, IRI.intUnitMeasureId)
/*END ====>>> ***SCALE TICKETS*** FOR DP TO OP*/