/*NOTE: this applies only in dp storages from Scale Tickets; 
****charges/discounts don't have GL entries when they were generated from Delivery Sheets****/
CREATE VIEW [dbo].[vyuGRTransferChargesClearing]
AS
SELECT  
    charges.*  
    ,APClearing.intAccountId  
    ,APClearing.strAccountId  
FROM (     
--BILL ysnPrice = 1/Charge Entity      
SELECT DISTINCT '1' AS TEST,
    Receipt.intEntityVendorId AS intEntityVendorId      
    ,Receipt.dtmReceiptDate AS dtmDate      
    ,Receipt.strReceiptNumber  AS strTransactionNumber     
    ,Receipt.intInventoryReceiptId      
    ,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,ReceiptCharge.intInventoryReceiptChargeId      
    ,ReceiptCharge.intChargeId AS intItemId     
    ,ReceiptCharge.intCostUOMId  AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM   
    ,0 AS dblTransferTotal      
    ,0 AS dblTransferQty      
    ,CAST((ISNULL(ReceiptCharge.dblAmount * -1,0) --multiple the amount to reverse if ysnPrice = 1      
        + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal      
    ,ISNULL(ReceiptCharge.dblQuantity,0) * -1 AS dblReceiptChargeQty      
    ,Receipt.intLocationId      
    ,compLoc.strLocationName      
    ,0 AS '1'
FROM tblICInventoryReceiptCharge ReceiptCharge      
INNER JOIN tblICInventoryReceipt Receipt       
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId       
INNER JOIN tblSMCompanyLocation compLoc      
    ON Receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN (
	SELECT intInventoryReceiptId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
		INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 0
			AND CS_FROM.intTicketId IS NOT NULL
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
	WHERE (ST_FROM.ysnDPOwnedType = 0 AND ST_TO.ysnDPOwnedType = 1) --OS to DP
		OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) --DP to OS
        OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1) --DP to DP
) TS	
	ON TS.intInventoryReceiptId = Receipt.intInventoryReceiptId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = ReceiptCharge.intCostUOMId 
WHERE       
    Receipt.ysnPosted = 1        
AND ReceiptCharge.ysnPrice = 1      
UNION ALL      
--BILL ysnAccrue = 1/There is a vendor selected, receipt vendor    
SELECT DISTINCT '2',
    ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) AS intEntityVendorId      
    ,Receipt.dtmReceiptDate AS dtmDate      
    ,Receipt.strReceiptNumber  AS strTransactionNumber    
    ,Receipt.intInventoryReceiptId      
    ,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,ReceiptCharge.intInventoryReceiptChargeId      
    ,ReceiptCharge.intChargeId AS intItemId    
    ,ReceiptCharge.intCostUOMId  AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM     
    ,0 AS dblTransferTotal      
    ,0 AS dblTransferQty      
    ,CAST((ISNULL(dblAmount,0) + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal      
    ,ISNULL(ReceiptCharge.dblQuantity,0) AS dblReceiptChargeQty      
    ,Receipt.intLocationId      
    ,compLoc.strLocationName      
    ,0
FROM tblICInventoryReceiptCharge ReceiptCharge      
INNER JOIN tblICInventoryReceipt Receipt       
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId       
        AND ReceiptCharge.ysnAccrue = 1       
INNER JOIN tblSMCompanyLocation compLoc      
    ON Receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN (
	SELECT intInventoryReceiptId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 0
			AND CS_FROM.intTicketId IS NOT NULL
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
	WHERE (ST_FROM.ysnDPOwnedType = 0 AND ST_TO.ysnDPOwnedType = 1) --OS to DP
		OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) --DP to OS
        OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1) --DP to DP
) TS	
	ON TS.intInventoryReceiptId = Receipt.intInventoryReceiptId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = ReceiptCharge.intCostUOMId
WHERE       
    Receipt.ysnPosted = 1        
AND ReceiptCharge.ysnAccrue = 1      
AND Receipt.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) --make sure that the result would be for receipt vendor only    
UNION ALL      
--BILL ysnAccrue = 1/There is a vendor selected, third party vendor    
SELECT '3',
    ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) AS intEntityVendorId      
    ,Receipt.dtmReceiptDate AS dtmDate      
    ,Receipt.strReceiptNumber  AS strTransactionNumber    
    ,Receipt.intInventoryReceiptId      
    ,NULL AS intTransferStorageId
    ,NULL AS strTransferStorageTicket
    ,NULL AS intTransferStorageReferenceId
    ,ReceiptCharge.intInventoryReceiptChargeId          
    ,ReceiptCharge.intChargeId AS intItemId      
    ,ReceiptCharge.intCostUOMId  AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM     
    ,0 AS dblTransferTotal      
    ,0 AS dblTransferQty      
    ,CAST((ISNULL(dblAmount,0) + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal      
    ,ISNULL(ReceiptCharge.dblQuantity,0) AS dblReceiptChargeQty      
    ,Receipt.intLocationId      
    ,compLoc.strLocationName      
    ,0
FROM tblICInventoryReceiptCharge ReceiptCharge      
INNER JOIN tblICInventoryReceipt Receipt       
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId       
        AND ReceiptCharge.ysnAccrue = 1       
INNER JOIN tblSMCompanyLocation compLoc      
    ON Receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN (
	SELECT intInventoryReceiptId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 0
			AND CS_FROM.intTicketId IS NOT NULL
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
	WHERE (ST_FROM.ysnDPOwnedType = 0 AND ST_TO.ysnDPOwnedType = 1) --OS to DP
		OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) --DP to OS
        OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1) --DP to DP
) TS	
	ON TS.intInventoryReceiptId = Receipt.intInventoryReceiptId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = ReceiptCharge.intCostUOMId
WHERE       
    Receipt.ysnPosted = 1        
AND ReceiptCharge.ysnAccrue = 1      
AND ReceiptCharge.intEntityVendorId IS NOT NULL    
AND ReceiptCharge.intEntityVendorId != Receipt.intEntityVendorId --make sure that the result would be for third party vendor only    
UNION ALL      



--Transfer for Receipt Charges
SELECT DISTINCT '4',
    CS_Tomorrow.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate      
    ,IR.strReceiptNumber
	,IR.intInventoryReceiptId
    ,TS.intTransferStorageId
    ,TS.strTransferStorageTicket
    ,SR.intTransferStorageReferenceId
    ,IRC.intInventoryReceiptChargeId      
    ,IC.intItemId      
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) * -1 dblTransferTotal  
    ,(ISNULL(IRC.dblQuantity,0) * (SR.dblSplitPercent / 100 )) * -1 AS dblTransferQty 
    ,0 AS dblReceiptChargeTotal
    ,0 AS dblReceiptChargeQty
    ,CS.intCompanyLocationId      
    ,CL.strLocationName      
    ,0
FROM vyuGLDetail GL
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = GL.intTransactionId
		AND TS.strTransferStorageTicket = GL.strTransactionId
INNER JOIN tblGRTransferStorageReference SR
	ON SR.intTransferStorageId = TS.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId
INNER JOIN tblGRCustomerStorage CS_Tomorrow
        ON CS_Tomorrow.intCustomerStorageId = SR.intToCustomerStorageId
INNER JOIN tblSMCompanyLocation CL      
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN (
	SELECT CS.intCustomerStorageId
		,intInventoryReceiptId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS.ysnTransferStorage = 0
			AND CS.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS.intStorageTypeId
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    WHERE ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1
) IR_SOURCE	
	ON IR_SOURCE.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblICItem IC
	ON IC.strItemNo = REPLACE(SUBSTRING(GL.strDescription, CHARINDEX('Charges from ', GL.strDescription), LEN(GL.strDescription) -1),'Charges from ','')
INNER JOIN tblICInventoryReceipt IR
	ON IR.intInventoryReceiptId = IR_SOURCE.intInventoryReceiptId
INNER JOIN tblICInventoryReceiptCharge IRC
	ON IRC.intInventoryReceiptId = IR.intInventoryReceiptId
		AND IRC.intChargeId = IC.intItemId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE GL.strDescription LIKE '%Charges from %'





UNION ALL
SELECT DISTINCT '4.1',
   CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate      
    ,IR.strReceiptNumber      
    ,IR.intInventoryReceiptId      
    ,TS.intTransferStorageId
    ,TS.strTransferStorageTicket
    ,SR.intTransferStorageReferenceId
    ,IRC.intInventoryReceiptChargeId      
    ,IC.intItemId      
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,0
    ,ISNULL(IRC.dblQuantity,0) AS dblReceiptChargeQty 
    ,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) dblReceiptChargeTotal  
    ,ISNULL(IRC.dblQuantity,0) AS dblReceiptChargeQty 
    ,CS.intCompanyLocationId      
    ,CL.strLocationName      
    ,0
FROM vyuGLDetail GL
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = GL.intTransactionId
		AND TS.strTransferStorageTicket = GL.strTransactionId
INNER JOIN tblGRTransferStorageReference SR
	ON SR.intTransferStorageId = TS.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId
INNER JOIN tblSMCompanyLocation CL      
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN (
	SELECT CS_.intCustomerStorageId
		,intInventoryReceiptId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS_
		ON CS_.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_.ysnTransferStorage = 0
			AND CS_.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_.intStorageTypeId
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    WHERE ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0
) IR_SOURCE	
	ON IR_SOURCE.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblICItem IC
	ON IC.strItemNo = REPLACE(SUBSTRING(GL.strDescription, CHARINDEX('Charges from ', GL.strDescription), LEN(GL.strDescription) -1),'Charges from ','')
INNER JOIN tblICInventoryReceipt IR
	ON IR.intInventoryReceiptId = IR_SOURCE.intInventoryReceiptId
INNER JOIN tblICInventoryReceiptCharge IRC
	ON IRC.intInventoryReceiptId = IR.intInventoryReceiptId
		AND IRC.intChargeId = IC.intItemId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE GL.strDescription LIKE '%Charges from %'
--and TS.dtmTransferStorageDate between '2021-03-02' and '2021-03-03'
AND ((CASE WHEN GL.dblDebitUnit = 0 THEN GL.dblCreditUnit ELSE GL.dblDebitUnit END = SR.dblUnitQty)
    OR (CASE WHEN GL.dblDebitUnit = 0 THEN GL.dblCreditUnit ELSE GL.dblDebitUnit END = CS.dblGrossQuantity))
UNION ALL      
--Transfer for Receipt Charge Taxes
SELECT DISTINCT '5',
    CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate      
    ,TS.strTransferStorageTicket
	,IR.intInventoryReceiptId
    ,TS.intTransferStorageId
    ,TS.strTransferStorageTicket
    ,SR.intTransferStorageReferenceId
    ,IRC.intInventoryReceiptChargeId      
    ,IC.intItemId      
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,0 AS dblTransferTotal      
    ,0 AS dblTransferQty  
    ,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) dblReceiptChargeTotal  
    ,0 AS dblReceiptChargeQty 
    ,CS.intCompanyLocationId      
    ,CL.strLocationName      
    ,0
FROM vyuGLDetail GL
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = GL.intTransactionId
		AND TS.strTransferStorageTicket = GL.strTransactionId
INNER JOIN tblGRTransferStorageReference SR
	ON SR.intTransferStorageId = TS.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId
INNER JOIN tblSMCompanyLocation CL      
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN (
	SELECT CS.intCustomerStorageId
		,intInventoryReceiptId
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intSourceCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS.ysnTransferStorage = 0
			AND CS.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS.intStorageTypeId
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    WHERE ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1
) IR_SOURCE	
	ON IR_SOURCE.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblICInventoryReceipt IR
	ON IR.intInventoryReceiptId = IR_SOURCE.intInventoryReceiptId
INNER JOIN tblICInventoryReceiptCharge IRC
	ON IRC.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN tblICItem IC
	ON IC.intItemId = IRC.intChargeId
	AND GL.strDescription LIKE '%' + IC.strItemNo + '%'
INNER JOIN tblICInventoryReceiptChargeTax IRCT
	ON IRCT.intInventoryReceiptChargeId = IRC.intInventoryReceiptChargeId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE GL.strDescription NOT LIKE '%Charges from %'
UNION ALL
--TRANSFER  OS(AND DP) TO DP
SELECT DISTINCT '6',
    CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate      
    ,TS.strTransferStorageTicket
	,TS.intTransferStorageId --IR.intInventoryReceiptId
    ,NULL
    ,NULL--TS.strTransferStorageTicket
    ,NULL
    ,SR.intTransferStorageReferenceId--IRC.intInventoryReceiptChargeId      
    ,IM.intItemId      
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,0 AS dblTransferTotal      
    ,0 AS dblTransferQty  
    --,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) dblReceiptChargeTotal  
	,CAST((CASE
		WHEN QM.strDiscountChargeType = 'Percent'
			THEN (QM.dblDiscountAmount * (CS.dblBasis + CS.dblSettlementPrice) * -1)
		WHEN QM.strDiscountChargeType = 'Dollar' THEN QM.dblDiscountAmount
	END 
	* (CASE 
		WHEN QM.strCalcMethod = 3 
			THEN (CS.dblGrossQuantity * (SR.dblUnitQty / CS.dblOriginalBalance))	
		ELSE SR.dblUnitQty
	END) * -1) AS DECIMAL(18,2))
    ,ROUND(((CASE WHEN QM.strCalcMethod = 3 
		THEN (CS.dblGrossQuantity * (SR.dblUnitQty / CS.dblOriginalBalance))--@dblGrossUnits 
	ELSE SR.dblUnitQty END * (CASE WHEN QM.dblDiscountAmount > 0 THEN 1 ELSE -1 END)) ) * -1, 2) AS dblReceiptChargeQty 
    ,CS.intCompanyLocationId      
    ,CL.strLocationName      
    ,0
FROM vyuGLDetail GL
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = GL.intTransactionId
		AND TS.strTransferStorageTicket = GL.strTransactionId
INNER JOIN tblGRTransferStorageReference SR
	ON SR.intTransferStorageId = TS.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SR.intToCustomerStorageId
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		AND ST.ysnDPOwnedType = 1
INNER JOIN tblGRCustomerStorage CS_FROM
	ON CS_FROM.intCustomerStorageId = SR.intSourceCustomerStorageId
INNER JOIN tblGRStorageType ST_FROM
	ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblQMTicketDiscount QM	
	ON QM.intTicketFileId = CS.intCustomerStorageId	
		AND QM.strSourceType = 'Storage'
		AND QM.dblDiscountDue <> 0
INNER JOIN tblGRDiscountScheduleCode DSC
	ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
INNER JOIN tblICItem IM
	ON DSC.intItemId = IM.intItemId
OUTER APPLY
(
	SELECT GD.intAccountId, AD.strAccountId--, GD.dblDebit, GD.dblCredit, GD.dblCreditUnit, GD.dblDebitUnit
	FROM tblGLDetail GD
	INNER JOIN vyuGLAccountDetail AD
		ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
	WHERE GD.strTransactionId = TS.strTransferStorageTicket
		AND GD.intTransactionId = TS.intTransferStorageId
		-- AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND IM.strItemNo = REPLACE(SUBSTRING(GD.strDescription, CHARINDEX('Charges from ', GD.strDescription), LEN(GD.strDescription) -1),'Charges from ','')
		AND GD.ysnIsUnposted = 0
		AND GD.intAccountId NOT IN (
			SELECT GD.intAccountId
			FROM tblGLDetail		
			WHERE strTransactionId = GD.strTransactionId
				AND intTransactionId = GD.intTransactionId
				AND strDescription = GD.strDescription
				AND ysnIsUnposted = 0
				AND intAccountId = GD.intAccountId
				AND (dblDebit = GD.dblCredit OR dblCredit = GD.dblDebit)
                -- Exclude DP to DP for this checking
                AND NOT (ST_FROM.ysnDPOwnedType = 1 AND ST.ysnDPOwnedType = 1)
	)
) GLDetail
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS.intItemUOMId
-- WHERE GL.strDescription NOT LIKE '%Charges from %'
WHERE GL.strCode = 'IC'
AND QM.dblDiscountDue <> 0
AND GLDetail.intAccountId IS NOT NULL
UNION ALL
--DP TRANSFER STORAGE TO OS (AND DP)
SELECT DISTINCT '7',
    CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate
    ,ORIGIN.strTransferStorageTicket
	,ORIGIN.intTransferStorageId --IR.intInventoryReceiptId
    ,TS.intTransferStorageId
    ,TS.strTransferStorageTicket--TS.strTransferStorageTicket
    ,SR.intTransferStorageReferenceId
    ,ORIGIN.intTransferStorageReferenceId--IRC.intInventoryReceiptChargeId      
    ,IM.intItemId      
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,CAST((CASE
		WHEN QM.strDiscountChargeType = 'Percent'
			THEN (QM.dblDiscountAmount * (CS.dblBasis + CS.dblSettlementPrice) * -1)
		WHEN QM.strDiscountChargeType = 'Dollar' THEN QM.dblDiscountAmount
	END 
	* (CASE 
		WHEN QM.strCalcMethod = 3 
			THEN (CS.dblGrossQuantity * (SR.dblUnitQty / CS.dblOriginalBalance))	
		ELSE SR.dblUnitQty
	END) * -1) AS DECIMAL(18,2))
    ,ROUND(((CASE WHEN QM.strCalcMethod = 3 
		THEN (CS.dblGrossQuantity * (SR.dblUnitQty / CS.dblOriginalBalance))--@dblGrossUnits 
	ELSE SR.dblUnitQty END * (CASE WHEN QM.dblDiscountAmount > 0 THEN 1 ELSE -1 END)) * -1), 2) AS dblTransferQty  
    --,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) dblReceiptChargeTotal  
	,0 AS dblReceiptChargeTotal
    ,0 AS dblReceiptChargeQty 
    ,CS.intCompanyLocationId      
    ,CL.strLocationName      
    ,0
FROM vyuGLDetail GL
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = GL.intAccountId 
		AND APClearing.intAccountCategoryId = 45
INNER JOIN tblGRTransferStorage TS
	ON TS.intTransferStorageId = GL.intTransactionId
		AND TS.strTransferStorageTicket = GL.strTransactionId
INNER JOIN tblGRTransferStorageReference SR
	ON SR.intTransferStorageId = TS.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId
		AND CS.ysnTransferStorage = 1
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		AND ST.ysnDPOwnedType = 1
OUTER APPLY (
	SELECT TSR2.intTransferStorageReferenceId,TS2.intTransferStorageId,TS2.strTransferStorageTicket
	FROM tblGRTransferStorageReference TSR2
	INNER JOIN tblGRTransferStorage TS2
		ON TS2.intTransferStorageId = TSR2.intTransferStorageId
	WHERE TSR2.intToCustomerStorageId = SR.intSourceCustomerStorageId
) ORIGIN
INNER JOIN tblGRCustomerStorage CS_TO
	ON CS_TO.intCustomerStorageId = SR.intToCustomerStorageId
INNER JOIN tblGRStorageType ST_TO
	ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
		-- AND ST_TO.ysnDPOwnedType = 0
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblQMTicketDiscount QM	
	ON QM.intTicketFileId = CS.intCustomerStorageId	
		AND QM.strSourceType = 'Storage'
		AND QM.dblDiscountDue <> 0
INNER JOIN tblGRDiscountScheduleCode DSC
	ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
INNER JOIN tblICItem IM
	ON DSC.intItemId = IM.intItemId
OUTER APPLY
(
	SELECT GD.intAccountId, AD.strAccountId--, GD.dblDebit, GD.dblCredit, GD.dblCreditUnit, GD.dblDebitUnit
	FROM tblGLDetail GD
	INNER JOIN vyuGLAccountDetail AD
		ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
	WHERE GD.strTransactionId = TS.strTransferStorageTicket
		AND GD.intTransactionId = TS.intTransferStorageId
		-- AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND IM.strItemNo = REPLACE(SUBSTRING(GD.strDescription, CHARINDEX('Charges from ', GD.strDescription), LEN(GD.strDescription) -1),'Charges from ','')
		AND GD.ysnIsUnposted = 0
		AND GD.intAccountId NOT IN (
			SELECT GD.intAccountId
			FROM tblGLDetail		
			WHERE strTransactionId = GD.strTransactionId
				AND intTransactionId = GD.intTransactionId
				AND strDescription = GD.strDescription
				AND ysnIsUnposted = 0
				AND intAccountId = GD.intAccountId
				AND (dblDebit = GD.dblCredit OR dblCredit = GD.dblDebit)
                -- Exclude DP to DP for this checking
                AND NOT (ST_TO.ysnDPOwnedType = 1 AND ST.ysnDPOwnedType = 1)
	)


) GLDetail
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS.intItemUOMId
-- WHERE GL.strDescription NOT LIKE '%Charges from %'
WHERE GL.strCode = 'IC'
--AND TS.strTransferStorageTicket = 'TRA-563'
AND QM.dblDiscountDue <> 0
AND GLDetail.intAccountId IS NOT NULL
--AND TS.dtmTransferStorageDate between '03/03/2021' and '03/04/2021'










    -- Voucher for IR Charges
    UNION ALL
    SELECT DISTINCT '8' AS TEST,
        bill.intEntityVendorId      
        ,bill.dtmDate AS dtmDate      
        ,receipt.strReceiptNumber      
        ,receipt.intInventoryReceiptId      
        ,bill.intBillId      
        ,bill.strBillId      
        ,NULL AS intTransferStorageReferenceId
        ,billDetail.intInventoryReceiptChargeId      
        ,billDetail.intItemId      
        ,billDetail.intUnitOfMeasureId AS intItemUOMId  
        ,unitMeasure.strUnitMeasure AS strUOM  
        ,ROUND(
            (
                CASE WHEN ABS(billDetail.dblTotal) <> receiptCharge.dblAmount
                    THEN (
                    --IF THERE IS OLD COST, ASSUME THIS IS NOT PRORATED
                    --PRO RATED SHOULD HAVE NO COST ADJUSTMENT
                    CASE WHEN billDetail.dblOldCost IS NOT NULL
                    THEN receiptCharge.dblAmount * (CASE WHEN billDetail.dblQtyReceived < 0 THEN -1 ELSE 1 END)
                    ELSE billDetail.dblTotal
                    END
                    )
                ELSE billDetail.dblTotal END
            )
        , 2) 
        *
        (
            CASE 
            WHEN bill.intTransactionType = 3
            THEN -1
            ELSE 1
            END
        ) AS dblVoucherTotal      
        ,ROUND(CASE       
            WHEN billDetail.intWeightUOMId IS NULL THEN       
                ISNULL(billDetail.dblQtyReceived, 0)       
            ELSE       
                CASE       
                    WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN       
                        ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)      
                    ELSE       
                        ISNULL(billDetail.dblNetWeight, 0)       
                END      
        END,2) 
        *
        (
            CASE 
            WHEN bill.intTransactionType = 3
            THEN -1
            ELSE 1
            END
        ) AS dblVoucherQty      
        ,0 AS dblReceiptChargeTotal
        ,0 AS dblReceiptChargeQty 
        ,receipt.intLocationId      
        ,compLoc.strLocationName      
        ,CAST(1 AS BIT) ysnAllowVoucher 
    FROM tblAPBill bill      
    INNER JOIN tblAPBillDetail billDetail      
        ON bill.intBillId = billDetail.intBillId      
    INNER JOIN tblICInventoryReceiptCharge receiptCharge      
        ON billDetail.intInventoryReceiptChargeId  = receiptCharge.intInventoryReceiptChargeId      
    INNER JOIN tblICInventoryReceipt receipt      
        ON receipt.intInventoryReceiptId  = receiptCharge.intInventoryReceiptId      
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
    WHERE       
        billDetail.intInventoryReceiptChargeId IS NOT NULL
    AND EXISTS (
        SELECT TOP 1 1
        FROM tblGRTransferStorageReference TSR
        WHERE TSR.intSourceCustomerStorageId = CS.intCustomerStorageId
    )
    -- AND receiptCharge.ysnInventoryCost = 0
    AND bill.ysnPosted = 1

    -- Voucher for TRA (DP to DP) Charges using intInventoryReceiptItemId in Bill Detail
    UNION ALL
    SELECT DISTINCT '9' AS TEST,
        bill.intEntityVendorId      
        ,bill.dtmDate AS dtmDate      
        ,TS.strTransferStorageTicket   
        ,TS.intTransferStorageId  
        ,bill.intBillId      
        ,bill.strBillId      
        ,NULL --billDetail.intInventoryReceiptChargeId
        ,TSR.intTransferStorageReferenceId 
        ,billDetail.intItemId      
        ,billDetail.intUnitOfMeasureId AS intItemUOMId  
        ,unitMeasure.strUnitMeasure AS strUOM  
        ,ROUND(
            (
                CASE WHEN ABS(billDetail.dblTotal) <> receiptCharge.dblAmount
                    THEN (
                    --IF THERE IS OLD COST, ASSUME THIS IS NOT PRORATED
                    --PRO RATED SHOULD HAVE NO COST ADJUSTMENT
                    CASE WHEN billDetail.dblOldCost IS NOT NULL
                    THEN receiptCharge.dblAmount * (CASE WHEN billDetail.dblQtyReceived < 0 THEN -1 ELSE 1 END)
                    ELSE billDetail.dblTotal
                    END
                    )
                ELSE billDetail.dblTotal END
            )
        , 2) 
        *
        (
            CASE 
            WHEN bill.intTransactionType = 3
            THEN -1
            ELSE 1
            END
        ) AS dblVoucherTotal      
        ,ROUND(CASE       
            WHEN billDetail.intWeightUOMId IS NULL THEN       
                ISNULL(billDetail.dblQtyReceived, 0)       
            ELSE       
                CASE       
                    WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN       
                        ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)      
                    ELSE       
                        ISNULL(billDetail.dblNetWeight, 0)       
                END      
        END,2) 
        *
        (
            CASE 
            WHEN bill.intTransactionType = 3
            THEN -1
            ELSE 1
            END
        ) AS dblVoucherQty      
        ,0 AS dblReceiptChargeTotal
        ,0 AS dblReceiptChargeQty 
        ,receipt.intLocationId      
        ,compLoc.strLocationName      
        ,CAST(1 AS BIT) ysnAllowVoucher 
    FROM tblAPBill bill      
    INNER JOIN tblAPBillDetail billDetail      
        ON bill.intBillId = billDetail.intBillId      
    INNER JOIN tblICInventoryReceiptCharge receiptCharge      
        ON billDetail.intInventoryReceiptChargeId  = receiptCharge.intInventoryReceiptChargeId      
    INNER JOIN tblICInventoryReceipt receipt      
        ON receipt.intInventoryReceiptId  = receiptCharge.intInventoryReceiptId      
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
		AND gl.strCode <> 'IC'
	) APClearing
    WHERE       
        billDetail.intInventoryReceiptChargeId IS NOT NULL
    AND bill.ysnPosted = 1
	AND APClearing.intAccountId IS NOT NULL

    -- Voucher for TRA (DP to DP) Charges using intCustomerStorageId in Bill Detail
    UNION ALL
    SELECT DISTINCT '9.1' AS TEST,
        bill.intEntityVendorId      
        ,bill.dtmDate AS dtmDate      
        ,TS.strTransferStorageTicket   
        ,TS.intTransferStorageId  
        ,bill.intBillId      
        ,bill.strBillId      
        ,NULL --billDetail.intInventoryReceiptChargeId
        ,TSR.intTransferStorageReferenceId 
        ,billDetail.intItemId      
        ,billDetail.intUnitOfMeasureId AS intItemUOMId  
        ,unitMeasure.strUnitMeasure AS strUOM  
        ,ROUND(billDetail.dblTotal, 2) 
        *
        (
            CASE 
            WHEN bill.intTransactionType = 3
            THEN -1
            ELSE 1
            END
        ) AS dblVoucherTotal      
        ,ROUND(CASE       
            WHEN billDetail.intWeightUOMId IS NULL THEN       
                ISNULL(billDetail.dblQtyReceived, 0)       
            ELSE       
                CASE       
                    WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN       
                        ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)      
                    ELSE       
                        ISNULL(billDetail.dblNetWeight, 0)       
                END      
        END,2) 
        *
        (
            CASE 
            WHEN bill.intTransactionType = 3
            THEN -1
            ELSE 1
            END
        ) AS dblVoucherQty      
        ,0 AS dblReceiptChargeTotal
        ,0 AS dblReceiptChargeQty 
        ,TS.intCompanyLocationId      
        ,compLoc.strLocationName      
        ,CAST(1 AS BIT) ysnAllowVoucher 
    FROM tblAPBill bill      
    INNER JOIN tblAPBillDetail billDetail      
        ON bill.intBillId = billDetail.intBillId
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = billDetail.intCustomerStorageId
    INNER JOIN tblGRStorageType ST
        ON ST.intStorageScheduleTypeId = CS_TO.intStorageTypeId
        AND ST.ysnDPOwnedType = 1
    INNER JOIN tblGRTransferStorageReference TSR
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblSMCompanyLocation compLoc      
        ON TS.intCompanyLocationId = compLoc.intCompanyLocationId
    INNER JOIN tblGRSettleStorageBillDetail SSBD
        ON SSBD.intBillId = bill.intBillId
    INNER JOIN tblGRSettleStorage SS
        ON SS.intSettleStorageId = SSBD.intSettleStorageId
    INNER JOIN tblGRSettleStorageTicket SST
        ON SST.intSettleStorageId = SS.intSettleStorageId
        AND CS_TO.intCustomerStorageId = SST.intCustomerStorageId
    INNER JOIN tblQMTicketDiscount QM	
        ON QM.intTicketFileId = CS_TO.intCustomerStorageId	
        AND QM.strSourceType = 'Storage'
        AND QM.dblDiscountDue <> 0
    INNER JOIN tblGRDiscountScheduleCode DSC
        ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
        AND DSC.intItemId = billDetail.intItemId
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
		AND gl.strCode <> 'IC'
	) APClearing
    WHERE bill.ysnPosted = 1
		AND APClearing.intAccountId IS NOT NULL

) charges  
OUTER APPLY (
SELECT TOP 1 intAccountId, strAccountId FROM vyuAPReceiptClearingGL gl
	 WHERE gl.strTransactionId = charges.strTransactionNumber
) APClearing
