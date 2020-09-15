CREATE VIEW [dbo].[vyuGRTransferClearing_FullDPtoDP]
AS
SELECT	--'1' AS TEST,
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
        ISNULL(receiptItem.dblOpenReceive, 0) --
		--ISNULL(CASE WHEN (SIR.dblTransactionUnits + ABS(SIR.dblShrinkage)) <= receiptItem.dblOpenReceive THEN receiptItem.dblOpenReceive ELSE (SIR.dblTransactionUnits + ABS(SIR.dblShrinkage)) END, 0) 
        * dbo.fnCalculateCostBetweenUOM(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId, receiptItem.dblUnitCost)
        * (
            CASE 
                WHEN receiptItem.ysnSubCurrency = 1 AND ISNULL(receipt.intSubCurrencyCents, 1) <> 0 THEN 1 / ISNULL(receipt.intSubCurrencyCents, 1) 
                ELSE 1 
            END 
        )
        , 2
    )
    +
    receiptItem.dblTax
    AS dblReceiptTotal
    ,ISNULL(receiptItem.dblOpenReceive, 0) AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(0 AS BIT) ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
	--,receiptItem.dblOpenReceive
	--,S.dblNetUnits
	--,S.dblShrinkage
	--,S.intInventoryReceiptId
	--,SIR.dblTransactionUnits
	--,TRANSFER_TRAN.dblTransferredUnits
	--,TOTAL.dblTotal
	--,CS_TO.strStorageTicketNumber
FROM tblICInventoryReceipt receipt 
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN (
	SELECT 
		intCustomerStorageId
		,intInventoryReceiptId
        ,intInventoryReceiptItemId
		,dblNetUnits
		,dblShrinkage
		,dblTransactionUnits
        ,ROW_NUMBER() OVER(PARTITION BY intInventoryReceiptId
                                 ORDER BY intStorageInventoryReceipt) AS rk
	FROM tblGRStorageInventoryReceipt
	WHERE ysnUnposted = 0
) S ON S.intInventoryReceiptId = receipt.intInventoryReceiptId AND S.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId AND S.rk = 1 --AND S.intInventoryReceiptId IS NOT NULL
INNER JOIN (
	tblGRStorageInventoryReceipt SIR --ONLY THOSE IRs WITH TRANSFER WILL BE PULLED
	INNER JOIN tblGRTransferStorageReference TSR 
		ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId 
	INNER JOIN tblGRTransferStorage TS 
		ON TS.intTransferStorageId = TSR.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRStorageType ST 
		ON ST.intStorageScheduleTypeId = CS_TO.intStorageTypeId
			AND ST.ysnDPOwnedType = 1
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			--AND CS_FROM.ysnTransferStorage = 0
	) ON SIR.intInventoryReceiptId = S.intInventoryReceiptId
		AND SIR.intInventoryReceiptItemId = S.intInventoryReceiptItemId
		AND SIR.ysnUnposted = 0
OUTER APPLY (
	SELECT ROUND(SUM(dblTransactionUnits + ABS(dblShrinkage)),2) AS dblTotal
		,intInventoryReceiptItemId
	FROM tblGRStorageInventoryReceipt
	WHERE ysnUnposted = 0
		AND intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
	GROUP BY intInventoryReceiptItemId
) TOTAL
OUTER APPLY (
	SELECT CASE WHEN ROUND((ABS(S.dblShrinkage / S.dblNetUnits) * SIR.dblTransactionUnits) + SIR.dblTransactionUnits,2) = receiptItem.dblOpenReceive
		OR TOTAL.dblTotal = receiptItem.dblOpenReceive THEN 1 ELSE 0 END AS isFullyTransferred
		,ROUND((ABS(S.dblShrinkage / S.dblNetUnits) * SIR.dblTransactionUnits) + SIR.dblTransactionUnits,2) AS dblTransferredUnits
		,S.intInventoryReceiptItemId
) TRANSFER_TRAN
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
	AND TRANSFER_TRAN.isFullyTransferred = 1
	AND ST.ysnDPOwnedType = 1
	--and receiptItem.intInventoryReceiptItemId = 153481
	--AND receipt.dtmReceiptDate >= '2020-09-09'
GO


