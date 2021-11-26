CREATE VIEW [dbo].[vyuGRSettlementInboundSubReport]
AS
	
	-- We are using this view to directly insert table to an API Export table
	-- If there are changes in the view please update the insert in uspGRAPISettlementReportExport as well

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
			,dblDiscountAmount			= round(BillDtl.dblCost, 2)-- * BillDtl.dblQtyReceived
			,dblAmount					= BillDtl.dblTotal --+ BillDtl.dblTax
			,dblTax						= BillDtl.dblTax
			,Net						= ISNULL(PYMTDTL.dblTotal,0)
			,intCustomerStorageId		= BillDtl.intCustomerStorageId 
			,intInventoryReceiptChargeId = BillDtl.intInventoryReceiptChargeId
		FROM tblAPPayment PYMT
			JOIN tblAPPaymentDetail PYMTDTL 
				ON PYMT.intPaymentId = PYMTDTL.intPaymentId					
					and PYMTDTL.dblPayment <> 0
			JOIN tblAPBill Bill	
				ON PYMTDTL.intBillId = Bill.intBillId --and intTransactionType = 1
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
			,WeightedAverageReading	= CASE WHEN ISNULL(SUM(Net),0) = 0 THEN 0 ELSE (SUM(WeightedAverageReading) / SUM(Net)) END
			,WeightedAverageShrink	= CASE WHEN ISNULL(SUM(Net),0) = 0 THEN 0 ELSE  (SUM(WeightedAverageShrink) / SUM(Net)) END
			,Discount				= CASE WHEN ISNULL(SUM(Net),0) = 0 THEN 0 ELSE  (SUM(dblDiscountAmount) / SUM(Net)) END
			-- ,Discount				= (dblDiscountAmount)
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
					[dblDiscountAmount] = (isnull(S1.dblDiscountAmount, 0) * Net) + (isnull(S2.dblDiscountAmount, 0) * Net), 
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
						,dblDiscountAmount			= ISNULL(ScaleDiscount.dblDiscountAmount, 0)
					FROM tblICInventoryReceiptCharge INVRCPTCHR 
					LEFT JOIN tblICInventoryReceipt INVRCPT 
						ON INVRCPTCHR.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
					-- LEFT JOIN (
					-- 		SELECT intSourceId
					-- 			,intInventoryReceiptId
					-- 			,ROW_NUMBER() OVER (PARTITION BY intInventoryReceiptId ORDER BY intSourceId) intRowNum
					-- 		FROM tblICInventoryReceiptItem
					-- ) INVRCPTITEM 
					-- 	ON INVRCPTITEM.intInventoryReceiptId =INVRCPT.intInventoryReceiptId 
					-- 		AND INVRCPTITEM.intRowNum =1
					LEFT JOIN (
							SELECT MIN(intSourceId) intSourceId
								,intInventoryReceiptId
							FROM tblICInventoryReceiptItem
							GROUP BY intInventoryReceiptId
					) INVRCPTITEM 
						ON INVRCPTITEM.intInventoryReceiptId =INVRCPT.intInventoryReceiptId
					LEFT JOIN (
								SELECT 
									QM.intTicketId
								   ,isnull(QMII.intItemId, DCode.intItemId) as intItemId
								   ,QM.dblGradeReading
								   ,QM.dblShrinkPercent
								   ,QM.dblDiscountAmount
								FROM tblQMTicketDiscount QM								
								LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
									on QM.intTicketDiscountId = QMII.intTicketDiscountId
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
						,dblDiscountAmount			= ISNULL(StorageDiscount.dblDiscountAmount, 0)
					FROM (
								 SELECT 
									 QM.intTicketFileId
									,isnull(QMII.intItemId, DCode.intItemId) as intItemId
									,QM.dblGradeReading
									,QM.dblShrinkPercent
									,QM.dblDiscountAmount
								FROM tblQMTicketDiscount QM
								LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
									on QM.intTicketDiscountId = QMII.intTicketDiscountId
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
	-- ,dblDiscountAmount
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
