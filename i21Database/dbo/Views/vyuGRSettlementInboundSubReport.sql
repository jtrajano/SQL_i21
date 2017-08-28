CREATE VIEW [dbo].[vyuGRSettlementInboundSubReport]
AS
SELECT 
	 intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription
	,(SUM(WeightedAverageReading) / SUM(Net)) AS WeightedAverageReading
	,(SUM(WeightedAverageShrink) / SUM(Net)) AS WeightedAverageShrink
	,SUM(dblDiscountAmount) AS Discount
	,SUM(dblAmount) AS Amount
	,SUM(dblTax) AS Tax
FROM (
		 SELECT 
		 intPaymentId
		,strDiscountCode
		,strDiscountCodeDescription
		,Net
		,(Net * dblGradeReading) AS WeightedAverageReading
		,(Net * dblShrinkPercent) AS WeightedAverageShrink
		,dblDiscountAmount
		,dblAmount
		,dblTax
	FROM (
		SELECT --Discount Detail 
			 PYMT.intPaymentId
			,Bill.strBillId AS strId
			,BillDtl.intBillId
			,BillDtl.intItemId
			,Item.strShortName AS strDiscountCode
			,Item.strItemNo AS strDiscountCodeDescription
			,INVRCPTCHR.dblRate AS dblDiscountAmount
			,dblShrinkPercent = ISNULL((
										SELECT dblShrinkPercent
										FROM tblQMTicketDiscount TD
										JOIN tblGRDiscountScheduleCode DS ON TD.intDiscountScheduleCodeId = DS.intDiscountScheduleCodeId
										WHERE TD.intTicketId = CASE 
												WHEN INVRCPT.intSourceType = 4
													THEN (
															SELECT TOP 1 SC.intTicketId
															FROM tblGRCustomerStorage GR
															JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
															WHERE intCustomerStorageId = INVRCPTITEM.intSourceId
															)
												ELSE (
														SELECT TOP 1 SC.intTicketId
														FROM tblSCTicket SC
														WHERE intTicketId = INVRCPTITEM.intSourceId
														)
												END
											AND DS.intItemId = BillDtl.intItemId
										), 0)
			
			,dblGradeReading = ISNULL((
										SELECT dblGradeReading
										FROM tblQMTicketDiscount TD
										JOIN tblGRDiscountScheduleCode DS ON TD.intDiscountScheduleCodeId = DS.intDiscountScheduleCodeId
										WHERE TD.intTicketId = CASE 
												WHEN INVRCPT.intSourceType = 4
													THEN (
															SELECT TOP 1 SC.intTicketId
															FROM tblGRCustomerStorage GR
															JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
															WHERE intCustomerStorageId = INVRCPTITEM.intSourceId
															)
												ELSE (
														SELECT TOP 1 SC.intTicketId
														FROM tblSCTicket SC
														WHERE intTicketId = INVRCPTITEM.intSourceId
														)
												END
											AND DS.intItemId = BillDtl.intItemId
										), 0)
			
			,BillDtl.dblTotal AS dblAmount
			,BillDtl.dblTax AS dblTax
			,PYMTDTL.dblTotal AS Net
		
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
		JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
		JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = Bill.intBillId
		JOIN tblICInventoryReceiptCharge INVRCPTCHR ON BillDtl.intInventoryReceiptChargeId = INVRCPTCHR.intInventoryReceiptChargeId
		JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
		JOIN tblICInventoryReceipt INVRCPT ON INVRCPTCHR.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
		JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPT.intInventoryReceiptId = INVRCPTITEM.intInventoryReceiptId		
		WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL
		) tbl
	) tbl
GROUP BY intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription

