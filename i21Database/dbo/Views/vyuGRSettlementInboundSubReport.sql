CREATE VIEW [dbo].[vyuGRSettlementInboundSubReport]
AS
	WITH MSPG_123 (intPaymentId, strId, intBillId, intItemId, strDiscountCode, strDiscountCodeDescription, dblDiscountAmount, dblAmount, dblTax, Net, intCustomerStorageId, intInventoryReceiptChargeId)
	AS 
	(
		select 
			intPaymentId				= PYMT.intPaymentId
			,strId						= Bill.strBillId
			,intBillId					= BillDtl.intBillId
			,intItemId					= BillDtl.intItemId
			,strDiscountCode			= Item.strShortName 
			,strDiscountCodeDescription = Item.strItemNo
			,dblDiscountAmount			= BillDtl.dblCost			
			,dblAmount					= BillDtl.dblTotal --+ BillDtl.dblTax
			,dblTax						= BillDtl.dblTax
			,Net						= PYMTDTL.dblTotal
			,intCustomerStorageId		= BillDtl.intCustomerStorageId 
			,intInventoryReceiptChargeId = BillDtl.intInventoryReceiptChargeId
		FROM tblAPPayment PYMT
			JOIN tblAPPaymentDetail PYMTDTL 
				ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill	
				ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl
				ON BillDtl.intBillId = Bill.intBillId
			JOIN tblICItem Item 
				ON BillDtl.intItemId = Item.intItemId
		WHERE Item.strType = 'Other Charge'			
	)
		SELECT 
			intPaymentId
			,strDiscountCode
			,strDiscountCodeDescription
			,WeightedAverageReading	= (SUM(WeightedAverageReading) / SUM(Net))
			,WeightedAverageShrink	= (SUM(WeightedAverageShrink) / SUM(Net))
			,Discount				= SUM(dblDiscountAmount)
			,Amount					= SUM(dblAmount)
			,Tax					= SUM(dblTax)
		FROM	(	
		SELECT  
			intPaymentId
			,strDiscountCode
			,strDiscountCodeDescription
			,Net
			,WeightedAverageReading	= dblGradeReading -- (Net * dblGradeReading)
			,WeightedAverageShrink	= dblShrinkPercent -- (Net * dblShrinkPercent)
			,dblDiscountAmount
			,dblAmount
			,dblTax
		FROM (

				SELECT 
					intPaymentId, 
					strId, 
					intBillId, 
					intItemId, 
					strDiscountCode, 
					strDiscountCodeDescription, 
					dblDiscountAmount, 
					dblAmount, 
					dblTax, 
					Net, 
					intCustomerStorageId, 
					intInventoryReceiptChargeId,
					dblShrinkPercent = (isnull(S1.dblShrinkPercent, 0) * Net) + (isnull(S2.dblShrinkPercent, 0) * Net),
					dblGradeReading = (isnull(S1.dblGradeReading, 0) * Net) + (isnull(S2.dblGradeReading, 0) * Net)

				FROM 
					MSPG_123 as B1
				OUTER APPLY (
					SELECT					
						dblShrinkPercent			= ISNULL(ScaleDiscount.dblShrinkPercent, 0)
						,dblGradeReading			= ISNULL(ScaleDiscount.dblGradeReading, 0)								
					FROM tblICInventoryReceiptCharge INVRCPTCHR 
					LEFT JOIN tblICInventoryReceipt INVRCPT 
						ON INVRCPTCHR.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
					LEFT JOIN (
							SELECT intSourceId
								,intInventoryReceiptId
								,ROW_NUMBER() OVER (PARTITION BY intInventoryReceiptId ORDER BY intSourceId) intRowNum
							FROM tblICInventoryReceiptItem
					) INVRCPTITEM 
						ON INVRCPTITEM.intInventoryReceiptId =INVRCPT.intInventoryReceiptId 
							AND INVRCPTITEM.intRowNum =1
					LEFT JOIN (
								SELECT 
									QM.intTicketId
								   ,DCode.intItemId
								   ,QM.dblGradeReading
								   ,QM.dblShrinkPercent
								FROM tblQMTicketDiscount QM
								JOIN tblGRDiscountScheduleCode DCode 
									ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
								WHERE QM.strSourceType = 'Scale'
					) ScaleDiscount 
						ON ScaleDiscount.intTicketId = INVRCPTITEM.intSourceId 
							AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId 
							AND INVRCPT.intSourceType = 1 
					WHERE B1.intInventoryReceiptChargeId = INVRCPTCHR.intInventoryReceiptChargeId		
				) AS S1
				OUTER APPLY 
				(
					SELECT 
						dblShrinkPercent			= ISNULL(StorageDiscount.dblShrinkPercent, 0)
						,dblGradeReading			= ISNULL(StorageDiscount.dblGradeReading, 0)			
					
					FROM (
								 SELECT 
									 QM.intTicketFileId
									,DCode.intItemId
									,QM.dblGradeReading
									,QM.dblShrinkPercent
								FROM tblQMTicketDiscount QM
								JOIN tblGRDiscountScheduleCode DCode 
									ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
								WHERE QM.strSourceType = 'Storage'
					) StorageDiscount 
						WHERE StorageDiscount.intTicketFileId = B1.intCustomerStorageId 
							AND StorageDiscount.intItemId = B1.intItemId							
	
				) AS S2
		
				

				--WHERE intPaymentId = 63
			) S3
			) S4
GROUP BY intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription
/*SELECT 
	intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription
	,WeightedAverageReading	= (SUM(WeightedAverageReading) / SUM(Net))
	,WeightedAverageShrink	= (SUM(WeightedAverageShrink) / SUM(Net))
	,Discount				= SUM(dblDiscountAmount)
	,Amount					= SUM(dblAmount)
	,Tax					= SUM(dblTax)
FROM (
		SELECT  
			intPaymentId
			,strDiscountCode
			,strDiscountCodeDescription
			,Net
			,WeightedAverageReading	= (Net * dblGradeReading)
			,WeightedAverageShrink	= (Net * dblShrinkPercent)
			,dblDiscountAmount
			,dblAmount
			,dblTax
		FROM (
				SELECT
					 intPaymentId				= PYMT.intPaymentId
					,strId						= Bill.strBillId
					,intBillId					= BillDtl.intBillId
					,intItemId					= BillDtl.intItemId
					,strDiscountCode			= Item.strShortName 
					,strDiscountCodeDescription	= Item.strItemNo
					,dblDiscountAmount			= BillDtl.dblTotal
					,dblShrinkPercent			= ISNULL(ScaleDiscount.dblShrinkPercent, 0)
					,dblGradeReading			= ISNULL(ScaleDiscount.dblGradeReading, 0)			
					,dblAmount					= BillDtl.dblTotal + BillDtl.dblTax
					,dblTax						= BillDtl.dblTax
					,Net						= PYMTDTL.dblTotal		
				FROM tblAPPayment PYMT
				JOIN tblAPPaymentDetail PYMTDTL 
					ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				JOIN tblAPBill Bill	
					ON PYMTDTL.intBillId = Bill.intBillId
				JOIN tblAPBillDetail BillDtl
					ON BillDtl.intBillId = Bill.intBillId
				JOIN tblICItem Item 
					ON BillDtl.intItemId = Item.intItemId
				LEFT JOIN tblICInventoryReceiptCharge INVRCPTCHR 
					ON BillDtl.intInventoryReceiptChargeId = INVRCPTCHR.intInventoryReceiptChargeId		
				LEFT JOIN tblICInventoryReceipt INVRCPT 
					ON INVRCPTCHR.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
				LEFT JOIN (
						SELECT intSourceId
							,intInventoryReceiptId
							,ROW_NUMBER() OVER (PARTITION BY intInventoryReceiptId ORDER BY intSourceId) intRowNum
						FROM tblICInventoryReceiptItem
				) INVRCPTITEM 
					ON INVRCPTITEM.intInventoryReceiptId =INVRCPT.intInventoryReceiptId 
						AND INVRCPTITEM.intRowNum =1
				LEFT JOIN (
							SELECT 
								QM.intTicketId
							   ,DCode.intItemId
							   ,QM.dblGradeReading
							   ,QM.dblShrinkPercent
							FROM tblQMTicketDiscount QM
							JOIN tblGRDiscountScheduleCode DCode 
								ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
							WHERE QM.strSourceType = 'Scale'
				) ScaleDiscount 
					ON ScaleDiscount.intTicketId = INVRCPTITEM.intSourceId 
						AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId 
						AND INVRCPT.intSourceType = 1 
				WHERE Item.strType = 'Other Charge'
			
				UNION ALL
		
				SELECT DISTINCT
					intPaymentId				= PYMT.intPaymentId
					,strId						= Bill.strBillId
					,intBillId					= BillDtl.intBillId
					,intItemId					= BillDtl.intItemId
					,strDiscountCode			= Item.strShortName 
					,strDiscountCodeDescription = Item.strItemNo
					,dblDiscountAmount			= BillDtl.dblCost
					,dblShrinkPercent			= ISNULL(StorageDiscount.dblShrinkPercent, 0)
					,dblGradeReading			= ISNULL(StorageDiscount.dblGradeReading, 0)			
					,dblAmount					= BillDtl.dblTotal + BillDtl.dblTax
					,dblTax						= BillDtl.dblTax
					,Net						= PYMTDTL.dblTotal
				FROM tblAPPayment PYMT
				JOIN tblAPPaymentDetail PYMTDTL 
					ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				JOIN tblAPBill Bill 
					ON PYMTDTL.intBillId = Bill.intBillId
				JOIN tblAPBillDetail BillDtl 
					ON BillDtl.intBillId = Bill.intBillId
				JOIN tblICItem Item 
					ON BillDtl.intItemId = Item.intItemId 
						AND Item.strType = 'Other Charge'
				JOIN tblGRStorageHistory StrgHstry 
					ON Bill.intBillId = StrgHstry.intBillId
				LEFT JOIN (
							 SELECT 
								 QM.intTicketFileId
								,DCode.intItemId
								,QM.dblGradeReading
								,QM.dblShrinkPercent
							FROM tblQMTicketDiscount QM
							JOIN tblGRDiscountScheduleCode DCode 
								ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
							WHERE QM.strSourceType = 'Storage'
				) StorageDiscount 
					ON StorageDiscount.intTicketFileId = BillDtl.intCustomerStorageId 
						AND StorageDiscount.intItemId = BillDtl.intItemId
					WHERE Item.strType = 'Other Charge'
			) tbl
	) tbl
GROUP BY intPaymentId
	,strDiscountCode
	,strDiscountCodeDescription*/