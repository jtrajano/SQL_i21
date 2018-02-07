CREATE VIEW [dbo].[vyuGRSettlementSubReport]
AS
SELECT 
 intBillDetailId
,strId
,intItemId
,strDiscountCode
,strDiscountCodeDescription
,SUM(dblDiscountAmount) dblDiscountAmount
,SUM(dblShrinkPercent) dblShrinkPercent
,dblGradeReading
,SUM(dblAmount) dblAmount
,SUM(dblTax) dblTax
,SUM(dblNetTotal) dblNetTotal
FROM
(

	 SELECT 
	 t1.intBillDetailId
	,t3.strId
	,t3.intBillId
	,t3.intItemId
	,t3.strDiscountCode
	,t3.strDiscountCodeDescription
	,t3.dblDiscountAmount * (t1.dblQtyOrdered / t2.dblTotalQty) dblDiscountAmount
	,t3.dblShrinkPercent * (t1.dblQtyOrdered / t2.dblTotalQty) dblShrinkPercent
	,t3.dblGradeReading
	,t3.dblAmount * (t1.dblQtyOrdered / t2.dblTotalQty)dblAmount
	,t3.intInventoryReceiptItemId
	,t3.intInventoryReceiptChargeId
	,t3.intContractDetailId
	,t3.dblTax
	,t3.dblNetTotal* (t1.dblQtyOrdered / t2.dblTotalQty) dblNetTotal
	FROM (
			 SELECT 
			 BillDtl.intBillDetailId
			,BillDtl.dblQtyOrdered
			,Bill.intBillId
			FROM tblAPBillDetail BillDtl
			JOIN tblAPBill Bill ON BillDtl.intBillId = Bill.intBillId
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'
		  ) t1
LEFT JOIN (
			 SELECT A.intBillId
			,SUM(dblQtyOrdered) dblTotalQty
			 FROM tblAPBillDetail A
			 JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType <> 'Other Charge'
			 GROUP BY A.intBillId
		  ) t2 ON t1.intBillId = t2.intBillId
LEFT JOIN

(SELECT * FROM
	( SELECT 
		 strId = Bill.strBillId
		,intBillId = BillDtl.intBillId
		,intBillDetailId  = BillDtl.intBillDetailId
		,intItemId = BillDtl.intItemId
		,strDiscountCode =Item.strShortName
		,strDiscountCodeDescription= Item.strItemNo
		,dblDiscountAmount = CASE 
								WHEN INVRCPTCHR.strCostMethod = 'Per Unit' THEN INVRCPTCHR.dblRate
								WHEN INVRCPTCHR.strCostMethod = 'Amount' THEN INVRCPTCHR.dblAmount
							 END
		,dblShrinkPercent = ISNULL(ScaleDiscount.dblShrinkPercent, 0)
		,dblGradeReading =  ISNULL(dbo.fnRemoveTrailingZeroes(ScaleDiscount.dblGradeReading), 'N/A')
		,dblAmount = BillDtl.dblTotal
		,intInventoryReceiptItemId = ISNULL(BillDtl.intInventoryReceiptItemId, 0)
		,intInventoryReceiptChargeId = ISNULL(BillDtl.intInventoryReceiptChargeId, 0)
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0)
		,dblTax = BillDtl.dblTax
		,dblNetTotal = BillDtl.dblTotal+ BillDtl.dblTax
	FROM tblAPBillDetail BillDtl
	JOIN tblAPBill Bill ON BillDtl.intBillId = Bill.intBillId
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
	JOIN tblICInventoryReceiptCharge INVRCPTCHR ON BillDtl.intInventoryReceiptChargeId = INVRCPTCHR.intInventoryReceiptChargeId	
	JOIN tblICInventoryReceipt INVRCPT ON INVRCPTCHR.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
	JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPT.intInventoryReceiptId = INVRCPTITEM.intInventoryReceiptId
	LEFT JOIN (
			    SELECT 
				QM.intTicketId
			   ,DCode.intItemId
			   ,QM.dblGradeReading
			   ,QM.dblShrinkPercent
				FROM tblQMTicketDiscount QM
				JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				WHERE QM.strSourceType = 'Scale'
		  ) ScaleDiscount 
	 ON ScaleDiscount.intTicketId = INVRCPTITEM.intSourceId AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId AND INVRCPT.intSourceType = 1
	WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL AND Item.strType = 'Other Charge'	
	
	UNION ALL
	
	SELECT 
		 strId = Inv.strInvoiceNumber
		,intInvoiceId=InvDtl.intInvoiceId
		,intInvoiceDetailId  = InvDtl.intInvoiceDetailId
		,intItemId = InvDtl.intItemId
		,strDiscountCode = Item.strShortName 
		,strDiscountCodeDescription = Item.strItemNo
		,dblDiscountAmount = ISNULL((
				SELECT dblDiscountAmount
				FROM tblQMTicketDiscount TD
				JOIN tblGRDiscountScheduleCode DS ON TD.intDiscountScheduleCodeId = DS.intDiscountScheduleCodeId
				WHERE TD.intTicketId = CASE 
						WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT TOP 1 SC.intTicketId
									FROM tblGRCustomerStorage GR
									JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
									WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									)
						ELSE (
								SELECT TOP 1 SC.intTicketId
								FROM tblSCTicket SC
								WHERE intTicketId = INVSHIPITEM.intSourceId
								)
						END
					AND DS.intItemId = InvDtl.intItemId
				), 0)
		,dblShrinkPercent = ISNULL((
				SELECT dblShrinkPercent
				FROM tblQMTicketDiscount TD
				JOIN tblGRDiscountScheduleCode DS ON TD.intDiscountScheduleCodeId = DS.intDiscountScheduleCodeId
				WHERE TD.intTicketId = CASE 
						WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT TOP 1 SC.intTicketId
									FROM tblGRCustomerStorage GR
									JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
									WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									)
						ELSE (
								SELECT TOP 1 SC.intTicketId
								FROM tblSCTicket SC
								WHERE intTicketId = INVSHIPITEM.intSourceId
								)
						END
					AND DS.intItemId = InvDtl.intItemId
				), 0)
		,dblGradeReading = ISNULL(dbo.fnRemoveTrailingZeroes((
				SELECT dblGradeReading
				FROM tblQMTicketDiscount TD
				JOIN tblGRDiscountScheduleCode DS ON TD.intDiscountScheduleCodeId = DS.intDiscountScheduleCodeId
				WHERE TD.intTicketId = CASE 
						WHEN INVSHIP.intSourceType = 4
							THEN (
									SELECT TOP 1 SC.intTicketId
									FROM tblGRCustomerStorage GR
									JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
									WHERE intCustomerStorageId = INVSHIPITEM.intSourceId
									)
						ELSE (
								SELECT TOP 1 SC.intTicketId
								FROM tblSCTicket SC
								WHERE intTicketId = INVSHIPITEM.intSourceId
								)
						END
					AND DS.intItemId = InvDtl.intItemId
				)), 'N/A')
		,InvDtl.dblTotal AS dblAmount
		,0
		,0
		,0
		,0
		,0
	FROM tblARInvoiceDetail InvDtl
	JOIN tblARInvoice Inv ON InvDtl.intInvoiceId = Inv.intInvoiceId
	JOIN tblICInventoryShipmentCharge INVSHIPCHR ON InvDtl.intInventoryShipmentChargeId = INVSHIPCHR.intInventoryShipmentChargeId
	JOIN tblICItem Item ON InvDtl.intItemId = Item.intItemId
	JOIN tblICInventoryShipment INVSHIP ON INVSHIPCHR.intInventoryShipmentId = INVSHIP.intInventoryShipmentId
	JOIN tblICInventoryShipmentItem INVSHIPITEM ON INVSHIP.intInventoryShipmentId = INVSHIPITEM.intInventoryShipmentId
	JOIN tblSCTicket TICKET ON INVSHIPITEM.intSourceId = TICKET.intTicketId	
	WHERE InvDtl.intInventoryShipmentChargeId IS NOT NULL
	
	UNION ALL
	
	SELECT 
		 strId = Bill.strBillId
		,intBillId = BillDtl.intBillId
		,intBillDetailId  = BillDtl.intBillDetailId
		,intItemId = BillDtl.intItemId		
		,strDiscountCode = Item.strShortName
		,strDiscountCodeDescription = Item.strItemNo
		,dblDiscountAmount = BillDtl.dblCost
		,dblShrinkPercent = ISNULL(StorageDiscount.dblShrinkPercent, 0)
		,dblGradeReading =  ISNULL(dbo.fnRemoveTrailingZeroes(StorageDiscount.dblGradeReading),'N/A')
		,dblAmount = BillDtl.dblTotal
		,intInventoryReceiptItemId = 0 
		,intInventoryReceiptChargeId = 0 
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0)
		,dblTax = BillDtl.dblTax
		,dblNetTotal = BillDtl.dblTotal+ BillDtl.dblTax
	FROM tblAPBillDetail BillDtl
	JOIN tblAPBill Bill ON BillDtl.intBillId = Bill.intBillId
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType = 'Other Charge'
	JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
	LEFT JOIN (
				 SELECT 
				 QM.intTicketFileId
				,DCode.intItemId
				,QM.dblGradeReading
				,QM.dblShrinkPercent
				FROM tblQMTicketDiscount QM
				JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				WHERE QM.strSourceType = 'Storage'
		  ) StorageDiscount ON StorageDiscount.intTicketFileId = BillDtl.intCustomerStorageId AND StorageDiscount.intItemId = BillDtl.intItemId
      WHERE Item.strType = 'Other Charge'
	) tbl 
GROUP BY 
	 strId
	,intBillId
	,intBillDetailId
	,intItemId
	,strDiscountCode
	,strDiscountCodeDescription
	,dblDiscountAmount
	,dblShrinkPercent
	,dblGradeReading
	,dblAmount
	,intInventoryReceiptItemId
	,intInventoryReceiptChargeId
	,intContractDetailId
	,dblTax
	,dblNetTotal)t3 ON  t3.intBillId =t2.intBillId AND t3.intBillId =t1.intBillId
	WHERE t3.intItemId IS NOT NULL 
)t
	
 GROUP BY 
 intBillDetailId
,strId
,intItemId
,strDiscountCode
,strDiscountCodeDescription
,dblGradeReading
