CREATE VIEW [dbo].[vyuGRTransferClearing]
AS
/*START ====>>> ***DELIVERY SHEETS*** FOR DP TO OP/DP*/
--SELECT * FROM (
--Receipt item
SELECT	

	'1.1'  collate Latin1_General_CI_AS AS strMark,
    CASE WHEN isFullyTransferred = 1 AND ST.ysnDPOwnedType = 1 THEN CS_TO.intEntityId ELSE receipt.intEntityVendorId END AS intEntityVendorId
    ,CASE WHEN isFullyTransferred = 1 AND ST.ysnDPOwnedType = 1 THEN TS.dtmTransferStorageDate ELSE receipt.dtmReceiptDate END AS dtmDate
    ,CASE WHEN isFullyTransferred = 1 AND ST.ysnDPOwnedType = 1 THEN TS.strTransferStorageTicket ELSE receipt.strReceiptNumber END AS strTransactionNumber
    ,CASE WHEN isFullyTransferred = 1 AND ST.ysnDPOwnedType = 1 THEN TS.intTransferStorageId ELSE receipt.intInventoryReceiptId END AS intInventoryReceiptId
    ,TS.intTransferStorageId AS intTransferStorageId
    ,TS.strTransferStorageTicket AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,CASE WHEN isFullyTransferred = 1 AND ST.ysnDPOwnedType = 1 THEN SIR.intTransferStorageReferenceId ELSE receiptItem.intInventoryReceiptItemId END AS intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,receiptItem.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblTransferTotal
    ,0 AS dblTransferQty
    ,ROUND(
        ISNULL(
			CASE 
				WHEN isnull(CheckingForMultipleTransfer.intDataCount,0) > 1 
					then 
					CheckingForMultipleTransfer.dblUnits
					--(SIR.dblTransactionUnits + ((SIR.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage)))			
					-- The purpose of this checking is to know if an IR is split into different transfer. When that happens, we should use the units and not the whole IR unit
				WHEN isFullyTransferred = 1 AND ST.ysnDPOwnedType = 1 THEN TRANSFER_TRAN.dblTransferredUnits ELSE receiptItem.dblOpenReceive END
		, 0) --
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
    ,ISNULL(CASE 
			WHEN isnull(CheckingForMultipleTransfer.intDataCount,0) > 1 
					then 
					CheckingForMultipleTransfer.dblUnits
			WHEN isFullyTransferred = 1 AND ST.ysnDPOwnedType = 1 THEN TRANSFER_TRAN.dblTransferredUnits ELSE receiptItem.dblOpenReceive END, 0) AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(0 AS BIT) ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
	--,'a'=receiptItem.dblOpenReceive
	--,'b'=S.dblNetUnits
	--,'c'=S.dblShrinkage
	--,'d'=S.intInventoryReceiptId
	--,'e'=SIR.dblTransactionUnits
	--,'f'=TRANSFER_TRAN.dblTransferredUnits
	--,'g'=TOTAL.dblTotal
	--,'h'=TRANSFER_TRAN.isFullyTransferred
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
			AND CS_TO.intCustomerStorageId NOT IN (	SELECT intSourceCustomerStorageId FROM tblGRTransferStorageReference except 
													SELECT intToCustomerStorageId FROM tblGRTransferStorageReference StorageReference
															JOIN tblGRCustomerStorage SourceStorage
																on StorageReference.intSourceCustomerStorageId = SourceStorage.intCustomerStorageId
															join tblGRStorageType SourceStorageType
																on SourceStorageType.intStorageScheduleTypeId = SourceStorage.intStorageTypeId
	
															join tblGRCustomerStorage DestinationStorage
																on StorageReference.intToCustomerStorageId = DestinationStorage.intCustomerStorageId
															join tblGRStorageType DestinationStorageType
																on DestinationStorageType.intStorageScheduleTypeId = DestinationStorage.intStorageTypeId		
														where (SourceStorageType.ysnDPOwnedType = 1 and DestinationStorageType.strOwnedPhysicalStock = 'Customer')
			
													) --DO NOT INCLUDE IF THE TRANSFER STORAGE HAS ALSO BEEN TRANSFERRED But inclue DP to OS transfer
	INNER JOIN tblGRStorageType ST 
		ON ST.intStorageScheduleTypeId = CS_TO.intStorageTypeId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 0
	) ON SIR.intInventoryReceiptId = S.intInventoryReceiptId
		AND SIR.intInventoryReceiptItemId = S.intInventoryReceiptItemId
		AND SIR.ysnUnposted = 0

--Mon modification
outer apply (
	select count(*) as intDataCount
			,intInventoryReceiptId 
			,(SIR.dblTransactionUnits + ((SIR.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage)))	dblUnits--this should be the same unit as the one used in the computation
		from tblGRStorageInventoryReceipt StorageReceipt 
			where 
				StorageReceipt.intInventoryReceiptId = receipt.intInventoryReceiptId
				--and StorageReceipt.intTransferStorageReferenceId is not null
				and ysnUnposted = 0
		group by intInventoryReceiptId
		having count(intStorageInventoryReceipt) > 1
) CheckingForMultipleTransfer
	
--Mon modification
OUTER APPLY (
	SELECT ROUND(SUM(dblTransactionUnits + ABS(dblShrinkage)),2) AS dblTotal
		,intInventoryReceiptItemId
	FROM tblGRStorageInventoryReceipt
	WHERE ysnUnposted = 0
		AND intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
	GROUP BY intInventoryReceiptItemId
) TOTAL
OUTER APPLY (
	SELECT isFullyTransferred = CASE WHEN ABS(dblTransferredUnits - receiptItem.dblOpenReceive) <= 0.01 OR dblTransferredUnits = receiptItem.dblOpenReceive OR TOTAL.dblTotal = receiptItem.dblOpenReceive THEN 1 ELSE 0 END
		,dblTransferredUnits
		,S.intInventoryReceiptItemId
	FROM (
		SELECT 
		--CASE WHEN ROUND((ABS(S.dblShrinkage / S.dblNetUnits) * SIR.dblTransactionUnits) + SIR.dblTransactionUnits,2) = receiptItem.dblOpenReceive
		--	OR TOTAL.dblTotal = receiptItem.dblOpenReceive THEN 1 ELSE 0 END AS isFullyTransferred
			ROUND((ABS(S.dblShrinkage / S.dblNetUnits) * SIR.dblTransactionUnits) + SIR.dblTransactionUnits,2) AS dblTransferredUnits
			,S.intInventoryReceiptItemId
	) A
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

UNION ALL
--Transfer Storages
SELECT 
	'2.2'  collate Latin1_General_CI_AS AS TEST,
    --IR.intEntityVendorId AS intEntityVendorId
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
    ,ISNULL(CAST(A.dblTotalTransfer * (IRI.dblUnitCost)  AS DECIMAL(18,2)),0) * 1 AS dblTransferTotal  --Orig Calculation	
    ,ROUND(A.dblTotalTransfer,2) AS dblTransferQty
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
    ,IR.intLocationId
    ,CL.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
	--,SIR.dblTransactionUnits
	--,S.dblNetUnits
	--,S.dblShrinkage
	--,IRI.dblUnitCost
FROM tblGRStorageInventoryReceipt SIR
INNER JOIN tblGRTransferStorageReference TSR
	ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRCustomerStorage CS_FROM
	ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
		AND CS_FROM.ysnTransferStorage = 0
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSR.intTransferStorageId
INNER JOIN tblICInventoryReceiptItem IRI
	ON IRI.intInventoryReceiptItemId = SIR.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt IR
	ON IR.intInventoryReceiptId = SIR.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN (
	SELECT DISTINCT intAccountId, intTransactionId FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strTransactionType = 'Transfer Storage' AND strDescription LIKE '%Item: %'
) GL ON GL.intTransactionId = TSR.intTransferStorageId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
INNER JOIN (
	SELECT 
		intCustomerStorageId
		,intInventoryReceiptId
        ,intInventoryReceiptItemId
		,dblNetUnits
		,dblShrinkage
        ,ROW_NUMBER() OVER(PARTITION BY intInventoryReceiptId
                                 ORDER BY intStorageInventoryReceipt) AS rk
	FROM tblGRStorageInventoryReceipt
	WHERE ysnUnposted = 0
) S ON S.intInventoryReceiptId = SIR.intInventoryReceiptId AND S.intInventoryReceiptItemId = SIR.intInventoryReceiptItemId AND S.rk = 1
OUTER APPLY (
	SELECT S.intInventoryReceiptItemId
		,CASE WHEN ABS(dblTransferredUnits - IRI.dblOpenReceive) <= 0.01 THEN IRI.dblOpenReceive ELSE dblTransferredUnits END dblTotalTransfer
	FROM (
		SELECT (SIR.dblTransactionUnits + ((SIR.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage))) AS dblTransferredUnits
	) e
) A
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(IRI.intWeightUOMId, IRI.intUnitMeasureId)
WHERE SIR.ysnUnposted = 0

/*END ====>>> ***DELIVERY SHEETS*** FOR DP TO OP*/
UNION ALL
/*START ====>>> ***SCALE TICKETS*** FOR DP TO OP*/
SELECT DISTINCT	
	'3'  collate Latin1_General_CI_AS AS TEST,
    CASE WHEN ST_FROM.ysnDPOwnedType = 0 OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1 AND CS.dblOpenBalance > 0) THEN receipt.intEntityVendorId ELSE CS_TO.intEntityId END AS intEntityVendorId
    ,CASE WHEN ST_FROM.ysnDPOwnedType = 0 OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1 AND CS.dblOpenBalance > 0) THEN receipt.dtmReceiptDate ELSE TSR.dtmProcessDate END AS dtmDate
    ,CASE WHEN ST_FROM.ysnDPOwnedType = 0 OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1 AND CS.dblOpenBalance > 0) THEN receipt.strReceiptNumber ELSE TS.strTransferStorageTicket END AS strTransactionNumber
    ,CASE WHEN ST_FROM.ysnDPOwnedType = 0 OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1 AND CS.dblOpenBalance > 0) THEN receipt.intInventoryReceiptId ELSE TS.intTransferStorageId END AS intInventoryReceiptId
    ,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,CASE WHEN ST_FROM.ysnDPOwnedType = 0 OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1 AND CS.dblOpenBalance > 0) THEN receiptItem.intInventoryReceiptItemId ELSE TSR.intTransferStorageReferenceId END AS intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,receiptItem.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblTransferTotal
    ,0 AS dblTransferQty
    ,ROUND(
        ISNULL(CASE WHEN (CS.dblOpenBalance = 0 AND ST_FROM.ysnDPOwnedType = 1) THEN CS_TO.dblOriginalBalance ELSE receiptItem.dblOpenReceive END, 0) 
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
    +
    receiptItem.dblTax
    AS dblReceiptTotal
    ,ISNULL(CASE WHEN (CS.dblOpenBalance = 0 AND ST_FROM.ysnDPOwnedType = 1) THEN CS_TO.dblOriginalBalance ELSE receiptItem.dblOpenReceive END, 0)
    AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
	--,transfers.dblOriginalBalance
FROM tblICInventoryReceipt receipt 
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN (
	tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRTransferStorage TS
		ON TS.intTransferStorageId = TSR.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS.ysnTransferStorage = 0
			AND CS.intTicketId IS NOT NULL
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = CS.intStorageTypeId
)
	ON SH.intInventoryReceiptId = receipt.intInventoryReceiptId
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
AND (
    (ST_TO.ysnDPOwnedType = 0 AND ST_FROM.ysnDPOwnedType = 1) --DP to OS
	OR (ST_TO.ysnDPOwnedType = 1 AND ST_FROM.ysnDPOwnedType = 0) --OS to DP
)
UNION ALL
--Transfer Storages
SELECT 
	'4' collate Latin1_General_CI_AS  AS TEST,
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
    ,ISNULL(TSR.dblUnitQty, 0) AS dblTransferQty
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
	ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
INNER JOIN tblGRCustomerStorage CS_TO
	ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRStorageType ST_TO
	ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSR.intTransferStorageId
INNER JOIN tblICInventoryReceipt IR
	ON IR.intInventoryReceiptId = SH.intInventoryReceiptId
INNER JOIN tblICInventoryReceiptItem IRI
	ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
--INNER JOIN tblGLDetail GL
--	ON GL.intTransactionId = TSR.intTransferStorageId
--		AND GL.strTransactionType = 'Transfer Storage'
--		AND GL.strDescription LIKE '%Item: %' --A/P CLEARING ACCOUNT - {Location} - Grain Item: {Item}, Qty: {Units}, Cost: {Cost}
INNER JOIN (
	SELECT DISTINCT intAccountId, intTransactionId FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strTransactionType = 'Transfer Storage' AND strDescription LIKE '%Item: %'
) GL ON GL.intTransactionId = TSR.intTransferStorageId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(IRI.intWeightUOMId, IRI.intUnitMeasureId)
WHERE (ST_TO.ysnDPOwnedType = 0 AND ST.ysnDPOwnedType = 1) --DP to OS
		OR (ST_TO.ysnDPOwnedType = 1 AND ST.ysnDPOwnedType = 0) --OS to DP
/*END ====>>> ***SCALE TICKETS*** FOR DP TO OP*/
UNION ALL
/*START ====>>>  ***DS/SC*** FOR OP TO DP*/
--Transfer Storages >> OS to DP >> there will be an OPEN CLEARING in the new transfer storage
SELECT 

	'5'  collate Latin1_General_CI_AS AS TEST,
    CS.intEntityId AS intEntityVendorId
    ,TSR.dtmProcessDate AS dtmDate
    ,TS.strTransferStorageTicket AS strReceiptNumber--IR.strReceiptNumber
    ,TS.intTransferStorageId AS intInventoryReceiptId--IR.intInventoryReceiptId
	,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,TSR.intTransferStorageReferenceId AS intInventoryReceiptItemId--IRI.intInventoryReceiptItemId
    ,CS.intItemId
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblTransferTotal  --Orig Calculation	
    ,0 AS dblTransferQty
    ,ISNULL(CAST((TSR.dblUnitQty) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1 AS dblReceiptTotal
    ,ISNULL(TSR.dblUnitQty, 0) AS dblReceiptQty
    ,CS.intCompanyLocationId
    ,CL.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblGRTransferStorageReference TSR
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		AND ST.ysnDPOwnedType = 1
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSR.intTransferStorageId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
--INNER JOIN tblGLDetail GL
--	ON GL.intTransactionId = TSR.intTransferStorageId
--		AND GL.strTransactionType = 'Transfer Storage'
--		AND GL.strDescription LIKE '%Item: %' --A/P CLEARING ACCOUNT - {Location} - Grain Item: {Item}, Qty: {Units}, Cost: {Cost}
INNER JOIN (
	SELECT DISTINCT intAccountId, intTransactionId FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strTransactionType = 'Transfer Storage' AND strDescription LIKE '%Item: %'
) GL ON GL.intTransactionId = TSR.intTransferStorageId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
-- WHERE NOT EXISTS (SELECT intSourceCustomerStorageId FROM tblGRTransferStorageReference WHERE intSourceCustomerStorageId = CS.intCustomerStorageId)
UNION ALL
-- Bill for Transfer Settlement
SELECT 
	
	'5.99'  collate Latin1_General_CI_AS AS TEST,
    CS.intEntityId AS intEntityVendorId
    ,TSR.dtmProcessDate AS dtmDate
    ,TS.strTransferStorageTicket AS strReceiptNumber--IR.strReceiptNumber
    ,TS.intTransferStorageId AS intInventoryReceiptId--IR.intInventoryReceiptId
	,Bill.intBillId AS intTransferStorageId
    ,Bill.strBillId AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,TSR.intTransferStorageReferenceId AS intInventoryReceiptItemId--IRI.intInventoryReceiptItemId
    ,CS.intItemId
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    --,ISNULL(CAST((TSR.dblUnitQty) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1 AS dblTransferTotal  --Orig Calculation	
    ,ISNULL(CAST((BillDetail.dblQtyReceived) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1 AS dblTransferTotal  --Orig Calculation	
	--
    ,BillDetail.dblQtyReceived AS dblTransferQty
    ,0 -- ISNULL(CAST((TSR.dblUnitQty) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1 AS dblReceiptTotal
    ,0 -- ISNULL(TSR.dblUnitQty, 0) AS dblReceiptQty
    ,CS.intCompanyLocationId
    ,CL.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblGRTransferStorageReference TSR
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		AND ST.ysnDPOwnedType = 1
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSR.intTransferStorageId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
join tblAPBillDetail BillDetail
	on BillDetail.intCustomerStorageId =  CS.intCustomerStorageId
		and BillDetail.intItemId = TS.intItemId
join tblAPBill Bill
    on Bill.intBillId = BillDetail.intBillId
--INNER JOIN tblGLDetail GL
--	ON GL.intTransactionId = TSR.intTransferStorageId
--		AND GL.strTransactionType = 'Transfer Storage'
--		AND GL.strDescription LIKE '%Item: %' --A/P CLEARING ACCOUNT - {Location} - Grain Item: {Item}, Qty: {Units}, Cost: {Cost}
INNER JOIN (
	SELECT DISTINCT intAccountId, intTransactionId FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strTransactionType = 'Transfer Storage' AND strDescription LIKE '%Item: %'
) GL ON GL.intTransactionId = TSR.intTransferStorageId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
Where Bill.ysnPosted = 1


----
UNION ALL
SELECT 
	
	'5.98'   + '(' + TSR_TS.strTransferStorageTicket + ')' collate Latin1_General_CI_AS AS TEST,
    CS.intEntityId AS intEntityVendorId
    ,TSR.dtmProcessDate AS dtmDate
    ,TS.strTransferStorageTicket AS strReceiptNumber--IR.strReceiptNumber
    ,TS.intTransferStorageId AS intInventoryReceiptId--IR.intInventoryReceiptId
	,Bill.intBillId AS intTransferStorageId
    ,Bill.strBillId AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,TSR.intTransferStorageReferenceId AS intInventoryReceiptItemId--IRI.intInventoryReceiptItemId
    ,CS.intItemId
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    --,ISNULL(CAST((TSR.dblUnitQty) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1 AS dblTransferTotal  --Orig Calculation	
    ,ISNULL(CAST((BillDetail.dblQtyReceived) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1 AS dblTransferTotal  --Orig Calculation	
	--
    ,BillDetail.dblQtyReceived AS dblTransferQty
    ,0 -- ISNULL(CAST((TSR.dblUnitQty) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1 AS dblReceiptTotal
    ,0 -- ISNULL(TSR.dblUnitQty, 0) AS dblReceiptQty
    ,CS.intCompanyLocationId
    ,CL.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblGRTransferStorageReference TSR
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		AND ST.ysnDPOwnedType = 1

inner join tblGRTransferStorageReference TSR_TSR
	on TSR.intToCustomerStorageId = TSR_TSR.intSourceCustomerStorageId
inner join tblGRCustomerStorage TSR_CS
	on TSR_TSR.intToCustomerStorageId = TSR_CS.intCustomerStorageId

INNER JOIN tblGRStorageType TSR_ST
	ON TSR_ST.intStorageScheduleTypeId = TSR_CS.intStorageTypeId
		AND TSR_ST.ysnDPOwnedType = 1


INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = TSR.intTransferStorageId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = TSR_CS.intCompanyLocationId


INNER JOIN tblGRTransferStorage TSR_TS
	ON TSR_TS.intTransferStorageId = TSR_TSR.intTransferStorageId






join tblAPBillDetail BillDetail
	on BillDetail.intCustomerStorageId =  TSR_CS.intCustomerStorageId
		and BillDetail.intItemId = TS.intItemId
join tblAPBill Bill
    on Bill.intBillId = BillDetail.intBillId
--INNER JOIN tblGLDetail GL
--	ON GL.intTransactionId = TSR.intTransferStorageId
--		AND GL.strTransactionType = 'Transfer Storage'
--		AND GL.strDescription LIKE '%Item: %' --A/P CLEARING ACCOUNT - {Location} - Grain Item: {Item}, Qty: {Units}, Cost: {Cost}
INNER JOIN (
	SELECT DISTINCT intAccountId, intTransactionId FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strTransactionType = 'Transfer Storage' AND strDescription LIKE '%Item: %'
) GL ON GL.intTransactionId = TSR.intTransferStorageId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
Where Bill.ysnPosted = 1
----


UNION ALL
--Transfer Storages from above select statement
SELECT DISTINCT 

	'6'  collate Latin1_General_CI_AS AS TEST,
    CS_TO.intEntityId AS intEntityVendorId
    ,TSR.dtmProcessDate AS dtmDate
    ,SH.strTransferTicket
    ,SH.intTransferStorageId
	,TSR.intTransferStorageId
    ,TS_TO.strTransferStorageTicket
    ,TSR.intTransferStorageReferenceId
    ,TSR_FROM.intTransferStorageReferenceId
    ,CS_TO.intItemId
    ,CS_TO.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    --,ISNULL(CAST((TSR.dblUnitQty) * (REPLACE(SUBSTRING(GL.strDescription, CHARINDEX('Cost: ', GL.strDescription), LEN(GL.strDescription) -1),'Cost: ',''))  AS DECIMAL(38,15)),0) * 1 AS dblTransferTotal  --Orig Calculation	
	
    ,ISNULL(CAST((TSR.dblUnitQty) * case when ST_FROM.ysnDPOwnedType = 1 and ST_TO.ysnDPOwnedType = 0 then CS_FROM.dblBasis + CS_FROM.dblSettlementPrice else (REPLACE(SUBSTRING(GL.strDescription, CHARINDEX('Cost: ', GL.strDescription), LEN(GL.strDescription) -1),'Cost: ','')) end AS DECIMAL(38,15) ),0) * 1 AS dblTransferTotal  --Orig Calculation	
    ,ISNULL(TSR.dblUnitQty, 0) AS dblTransferQty
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
    ,CS_TO.intCompanyLocationId
    ,CL_TO.strLocationName
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblGRTransferStorageReference TSR
INNER JOIN tblGRCustomerStorage CS_FROM
	ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
		AND CS_FROM.ysnTransferStorage = 1
INNER JOIN tblGRStorageHistory SH
	ON SH.intCustomerStorageId = CS_FROM.intCustomerStorageId
		AND SH.strType = 'From Transfer'
INNER JOIN tblGRTransferStorageReference TSR_FROM
	ON TSR_FROM.intTransferStorageId = SH.intTransferStorageId
		AND TSR_FROM.intToCustomerStorageId = SH.intCustomerStorageId
INNER JOIN tblGRStorageType ST_FROM
	ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
		AND ST_FROM.ysnDPOwnedType = 1
INNER JOIN tblSMCompanyLocation CL_FROM
    ON CL_FROM.intCompanyLocationId = CS_FROM.intCompanyLocationId
INNER JOIN tblGRCustomerStorage CS_TO
	ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRStorageType ST_TO
	ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
		AND ST_TO.ysnDPOwnedType = 0
INNER JOIN tblSMCompanyLocation CL_TO
    ON CL_TO.intCompanyLocationId = CS_TO.intCompanyLocationId
INNER JOIN tblGRTransferStorage TS_TO
	ON TS_TO.intTransferStorageId = TSR.intTransferStorageId
OUTER APPLY (
	SELECT ROUND(SUM(ABS(dblShrinkage)),2) AS dblTotal
		,intInventoryReceiptItemId
	FROM tblGRStorageInventoryReceipt A
	INNER JOIN tblGRCustomerStorage B
		ON B.intCustomerStorageId = A.intCustomerStorageId
			AND B.strStorageTicketNumber = CS_FROM.strStorageTicketNumber
			AND B.ysnTransferStorage = 0
	WHERE ysnUnposted = 0
		--AND intTransferStorageReferenceId = TSR.intTransferStorageReferenceId
	GROUP BY intInventoryReceiptItemId
) TOTAL
LEFT JOIN (
	SELECT DISTINCT intAccountId, intTransactionId, strDescription FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strTransactionType = 'Transfer Storage' AND strDescription LIKE '%Item: %'
) GL ON GL.intTransactionId = TSR.intTransferStorageId
LEFT JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS_TO.intItemUOMId
WHERE APClearing.intAccountId IS NOT NULL
/*END ====>>> ***DS/SC*** FOR OP TO DP*/
--) A 
--WHERE dtmDate between '2021-03-03' and '2021-03-04'
--AND strTransactionNumber LIKE 'TRA%'