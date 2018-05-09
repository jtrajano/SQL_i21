﻿CREATE VIEW [dbo].[vyuAPRptCheckBasisInfo]
AS

SELECT 
	A.intBillId
	,B.intScaleTicketId 
	,C.strTicketNumber
	,B.intContractHeaderId
	,D.strContractNumber
	,B.dblBasis
	,B.dblFutures
	,A.dblTotal AS dblTotalAdvance
	,ISNULL(charges.dblAmount,0) AS dblTotalCharges
	,ISNULL(discounts.dblAmount,0) AS dblTotalDiscounts
	,ISNULL(taxes.dblTax,0) AS dblTotalTaxes
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblSCTicket C ON B.intScaleTicketId = C.intTicketId
INNER JOIN tblCTContractHeader D ON B.intContractHeaderId = D.intContractHeaderId
INNER JOIN (tblICInventoryReceipt E INNER JOIN tblICInventoryReceiptItem F ON E.intInventoryReceiptId = F.intInventoryReceiptId)
	ON C.intTicketId = F.intSourceId AND E.intSourceType = 1
OUTER APPLY (
    SELECT
        SUM(charge.dblAmount) AS dblAmount
    FROM tblQMTicketDiscount tktDiscount
    INNER JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
    INNER JOIN tblICInventoryReceiptCharge charge ON dscntCode.intItemId = charge.intChargeId
    WHERE charge.intInventoryReceiptId = F.intInventoryReceiptId
    AND tktDiscount.dblGradeReading != 0
    AND tktDiscount.intTicketId = B.intScaleTicketId
    AND tktDiscount.strSourceType = 'Scale'
    GROUP BY charge.intInventoryReceiptId
) discounts
    OUTER APPLY (
	SELECT SUM(dblAmount) AS dblAmount
	FROM (
		SELECT
			(ISNULL(charge.dblAmount,0) * (CASE WHEN charge.ysnPrice = 1 THEN -1 ELSE 1 END))
				+ (
					ISNULL((CASE WHEN ISNULL(charge.intEntityVendorId, E.intEntityVendorId) != E.intEntityVendorId
								THEN (CASE WHEN chargeTax.ysnCheckoffTax = 0 THEN ABS(charge.dblTax) ELSE charge.dblTax END) --THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
								ELSE (CASE WHEN charge.ysnPrice = 1 AND chargeTax.ysnCheckoffTax = 1 THEN charge.dblTax * -1 ELSE charge.dblTax END ) END),0)
				)
			AS dblAmount
		FROM tblICInventoryReceiptCharge charge
		OUTER APPLY
		(
			SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
			WHERE IRCT.intInventoryReceiptChargeId = charge.intInventoryReceiptChargeId
		)  chargeTax
		WHERE charge.intInventoryReceiptId = E.intInventoryReceiptId
		AND charge.intChargeId NOT IN (
			SELECT
				dscntCode.intItemId
			FROM tblQMTicketDiscount tktDiscount
			INNER JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
			WHERE tktDiscount.intTicketId = B.intScaleTicketId
		)
	) chargesAmount
) charges
OUTER APPLY (
    SELECT
        SUM(itemTax.dblTax) AS dblTax
    FROM tblICInventoryReceiptItem receiptDetail
    INNER JOIN tblICInventoryReceiptItemTax itemTax ON receiptDetail.intInventoryReceiptItemId = itemTax.intInventoryReceiptItemId
    WHERE receiptDetail.intInventoryReceiptId = E.intInventoryReceiptId
    GROUP BY receiptDetail.intInventoryReceiptId
) taxes