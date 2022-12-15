CREATE VIEW [dbo].[vyuGRTransferClearing]
AS
/*START ====>>> ***DELIVERY SHEETS*** FOR DP TO OP/DP*/
--SELECT * FROM (
--Receipt item
SELECT	

	'1.1'  collate Latin1_General_CI_AS AS strMark,
    CASE WHEN ( isFullyTransferred = 1  OR CS_TO.dblOpenBalance = 0) AND ST.ysnDPOwnedType = 1 and 1 = 0 THEN CS_TO.intEntityId ELSE receipt.intEntityVendorId END AS intEntityVendorId
    ,CASE WHEN ( isFullyTransferred = 1 OR CS_TO.dblOpenBalance = 0) AND ST.ysnDPOwnedType = 1 and 1 = 0 THEN TS.dtmTransferStorageDate ELSE receipt.dtmReceiptDate END AS dtmDate
    ,CASE WHEN ( isFullyTransferred = 1 OR CS_TO.dblOpenBalance = 0) AND ST.ysnDPOwnedType = 1 and 1 = 0 THEN TS.strTransferStorageTicket ELSE receipt.strReceiptNumber END AS strTransactionNumber
    ,CASE WHEN ( isFullyTransferred = 1 OR CS_TO.dblOpenBalance = 0) AND ST.ysnDPOwnedType = 1 and 1 = 0 THEN TS.intTransferStorageId ELSE receipt.intInventoryReceiptId END AS intInventoryReceiptId
    ,null AS intTransferStorageId
    ,'' AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,CASE WHEN ( isFullyTransferred = 1 OR CS_TO.dblOpenBalance = 0)  and 1 = 0 THEN SIR.intTransferStorageReferenceId ELSE receiptItem.intInventoryReceiptItemId END AS intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,receiptItem.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblTransferTotal
    ,0 AS dblTransferQty
    ,ROUND(
        (
			ISNULL(
				CASE 
					WHEN isnull(CheckingForMultipleTransfer.intDataCount,0) > 1 
						then 
						CheckingForMultipleTransfer.dblUnits * 1
						--(SIR.dblTransactionUnits + ((SIR.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage)))			
						-- The purpose of this checking is to know if an IR is split into different transfer. When that happens, we should use the units and not the whole IR unit
					WHEN ( isFullyTransferred = 1 OR CS_TO.dblOpenBalance = 0) AND ST.ysnDPOwnedType = 1  and 1 = 0 THEN 
						TRANSFER_TRAN.dblTransferredUnits * 1
					ELSE receiptItem.dblOpenReceive - isnull(StorageRunningQuantity.dblQty, 0) END
			, 0) --
					
		)
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
					CheckingForMultipleTransfer.dblUnits * 1
			WHEN ( isFullyTransferred = 1 OR CS_TO.dblOpenBalance = 0) AND ST.ysnDPOwnedType = 1  and 1 = 0 THEN 
					TRANSFER_TRAN.dblTransferredUnits 
					* 1 
			ELSE receiptItem.dblOpenReceive - isnull(StorageRunningQuantity.dblQty, 0) END, 0) 
				
	AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(0 AS BIT) ysnAllowVoucher
    ,gl.intAccountId as intAccountId
    ,gl.strAccountId as strAccountId
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
-- LEFT JOIN vyuAPReceiptClearingGL APClearing
--     ON APClearing.strTransactionId = receipt.strReceiptNumber
--         AND APClearing.intItemId = receiptItem.intItemId
--         AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    INNER JOIN tblICInventoryTransaction it
        ON it.intTransactionId = receipt.intInventoryReceiptId
        AND it.strTransactionId = receipt.strReceiptNumber
        AND gl.intJournalLineNo = it.intInventoryTransactionId
        AND it.ysnIsUnposted = 0
    WHERE receipt.strReceiptNumber = gl.strTransactionId      
    AND receipt.intInventoryReceiptId = gl.intTransactionId
    AND (gl.dblCredit != 0 OR gl.dblDebit != 0)   
) gl



outer apply (

	select top 1 
		dblReceiptRunningUnits  as dblQty
from tblGRStorageInventoryReceipt 
	where intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId 
	 and intInventoryReceiptId = receiptItem.intInventoryReceiptId 
	 and ysnUnposted = 0
	order by intStorageInventoryReceipt desc

) StorageRunningQuantity

--left join (
--	select sum(dblComputedShrinkPerIR) as dblComputedShrink, intInventoryReceiptItemId, 1 as ysnFlag
--		from tblSCDeliverySheetShrinkReceiptDistribution
--            where intInventoryReceiptItemId is not null
--	group by intInventoryReceiptItemId

--) Shrek
--	on Shrek.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId

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
    ,TS.dtmTransferStorageDate AS dtmDate
    ,IR.strReceiptNumber
    ,IR.intInventoryReceiptId
	,TSR.intTransferStorageId
    ,TS.strTransferStorageTicket
    ,SIR.intTransferStorageReferenceId
    ,SIR.intInventoryReceiptItemId
    ,IRI.intItemId
    ,IRI.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,ISNULL(CAST((A.dblTotalTransfer) * (IRI.dblUnitCost)  AS DECIMAL(18,2)),0) * 1 AS dblTransferTotal  --Orig Calculation	
    ,ROUND((A.dblTotalTransfer),2) AS dblTransferQty -- - isnull(Shrek.dblComputedShrink, 0)
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
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = TS.strTransferStorageTicket
    AND gl.intTransactionId = TSR.intTransferStorageId
    AND gl.strCode = 'IC'
) APClearing
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

--left join (
--	select sum(dblComputedShrinkPerIR) as dblComputedShrink, intInventoryReceiptItemId, 1 as ysnFlag
--		from tblSCDeliverySheetShrinkReceiptDistribution
--            where intInventoryReceiptItemId is not null
--	group by intInventoryReceiptItemId

--) Shrek
--	on Shrek.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId


WHERE SIR.ysnUnposted = 0
AND APClearing.intAccountId IS NOT NULL

/*END ====>>> ***DELIVERY SHEETS*** FOR DP TO OP*/
UNION ALL
/*START ====>>> ***SCALE TICKETS*** FOR DP TO OP*/
SELECT	
	'3'  collate Latin1_General_CI_AS AS TEST,
    receipt.intEntityVendorId AS intEntityVendorId
    ,receipt.dtmReceiptDate AS dtmDate
    ,receipt.strReceiptNumber AS strTransactionNumber
    ,receipt.intInventoryReceiptId AS intInventoryReceiptId
    ,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,receiptItem.intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,receiptItem.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblTransferTotal
    ,0 AS dblTransferQty
    ,ROUND((ISNULL(receiptItem.dblOpenReceive, 0))
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
    ,ISNULL(receiptItem.dblOpenReceive, 0) AS dblReceiptQty
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
	OR (ST_TO.ysnDPOwnedType = 1 AND ST_FROM.ysnDPOwnedType = 1) --DP to DP
)
UNION ALL
--Transfer Storages
SELECT 
	'4' collate Latin1_General_CI_AS  AS TEST,
    CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate
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
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = TS.strTransferStorageTicket
    AND gl.intTransactionId = TSR.intTransferStorageId
    AND gl.strCode = 'IC'
) APClearing
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(IRI.intWeightUOMId, IRI.intUnitMeasureId)
WHERE ((ST_TO.ysnDPOwnedType = 0 AND ST.ysnDPOwnedType = 1) --DP to OS
		OR (ST_TO.ysnDPOwnedType = 1 AND ST.ysnDPOwnedType = 1)) --DP to DP
        AND APClearing.intAccountId IS NOT NULL
/*END ====>>> ***SCALE TICKETS*** FOR DP TO OP*/
UNION ALL
/*START ====>>>  ***DS/SC*** FOR OP TO DP*/
--Transfer Storages >> OS to DP >> there will be an OPEN CLEARING in the new transfer storage
SELECT 

	'5'  collate Latin1_General_CI_AS AS TEST,
    CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate
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
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = TS.strTransferStorageTicket
    AND gl.intTransactionId = TSR.intTransferStorageId
    AND gl.strCode = 'IC'
) APClearing
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE APClearing.intAccountId IS NOT NULL
	
-- WHERE NOT EXISTS (SELECT intSourceCustomerStorageId FROM tblGRTransferStorageReference WHERE intSourceCustomerStorageId = CS.intCustomerStorageId)
UNION ALL
-- Bill for Transfer Settlement
SELECT 
	
	'5.99'  collate Latin1_General_CI_AS AS TEST,
    CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate
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
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = TS.strTransferStorageTicket
    AND gl.intTransactionId = TSR.intTransferStorageId
    AND gl.strCode = 'IC'
) APClearing
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
Where Bill.ysnPosted = 1
AND APClearing.intAccountId IS NOT NULL

-- Voucher for IR (DP)
UNION ALL
SELECT DISTINCT '5.97' AS TEST,
    bill.intEntityVendorId      
    ,bill.dtmDate AS dtmDate      
    ,receipt.strReceiptNumber      
    ,receipt.intInventoryReceiptId      
    ,bill.intBillId      
    ,bill.strBillId      
    ,NULL AS intTransferStorageReferenceId
    ,billDetail.intInventoryReceiptItemId      
    ,billDetail.intItemId      
    ,billDetail.intUnitOfMeasureId AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,ROUND(ISNULL(CAST((billDetail.dblQtyReceived) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1, 2) AS dblTransferTotal  --Orig Calculation	    
    ,billDetail.dblQtyReceived AS dblTransferQty   
    ,0 AS dblReceiptChargeTotal
    ,0 AS dblReceiptChargeQty 
    ,receipt.intLocationId      
    ,compLoc.strLocationName      
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblAPBill bill      
INNER JOIN tblAPBillDetail billDetail      
    ON bill.intBillId = billDetail.intBillId    
INNER JOIN tblICInventoryReceiptItem receiptItem
    ON receiptItem.intInventoryReceiptItemId  = billDetail.intInventoryReceiptItemId
    AND billDetail.intItemId = receiptItem.intItemId
INNER JOIN tblICInventoryReceipt receipt
    ON receipt.intInventoryReceiptId  = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc      
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblGRStorageHistory SH
    ON SH.intInventoryReceiptId = receipt.intInventoryReceiptId
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = SH.intCustomerStorageId
    AND CS.ysnTransferStorage = 0
    AND CS.intTicketId IS NOT NULL
INNER JOIN tblGRSettleStorageBillDetail SSBD
    ON SSBD.intBillId = bill.intBillId
INNER JOIN tblGRSettleStorage SS
    ON SS.intSettleStorageId = SSBD.intSettleStorageId
INNER JOIN tblGRSettleStorageTicket SST
    ON SST.intSettleStorageId = SS.intSettleStorageId
    AND CS.intCustomerStorageId = SST.intCustomerStorageId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = billDetail.intUnitOfMeasureId
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = receipt.strReceiptNumber
    AND gl.intTransactionId = receipt.intInventoryReceiptId
    AND gl.strCode = 'IC'
) APClearing
WHERE       
    billDetail.intInventoryReceiptItemId IS NOT NULL
AND EXISTS (
    SELECT TOP 1 1
    FROM tblGRTransferStorageReference TSR
    WHERE TSR.intSourceCustomerStorageId = CS.intCustomerStorageId
)
-- AND receiptCharge.ysnInventoryCost = 0
AND bill.ysnPosted = 1
AND APClearing.intAccountId IS NOT NULL

-- Voucher for Transfer Storage - DP(From IR) to DP
UNION ALL
SELECT DISTINCT '5.96' AS TEST,
    bill.intEntityVendorId      
    ,bill.dtmDate AS dtmDate      
    ,TS.strTransferStorageTicket   
    ,TS.intTransferStorageId  
    ,bill.intBillId      
    ,bill.strBillId      
    ,NULL    
    ,TSR.intTransferStorageReferenceId
    ,billDetail.intItemId      
    ,billDetail.intUnitOfMeasureId AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,ROUND(ISNULL(CAST((billDetail.dblQtyReceived) * (CS_TO.dblBasis + CS_TO.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1, 2) AS dblTransferTotal  --Orig Calculation	    
    ,billDetail.dblQtyReceived AS dblTransferQty
    ,0 AS dblReceiptChargeTotal
    ,0 AS dblReceiptChargeQty 
    ,receipt.intLocationId      
    ,compLoc.strLocationName      
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblAPBill bill      
INNER JOIN tblAPBillDetail billDetail      
    ON bill.intBillId = billDetail.intBillId    
INNER JOIN tblICInventoryReceiptItem receiptItem
    ON receiptItem.intInventoryReceiptItemId  = billDetail.intInventoryReceiptItemId
    AND billDetail.intItemId = receiptItem.intItemId
INNER JOIN tblICInventoryReceipt receipt
    ON receipt.intInventoryReceiptId  = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc      
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblGRStorageHistory SH
    ON SH.intInventoryReceiptId = receipt.intInventoryReceiptId
INNER JOIN tblGRCustomerStorage CS_FROM
    ON CS_FROM.intCustomerStorageId = SH.intCustomerStorageId
    AND CS_FROM.ysnTransferStorage = 0
    AND CS_FROM.intTicketId IS NOT NULL
INNER JOIN tblGRTransferStorageReference TSR
    ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
INNER JOIN tblGRTransferStorage TS
    ON TSR.intTransferStorageId = TS.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS_TO
    ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
INNER JOIN tblGRSettleStorageBillDetail SSBD
    ON SSBD.intBillId = bill.intBillId
INNER JOIN tblGRSettleStorage SS
    ON SS.intSettleStorageId = SSBD.intSettleStorageId
INNER JOIN tblGRSettleStorageTicket SST
    ON SST.intSettleStorageId = SS.intSettleStorageId
    AND CS_TO.intCustomerStorageId = SST.intCustomerStorageId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = billDetail.intUnitOfMeasureId
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = TS.strTransferStorageTicket
    AND gl.intTransactionId = TSR.intTransferStorageId
    AND gl.strCode = 'IC'
) APClearing
WHERE       
    billDetail.intInventoryReceiptItemId IS NOT NULL
-- AND EXISTS (
--     SELECT TOP 1 1
--     FROM tblGRTransferStorageReference TSR
--     WHERE TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
-- )
-- AND receiptCharge.ysnInventoryCost = 0
AND bill.ysnPosted = 1
AND APClearing.intAccountId IS NOT NULL

-- Voucher for IR (DP)
UNION ALL
SELECT DISTINCT '5.97' AS TEST,
    bill.intEntityVendorId      
    ,bill.dtmDate AS dtmDate      
    ,receipt.strReceiptNumber      
    ,receipt.intInventoryReceiptId      
    ,bill.intBillId      
    ,bill.strBillId      
    ,NULL AS intTransferStorageReferenceId
    ,billDetail.intInventoryReceiptItemId      
    ,billDetail.intItemId      
    ,billDetail.intUnitOfMeasureId AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,ROUND(ISNULL(CAST((billDetail.dblQtyReceived) * (CS.dblBasis + CS.dblSettlementPrice)  AS DECIMAL(18,2)),0) * 1, 2) AS dblTransferTotal  --Orig Calculation	    
    ,billDetail.dblQtyReceived AS dblTransferQty   
    ,0 AS dblReceiptChargeTotal
    ,0 AS dblReceiptChargeQty 
    ,receipt.intLocationId      
    ,compLoc.strLocationName      
    ,0
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblAPBill bill      
INNER JOIN tblAPBillDetail billDetail      
    ON bill.intBillId = billDetail.intBillId    
INNER JOIN tblICInventoryReceiptItem receiptItem
    ON receiptItem.intInventoryReceiptItemId  = billDetail.intInventoryReceiptItemId
    AND billDetail.intItemId = receiptItem.intItemId
INNER JOIN tblICInventoryReceipt receipt
    ON receipt.intInventoryReceiptId  = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc      
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblGRStorageHistory SH
    ON SH.intInventoryReceiptId = receipt.intInventoryReceiptId
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = SH.intCustomerStorageId
    AND CS.ysnTransferStorage = 0
    AND CS.intTicketId IS NOT NULL
INNER JOIN tblGRSettleStorageBillDetail SSBD
    ON SSBD.intBillId = bill.intBillId
INNER JOIN tblGRSettleStorage SS
    ON SS.intSettleStorageId = SSBD.intSettleStorageId
INNER JOIN tblGRSettleStorageTicket SST
    ON SST.intSettleStorageId = SS.intSettleStorageId
    AND CS.intCustomerStorageId = SST.intCustomerStorageId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = billDetail.intUnitOfMeasureId
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = receipt.strReceiptNumber
    AND gl.intTransactionId = receipt.intInventoryReceiptId
    AND gl.strCode = 'IC'
) APClearing
WHERE       
    billDetail.intInventoryReceiptItemId IS NOT NULL
AND EXISTS (
    SELECT TOP 1 1
    FROM tblGRTransferStorageReference TSR
    WHERE TSR.intSourceCustomerStorageId = CS.intCustomerStorageId
)
-- AND receiptCharge.ysnInventoryCost = 0
AND bill.ysnPosted = 1
AND APClearing.intAccountId IS NOT NULL

UNION ALL
--Transfer Storages from above select statement
SELECT DISTINCT 

    '6' AS TEST,
    CS_FROM.intEntityId AS intEntityVendorId
    ,TS_TO.dtmTransferStorageDate AS dtmDate
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
    ,GL.intAccountId
	,GL.strAccountId
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
		-- AND ST_TO.ysnDPOwnedType = 0
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
OUTER APPLY (
    SELECT TOP 1 gl.intAccountId, gla.strAccountId, gl.strDescription
    FROM tblGLDetail gl
    INNER JOIN vyuGLAccountDetail gla
        ON gl.intAccountId = gla.intAccountId
        AND gla.intAccountCategoryId = 45
    WHERE gl.strTransactionId = TS_TO.strTransferStorageTicket
    AND gl.intTransactionId = TSR.intTransferStorageId
    AND gl.strCode = 'IC'
) GL
LEFT JOIN 
(
    tblICItemUOM itemUOM 
	INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS_TO.intItemUOMId
WHERE GL.intAccountId IS NOT NULL
/*END ====>>> ***DS/SC*** FOR OP TO DP*/
--) A 
--WHERE dtmDate between '2021-03-03' and '2021-03-04'
--AND strTransactionNumber LIKE 'TRA%'
GO


