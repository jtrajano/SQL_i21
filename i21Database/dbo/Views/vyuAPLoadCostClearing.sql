﻿CREATE VIEW [dbo].[vyuAPLoadCostClearing]
AS 

SELECT
	ISNULL(C.intVendorId, B.intCustomerEntityId) AS intEntityVendorId
	,A.dtmPostedDate AS dtmDate
	,A.strLoadNumber AS strTransactionNumber
	,A.intLoadId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,B.intLoadDetailId
	,C.intLoadCostId
	,B.intItemId
	,B.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,C.dblAmount AS dblLoadCostDetailTotal
	,CASE WHEN C.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
		(CASE WHEN B.dblNet > 0 THEN B.dblNet ELSE B.dblQuantity END)
	END AS dblLoadCostDetailQty
	,B.intSCompanyLocationId AS intLocationId
	,compLoc.strLocationName
	,CAST((CASE WHEN receiptItem.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
	,GL.intAccountId
	,GL.strAccountId
FROM tblLGLoad A
INNER JOIN tblLGLoadDetail B
	ON A.intLoadId = B.intLoadId
INNER JOIN tblLGLoadCost C
	ON A.intLoadId = C.intLoadId
INNER JOIN tblSMCompanyLocation compLoc
    ON B.intSCompanyLocationId = compLoc.intCompanyLocationId
CROSS APPLY (SELECT TOP 1 GLD.intAccountId, GLA.strAccountId FROM tblGLDetail GLD
				INNER JOIN tblGLAccount GLA ON GLA.intAccountId = GLD.intAccountId
				INNER JOIN tblGLAccountGroup GLAG ON GLAG.intAccountGroupId = GLA.intAccountGroupId
				INNER JOIN tblGLAccountCategory GLAC ON GLAC.intAccountCategoryId = GLAG.intAccountCategoryId
			WHERE intTransactionId = A.intLoadId AND strTransactionId = A.strLoadNumber AND ysnIsUnposted = 0
				AND strCode IN ('LG', 'IC') AND GLAC.strAccountCategory = 'AP Clearing') GL
LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
			ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2)
ON receiptItem.intSourceId = B.intLoadDetailId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = B.intItemUOMId
WHERE 
	A.ysnPosted = 1 
AND A.intPurchaseSale = 2 --Outbound type is the only type that have AP Clearing for cost, this is also driven by company config
AND C.ysnAccrue = 1
UNION ALL
SELECT
	bill.intEntityVendorId
	,bill.dtmDate
	,D.strLoadNumber
	,C.intLoadId
	,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
	,C.intLoadDetailId
	,E.intLoadCostId
	,billDetail.intItemId
	,C.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal
    ,CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END AS dblVoucherQty
	,E.dblAmount AS dblLoadCostDetailTotal
	,CASE WHEN E.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
		(CASE WHEN C.dblNet > 0 THEN C.dblNet ELSE C.dblQuantity END)
	 END AS dblLoadCostDetailQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,1 --allow voucher if there is no receipt
	,accnt.intAccountId
	,accnt.strAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
	ON bill.intBillId = billDetail.intBillId
INNER JOIN (tblLGLoadDetail C INNER JOIN tblLGLoad D ON C.intLoadId = D.intLoadId INNER JOIN tblLGLoadCost E ON D.intLoadId = E.intLoadId)
	ON billDetail.intLoadDetailId = C.intLoadDetailId AND billDetail.intItemId = E.intItemId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
INNER JOIN tblGLAccount accnt
    ON accnt.intAccountId = billDetail.intAccountId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = C.intItemUOMId
WHERE bill.ysnPosted = 1