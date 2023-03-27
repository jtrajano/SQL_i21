CREATE VIEW [dbo].[vyuGRSettlementInboundSubReport]
AS
	
	-- We are using this view to directly insert table to an API Export table
	-- If there are changes in the view please update the insert in uspGRAPISettlementReportExport as well

	WITH MSPG_123 (intPaymentId, strId, intBillId, intItemId, strDiscountCode, strDiscountCodeDescription, dblDiscountAmount, dblAmount, dblTax, Net, intCustomerStorageId, intInventoryReceiptChargeId,intScaleTicketId,dblItemQty,dblGradeReading,dblShrinkage)
	AS 
	(
		select 
			intPaymentId				= PYMT.intPaymentId
			,strId						= Bill.strBillId
			,intBillId					= BillDtl.intBillId
			,intItemId					= BillDtl.intItemId
			,strDiscountCode			= Item.strShortName
			,strDiscountCodeDescription = Item.strItemNo
			,dblDiscountAmount			= round(BillDtl.dblCost, 2)
			,dblAmount					= BillDtl.dblTotal
			,dblTax						= BillDtl.dblTax
			,Net						= ISNULL(PYMTDTL.dblTotal,0)
			,intCustomerStorageId		= BillDtl.intCustomerStorageId 
			,intInventoryReceiptChargeId = BillDtl.intInventoryReceiptChargeId
			,intScaleTicketId			= BillDtl.intScaleTicketId
			,dblItemQty					= InvItemQty.dblQty
			,dblGradeReading			= 0
			,dblShrinkage				= 0
			--,QM.*
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
		JOIN (
			SELECT BD.intBillId
				,dblQty = SUM(BD.dblQtyReceived)
			FROM tblAPBillDetail BD
			INNER JOIN tblICItem IC
				ON IC.intItemId = BD.intItemId
					AND IC.strType = 'Inventory'
			GROUP BY BD.intBillId
		)InvItemQty
			ON InvItemQty.intBillId = Bill.intBillId
		WHERE Item.strType = 'Other Charge'

		UNION ALL

		--Discounts that have grade reading but no discount amount/due
		SELECT
			intPaymentId				= Bill.intPaymentId
			,strId						= Bill.strBillId
			,intBillId					= Bill.intBillId
			,intItemId					= QM.intItemId
			,strDiscountCode			= QM.strShortName
			,strDiscountCodeDescription = QM.strItemNo
			,dblDiscountAmount			= 0
			,dblAmount					= 0
			,dblTax						= 0
			,Net						= ISNULL(Bill.dblTotal,0)
			,intCustomerStorageId		= NULL
			,intInventoryReceiptChargeId = NULL
			,intScaleTicketId			= Bill.intScaleTicketId
			,dblItemQty					= InvItemQty.dblQty
			,dblGradeReading			= QM.dblGradeReading
			,dblShrinkage				= QM.dblShrinkPercent
		FROM (
			SELECT DISTINCT BillDtl.intScaleTicketId
				,BillDtl.intCustomerStorageId
				,Bill.strBillId
				,PYMT.intPaymentId
				,Bill.intBillId
				,Bill.dblTotal
			FROM tblAPPayment PYMT
			INNER JOIN tblAPPaymentDetail PYMTDTL 
				ON PYMT.intPaymentId = PYMTDTL.intPaymentId					
					and PYMTDTL.dblPayment <> 0
			INNER JOIN tblAPBill Bill	
				ON PYMTDTL.intBillId = Bill.intBillId --and intTransactionType = 1
			INNER JOIN tblAPBillDetail BillDtl
				ON BillDtl.intBillId = Bill.intBillId
		) Bill
		INNER JOIN (
			SELECT BD.intBillId
				,dblQty = SUM(BD.dblQtyReceived)
			FROM tblAPBillDetail BD
			INNER JOIN tblICItem IC
				ON IC.intItemId = BD.intItemId
					AND IC.strType = 'Inventory'
			GROUP BY BD.intBillId
		)InvItemQty
			ON InvItemQty.intBillId = Bill.intBillId
		OUTER APPLY (
			SELECT QM.dblGradeReading
				,QM.dblShrinkPercent
				,Item2.strShortName
				,Item2.strItemNo
				,Item2.intItemId
				,QM.strSourceType
				,QM.intTicketId
				,QM.intTicketFileId
			FROM tblQMTicketDiscount QM
			INNER JOIN tblGRDiscountScheduleCode DCode 
				ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
			INNER JOIN tblICItem Item2 
				ON Item2.intItemId = DCode.intItemId
			WHERE QM.dblGradeReading <> 0
				AND (QM.strSourceType = (CASE WHEN Bill.intCustomerStorageId IS NULL THEN 'Scale' ELSE 'Storage' END)
				AND (QM.intTicketId = (CASE WHEN Bill.intCustomerStorageId IS NULL THEN Bill.intScaleTicketId ELSE QM.intTicketId END)
						OR
					QM.intTicketFileId = (CASE WHEN Bill.intCustomerStorageId IS NULL THEN QM.intTicketFileId ELSE Bill.intCustomerStorageId END))
				)
				AND Item2.intItemId NOT IN (SELECT intItemId FROM tblAPBillDetail WHERE intBillId = Bill.intBillId)
		) QM

		UNION ALL
		-- This will include other charges from applied vendor prepayments and debit memos
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
			,intScaleTicketId			= BillDtl.intScaleTicketId
			,1
			,dblGradeReading			= 0
			,dblShrinkage				= 0
		FROM tblAPPayment PYMT
			JOIN tblAPPaymentDetail PYMTDTL 
				ON PYMT.intPaymentId = PYMTDTL.intPaymentId					
					and PYMTDTL.dblPayment <> 0
			JOIN tblAPBill Bill	
				ON PYMTDTL.intBillId = Bill.intBillId --and intTransactionType = 1
			JOIN tblAPAppliedPrepaidAndDebit APAD
				ON Bill.intBillId = APAD.intBillId
				AND Bill.intTransactionType NOT IN (13, 3)
				AND APAD.ysnApplied = 1
			JOIN tblAPBill BillAPAD
				ON BillAPAD.intBillId = APAD.intTransactionId
			JOIN tblAPBillDetail BillDtl
				ON BillDtl.intBillId = BillAPAD.intBillId
			JOIN tblICItem Item
				ON BillDtl.intItemId = Item.intItemId
		WHERE Item.strType = 'Other Charge'
	)

			SELECT
				intPaymentId
				,strDiscountCode
				,strDiscountCodeDescription
				,WeightedAverageReading	= CASE WHEN ISNULL(SUM(dblItemQty),0) = 0 THEN 0 ELSE (SUM(WeightedAverageReading) / SUM(dblItemQty)) END
				,WeightedAverageShrink	= CASE WHEN ISNULL(SUM(dblItemQty),0) = 0 THEN 0 ELSE  (SUM(WeightedAverageShrink) / SUM(dblItemQty)) END
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
				,dblItemQty
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
						dblShrinkPercent = (isnull(S1.dblShrinkPercent, 0) * dblItemQty) + (isnull(S2.dblShrinkPercent, 0) * dblItemQty) + (isnull(B1.dblShrinkage, 0) * dblItemQty),--(isnull(S5.dblShrinkPercent, 0) * Net),
						dblGradeReading = (isnull(S1.dblGradeReading, 0) * dblItemQty) + (isnull(S2.dblGradeReading, 0) * dblItemQty) + (isnull(B1.dblGradeReading, 0) * dblItemQty)--(isnull(S5.dblGradeReading, 0) * dblItemQty)
						,dblItemQty
					FROM MSPG_123 as B1
					OUTER APPLY (
						SELECT					
							dblShrinkPercent			= ISNULL(ScaleDiscount.dblShrinkPercent, 0)
							,dblGradeReading			= ISNULL(ScaleDiscount.dblGradeReading, 0)								
							,dblDiscountAmount			= ISNULL(ScaleDiscount.dblDiscountAmount, 0)
						FROM tblICInventoryReceiptCharge INVRCPTCHR 
						LEFT JOIN tblICInventoryReceipt INVRCPT 
							ON INVRCPTCHR.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
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
					--OUTER APPLY 
					--(
					--	SELECT 
					--		dblShrinkPercent			= ISNULL(StorageDiscount.dblShrinkPercent, 0)
					--		,dblGradeReading			= ISNULL(StorageDiscount.dblGradeReading, 0)			
					--		,dblDiscountAmount			= ISNULL(StorageDiscount.dblDiscountAmount, 0)
					--	FROM (
					--				 SELECT 
					--					 QM.intTicketFileId
					--					 ,QM.intTicketId
					--					,DCode.intItemId as intItemId
					--					,QM.dblGradeReading
					--					,QM.dblShrinkPercent
					--					,QM.dblDiscountAmount
					--				FROM tblQMTicketDiscount QM
					--				JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					--				JOIN tblICItem Item2 ON Item2.intItemId = DCode.intItemId
					--				WHERE QM.strSourceType = (CASE WHEN B1.intCustomerStorageId IS NULL THEN 'Scale' ELSE 'Storage' END)									
					--					AND QM.dblGradeReading <> 0
					--	) StorageDiscount 
					--		WHERE (StorageDiscount.intTicketId = (CASE WHEN B1.intCustomerStorageId IS NULL THEN B1.intScaleTicketId ELSE StorageDiscount.intTicketId END)
					--							OR
					--						StorageDiscount.intTicketFileId = (CASE WHEN B1.intCustomerStorageId IS NULL THEN StorageDiscount.intTicketFileId ELSE B1.intCustomerStorageId END))
					--			AND StorageDiscount.intItemId = B1.intItemId												   
					--			AND (B1.intInventoryReceiptChargeId IS NULL AND B1.intCustomerStorageId IS NULL)
					--) AS S5
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
GO


