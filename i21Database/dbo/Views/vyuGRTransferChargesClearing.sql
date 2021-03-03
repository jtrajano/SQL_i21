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
SELECT DISTINCT --'1' AS TEST,
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
SELECT DISTINCT --'2',
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
SELECT --'3',
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
SELECT DISTINCT --'4',
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
    ,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) * -1 dblReceiptChargeTotal  
    ,ISNULL(IRC.dblQuantity,0) * -1 AS dblReceiptChargeQty 
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
SELECT DISTINCT --'4.1',
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
AND (CASE WHEN GL.dblDebitUnit = 0 THEN GL.dblCreditUnit ELSE GL.dblDebitUnit END = SR.dblUnitQty)
UNION ALL      
--Transfer for Receipt Charge Taxes
SELECT DISTINCT --'5',
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
	AND GL.strDescription LIKE CONCAT('%', IC.strItemNo, '%')
INNER JOIN tblICInventoryReceiptChargeTax IRCT
	ON IRCT.intInventoryReceiptChargeId = IRC.intInventoryReceiptChargeId
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE GL.strDescription NOT LIKE '%Charges from %'

) charges  
OUTER APPLY (
SELECT TOP 1 intAccountId, strAccountId FROM vyuAPReceiptClearingGL gl
	 WHERE gl.strTransactionId = charges.strTransactionNumber
) APClearing