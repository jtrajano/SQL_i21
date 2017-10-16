CREATE VIEW [dbo].[vyuGRSettlementSubReport]
AS
SELECT *
FROM (
	SELECT 
		 strId = Bill.strBillId
		,intBillId = BillDtl.intBillId
		,intItemId = BillDtl.intItemId
		,strDiscountCode =Item.strShortName
		,strDiscountCodeDescription= Item.strItemNo
		,dblDiscountAmount = CASE 
								WHEN INVRCPTCHR.strCostMethod = 'Per Unit' THEN INVRCPTCHR.dblRate
								WHEN INVRCPTCHR.strCostMethod = 'Amount' THEN INVRCPTCHR.dblAmount
							 END
		,dblShrinkPercent = ISNULL(ScaleDiscount.dblShrinkPercent, 0)
		,dblGradeReading =  ISNULL(ScaleDiscount.dblGradeReading, 0)
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
		,dblGradeReading = ISNULL((
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
				), 0)
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
		,intItemId = BillDtl.intItemId
		,strDiscountCode = Item.strShortName
		,strDiscountCodeDescription = Item.strItemNo
		,dblDiscountAmount = BillDtl.dblCost
		,dblShrinkPercent = ISNULL(StorageDiscount.dblShrinkPercent, 0)
		,dblGradeReading =  ISNULL(StorageDiscount.dblGradeReading, 0)
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
GROUP BY strId
	,intBillId
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
	,dblNetTotal