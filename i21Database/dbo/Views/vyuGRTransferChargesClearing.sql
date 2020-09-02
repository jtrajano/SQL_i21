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
SELECT --'1' TEST,
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
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS.ysnTransferStorage = 0
			AND CS.intTicketId IS NOT NULL
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
SELECT --'2',
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
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS.ysnTransferStorage = 0
			AND CS.intTicketId IS NOT NULL
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
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS.ysnTransferStorage = 0
			AND CS.intTicketId IS NOT NULL
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
SELECT --'4',
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
    ,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) * -1 AS dblTransferTotal
    ,CS.dblOriginalBalance
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
/*Transfer for Receipt Charges (OS to DP)
***there will be an OPEN Clearing when transferring from OS to DP*/
SELECT --'5',
    CS.intEntityId AS intEntityVendorId
    ,TS.dtmTransferStorageDate AS dtmDate      
    ,TS.strTransferStorageTicket --IR.strReceiptNumber
    ,TS.intTransferStorageId--IR.intInventoryReceiptId      
    ,0--TS.intTransferStorageId
    ,NULL--TS.strTransferStorageTicket
    ,NULL--SR.intTransferStorageReferenceId
    ,SR.intTransferStorageReferenceId --IRC.intInventoryReceiptChargeId      
    ,IC.intItemId      
    ,CS.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,0--ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) * -1 AS dblTransferTotal
    ,0
    ,ROUND((CASE WHEN GL.dblDebit <> 0 THEN GL.dblDebit ELSE GL.dblCredit END), 2) * -1 AS dblReceiptChargeTotal
    ,CS.dblOriginalBalance AS dblReceiptChargeQty 
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
INNER JOIN tblSMCompanyLocation CL      
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblICItem IC
	ON IC.strItemNo = REPLACE(SUBSTRING(GL.strDescription, CHARINDEX('Charges from ', GL.strDescription), LEN(GL.strDescription) -1),'Charges from ','')
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE GL.strDescription LIKE '%Charges from %'
UNION ALL
SELECT --'6',
    CS_TO.intEntityId AS intEntityVendorId
	--CS_FROM.intEntityId AS intEntityVendorId
    ,TS_TO.dtmTransferStorageDate AS dtmDate      
    ,SH_FROM.strTransferTicket --IR.strReceiptNumber
    ,SH_FROM.intTransferStorageId--IR.intInventoryReceiptId      
    ,TS_TO.intTransferStorageId
    ,TS_TO.strTransferStorageTicket
    ,SR_TO.intTransferStorageReferenceId
    ,SR_FROM.intTransferStorageReferenceId --IRC.intInventoryReceiptChargeId      
    ,IC.intItemId      
    ,CS_TO.intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,ROUND((CASE WHEN GL_TO.dblDebit <> 0 THEN GL_TO.dblDebit ELSE GL_TO.dblCredit END), 2) * -1 AS dblTransferTotal
    ,CS_TO.dblOriginalBalance
    ,ROUND((CASE WHEN GL_FROM.dblDebit <> 0 THEN GL_FROM.dblDebit ELSE GL_FROM.dblCredit END), 2) * -1 AS dblReceiptChargeTotal
    ,CS_TO.dblOriginalBalance AS dblReceiptChargeQty 
    ,CS_TO.intCompanyLocationId      
    ,CL_TO.strLocationName      
    ,0
FROM vyuGLDetail GL_TO
INNER JOIN vyuGLAccountDetail APClearing_TO
    ON APClearing_TO.intAccountId = GL_TO.intAccountId 
		AND APClearing_TO.intAccountCategoryId = 45
INNER JOIN tblGRTransferStorage TS_TO
	ON TS_TO.intTransferStorageId = GL_TO.intTransactionId
		AND TS_TO.strTransferStorageTicket = GL_TO.strTransactionId
INNER JOIN tblGRTransferStorageReference SR_TO
	ON SR_TO.intTransferStorageId = TS_TO.intTransferStorageId
INNER JOIN tblGRCustomerStorage CS_TO
	ON CS_TO.intCustomerStorageId = SR_TO.intToCustomerStorageId
INNER JOIN tblSMCompanyLocation CL_TO      
    ON CL_TO.intCompanyLocationId = CS_TO.intCompanyLocationId
INNER JOIN tblGRStorageHistory SH_FROM
	ON SH_FROM.intCustomerStorageId = SR_TO.intSourceCustomerStorageId
		AND SH_FROM.strType = 'From Transfer'
INNER JOIN tblGRTransferStorageReference SR_FROM
	ON SR_FROM.intTransferStorageId = SH_FROM.intTransferStorageId
		AND SR_FROM.intToCustomerStorageId = SH_FROM.intCustomerStorageId
INNER JOIN vyuGLDetail GL_FROM
	ON GL_FROM.intTransactionId = SH_FROM.intTransferStorageId
		AND GL_FROM.strTransactionId = SH_FROM.strTransferTicket
INNER JOIN vyuGLAccountDetail APClearing_FROM
    ON APClearing_FROM.intAccountId = GL_FROM.intAccountId 
		AND APClearing_FROM.intAccountCategoryId = 45
INNER JOIN tblGRCustomerStorage CS_FROM
	ON CS_FROM.intCustomerStorageId = SH_FROM.intCustomerStorageId
INNER JOIN tblICItem IC
	ON IC.strItemNo = REPLACE(SUBSTRING(GL_TO.strDescription, CHARINDEX('Charges from ', GL_TO.strDescription), LEN(GL_TO.strDescription) -1),'Charges from ','')
		AND IC.strItemNo = REPLACE(SUBSTRING(GL_FROM.strDescription, CHARINDEX('Charges from ', GL_FROM.strDescription), LEN(GL_FROM.strDescription) -1),'Charges from ','')
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = CS_TO.intItemUOMId
WHERE GL_TO.strDescription LIKE '%Charges from %' AND GL_FROM.strDescription LIKE '%Charges from %'
) charges  
OUTER APPLY (
SELECT TOP 1 intAccountId, strAccountId FROM vyuAPReceiptClearingGL gl
	 WHERE gl.strTransactionId = charges.strTransactionNumber
) APClearing
GO


