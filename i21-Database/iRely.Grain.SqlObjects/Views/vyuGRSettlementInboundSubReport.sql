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
		SELECT
			 intPaymentId = PYMT.intPaymentId
			,strId = Bill.strBillId
			,intBillId = BillDtl.intBillId
			,intItemId = BillDtl.intItemId
			,strDiscountCode = Item.strShortName 
			,strDiscountCodeDescription = Item.strItemNo
			,dblDiscountAmount = BillDtl.dblTotal
			,dblShrinkPercent = ISNULL(ScaleDiscount.dblShrinkPercent, 0)
			,dblGradeReading =  ISNULL(ScaleDiscount.dblGradeReading, 0)			
			,dblAmount = BillDtl.dblTotal 
			,dblTax = BillDtl.dblTax
			,Net = PYMTDTL.dblTotal
		
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
		JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
		JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = Bill.intBillId
		JOIN tblICInventoryReceiptCharge INVRCPTCHR ON BillDtl.intInventoryReceiptChargeId = INVRCPTCHR.intInventoryReceiptChargeId
		JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
		JOIN tblICInventoryReceipt INVRCPT ON INVRCPTCHR.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
		JOIN (
				SELECT intSourceId,intInventoryReceiptId,ROW_NUMBER() OVER (PARTITION BY intInventoryReceiptId ORDER BY intSourceId) intRowNum
				FROM	tblICInventoryReceiptItem
			 )  INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId =INVRCPT.intInventoryReceiptId AND INVRCPTITEM.intRowNum =1
		LEFT JOIN (
					SELECT 
					QM.intTicketId
				   ,DCode.intItemId
				   ,QM.dblGradeReading
				   ,QM.dblShrinkPercent
					FROM tblQMTicketDiscount QM
					JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					WHERE QM.strSourceType = 'Scale'
			     ) ScaleDiscount ON ScaleDiscount.intTicketId = INVRCPTITEM.intSourceId AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId AND INVRCPT.intSourceType = 1 
				 WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL AND Item.strType = 'Other Charge'
        UNION ALL
		
		SELECT
			 intPaymentId = PYMT.intPaymentId
			,strId = Bill.strBillId
			,intBillId = BillDtl.intBillId
			,intItemId = BillDtl.intItemId
			,strDiscountCode = Item.strShortName 
			,strDiscountCodeDescription = Item.strItemNo
			,dblDiscountAmount = BillDtl.dblCost
			,dblShrinkPercent = ISNULL(StorageDiscount.dblShrinkPercent, 0)
			,dblGradeReading =  ISNULL(StorageDiscount.dblGradeReading, 0)			
			,dblAmount = BillDtl.dblTotal 
			,dblTax = BillDtl.dblTax
			,Net = PYMTDTL.dblTotal
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
		JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
		JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = Bill.intBillId
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
	) tbl
GROUP BY intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription


