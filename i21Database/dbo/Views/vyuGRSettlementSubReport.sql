CREATE VIEW [dbo].[vyuGRSettlementSubReport]
AS

	-- We are using this view to directly insert table to an API Export table
	-- If there are changes in the view please update the insert in uspGRAPISettlementReportExport as well
	-- any modification here should be applied to vyuGRSettlementSubNoTaxReport as well

SELECT 
	intBillDetailId
	,strId
	,intItemId
	,strDiscountCode
	,strDiscountCodeDescription
	,strTaxClass
	,(dblDiscountAmount) dblDiscountAmount
	,(dblShrinkPercent) dblShrinkPercent
	,ISNULL(dblGradeReading,'N/A') dblGradeReading
	,dblAmount dblAmount
	,(dblTax) dblTax
	,(dblNetTotal) dblNetTotal
FROM
(
	--SCALE
	 SELECT 
		 t1.intBillDetailId
		,t3.strId
		,t3.intBillId
		,t3.intItemId
		,t3.strDiscountCode
		,t3.strDiscountCodeDescription
		,t3.dblDiscountAmount dblDiscountAmount -- * (t1.dblQtyOrdered / t2.dblTotalQty) 
		,t3.dblShrinkPercent  dblShrinkPercent -- * (t1.dblQtyOrdered / t2.dblTotalQty)
		,t3.dblGradeReading
		,t3.dblAmount * (t1.dblQtyOrdered / t2.dblTotalQty) dblAmount	
		,t3.intContractDetailId
		,t3.dblTax * (t1.dblQtyOrdered / t2.dblTotalQty) dblTax
		,t3.dblNetTotal * (t1.dblQtyOrdered / t2.dblTotalQty) dblNetTotal
		,t3.strTaxClass
	FROM (
			 SELECT 
				 BillDtl.intBillDetailId
				,BillDtl.dblQtyOrdered
				,Bill.intBillId
			FROM tblAPBillDetail BillDtl
			JOIN tblAPBill Bill 
				ON BillDtl.intBillId = Bill.intBillId 
			JOIN tblICItem Item 
				ON BillDtl.intItemId = Item.intItemId 
					AND Item.strType <> 'Other Charge' 
			WHERE BillDtl.intContractDetailId IS NULL
		  ) t1
	LEFT JOIN (
				 SELECT 
					A.intBillId
					,SUM(dblQtyOrdered) dblTotalQty
				 FROM tblAPBillDetail A
				 JOIN tblICItem B 
					ON A.intItemId = B.intItemId 
						AND B.strType <> 'Other Charge'
				 WHERE A.intContractDetailId IS NULL
				 GROUP BY A.intBillId
			  ) t2 ON t1.intBillId = t2.intBillId
	LEFT JOIN
	(
		SELECT * 
		FROM
		(
		     SELECT 
				 strId						= Bill.strBillId
				,intBillId					= BillDtl.intBillId
				,intBillDetailId			= BillDtl.intBillDetailId
				,intItemId					= BillDtl.intItemId
				,strDiscountCode			= Item.strShortName
				,strDiscountCodeDescription	= Item.strItemNo
				,dblDiscountAmount			= CASE 
								 				WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN 
								 																CASE 
								 																	WHEN INVRCPTCHR.strCostMethod = 'Per Unit' THEN INVRCPTCHR.dblRate
								 																	WHEN INVRCPTCHR.strCostMethod = 'Amount' THEN INVRCPTCHR.dblAmount
								 																END
								 				ELSE BillDtl.dblCost
											 END
			
				,dblShrinkPercent			= CASE 
												WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN ISNULL(ScaleDiscount.dblShrinkPercent, 0)
												WHEN StrgHstry.intBillId IS NOT NULL THEN ISNULL(StorageDiscount.dblShrinkPercent, 0)
												ELSE 0
											END
			
				,CASE 
												WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(ScaleDiscount.dblGradeReading)
												WHEN StrgHstry.intBillId IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(StorageDiscount.dblGradeReading)
												ELSE 'N/A'
											END COLLATE Latin1_General_CI_AS as dblGradeReading

				,dblAmount					= BillDtl.dblTotal
				,intContractDetailId		= ISNULL(BillDtl.intContractDetailId, 0)
				,dblTax						= BillDtl.dblTax
				,dblNetTotal				= BillDtl.dblTotal + BillDtl.dblTax
				,strTaxClass = TaxClass.strTaxClass
		FROM tblAPBillDetail BillDtl
		JOIN tblAPBill Bill 
			ON BillDtl.intBillId = Bill.intBillId --and Bill.intTransactionType = 1
		JOIN tblICItem Item 
			ON BillDtl.intItemId = Item.intItemId
		LEFT JOIN vyuAPBillDetailTax Tax 
			ON BillDtl.intBillDetailId = Tax.intBillDetailId
		LEFT JOIN tblSMTaxClass TaxClass 
			ON Tax.intTaxClassId = TaxClass.intTaxClassId
		LEFT JOIN tblICInventoryReceiptCharge INVRCPTCHR 
			ON INVRCPTCHR.intInventoryReceiptChargeId = BillDtl.intInventoryReceiptChargeId	
		LEFT JOIN tblICInventoryReceipt INVRCPT 
			ON INVRCPT.intInventoryReceiptId = INVRCPTCHR.intInventoryReceiptId
		LEFT JOIN tblGRStorageHistory StrgHstry 
			ON StrgHstry.intBillId = Bill.intBillId
		LEFT JOIN (
				    SELECT 
						QM.intTicketId
					   ,isnull(QMII.intItemId, DCode.intItemId) as intItemId
					   ,QM.dblGradeReading
					   ,QM.dblShrinkPercent
					FROM tblQMTicketDiscount QM
					LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
						on QM.intTicketDiscountId = QMII.intTicketDiscountId
					JOIN tblGRDiscountScheduleCode DCode 
						ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					WHERE QM.strSourceType = 'Scale'
			  ) ScaleDiscount 
			  ON ScaleDiscount.intTicketId = BillDtl.intScaleTicketId 
				AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId AND INVRCPT.intSourceType = 1		
		LEFT JOIN (
					 SELECT 
						 QM.intTicketFileId
					   	,isnull(QMII.intItemId, DCode.intItemId) as intItemId
						,QM.dblGradeReading
						,QM.dblShrinkPercent
					FROM tblQMTicketDiscount QM
					LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
						on QM.intTicketDiscountId = QMII.intTicketDiscountId
					JOIN tblGRDiscountScheduleCode DCode 
						ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					WHERE QM.strSourceType = 'Storage'
			  ) StorageDiscount 
				ON StorageDiscount.intTicketFileId = BillDtl.intCustomerStorageId 
					AND StorageDiscount.intItemId = BillDtl.intItemId
		WHERE Item.strType = 'Other Charge' 
			AND ISNULL(BillDtl.intContractDetailId, 0) = 0
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
			,intContractDetailId
			,dblTax
			,dblNetTotal
			,strTaxClass
	) t3 
		ON t3.intBillId = t2.intBillId 
			AND t3.intBillId = t1.intBillId
	WHERE t3.intItemId IS NOT NULL

	UNION ALL

	--CONTRACT
	SELECT 
		 t3.intBillDetailIdItem
		,t3.strId
		,t3.intBillId
		,t3.intItemId
		,t3.strDiscountCode
		,t3.strDiscountCodeDescription
		,t3.dblDiscountAmount --* (t1.dblQtyOrdered / t2.dblTotalQty) dblDiscountAmount
		,t3.dblShrinkPercent --* (t1.dblQtyOrdered / t2.dblTotalQty) dblShrinkPercent
		,t3.dblGradeReading
		,t3.dblAmount --* (t1.dblQtyOrdered / t2.dblTotalQty) dblAmount	
		,t3.intContractDetailId
		,t3.dblTax --* (t1.dblQtyOrdered / t2.dblTotalQty) dblTax
		,t3.dblNetTotal --* (t1.dblQtyOrdered / t2.dblTotalQty) dblNetTotal
		,t3.strTaxClass
	FROM (
			 SELECT 
				 strId						= Bill.strBillId
				,intBillId					= BillDtl2.intBillId
				,intBillDetailId			= BillDtl2.intBillDetailId
				,intItemId					= BillDtl2.intItemId
				,intBillDetailIdItem		= BillDtl.intBillDetailId
				,strDiscountCode			= Item2.strShortName
				,strDiscountCodeDescription	= Item2.strItemNo
				,dblDiscountAmount			= CASE 
							 					WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN 
							 																	CASE 
							 																		WHEN INVRCPTCHR.strCostMethod = 'Per Unit' THEN INVRCPTCHR.dblRate
							 																		WHEN INVRCPTCHR.strCostMethod = 'Amount'   THEN INVRCPTCHR.dblAmount
							 																	END
							 					ELSE BillDtl2.dblCost
											 END
				,dblShrinkPercent			= CASE 
												WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN ISNULL(ScaleDiscount.dblShrinkPercent, 0)
												WHEN StrgHstry.intBillId	  IS NOT NULL THEN ISNULL(StorageDiscount.dblShrinkPercent, 0)
												ELSE 0
											END		
				,CASE 
												WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(ScaleDiscount.dblGradeReading)
												WHEN StrgHstry.intBillId	  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(StorageDiscount.dblGradeReading)
												ELSE 'N/A'
											END  COLLATE Latin1_General_CI_AS as dblGradeReading

				,dblAmount					= BillDtl2.dblTotal
				,intContractDetailId		= ISNULL(BillDtl2.intContractDetailId, 0)
				,dblTax						= BillDtl2.dblTax
				,dblNetTotal				= BillDtl2.dblTotal + BillDtl2.dblTax
				,strTaxClass = TaxClass.strTaxClass
				,BillDtl2.intInventoryReceiptItemId
				,BillDtl2.intLinkingId
				,BillDtl.dblQtyReceived
		FROM tblAPBillDetail BillDtl
		JOIN tblAPBill Bill 
			ON BillDtl.intBillId = Bill.intBillId
		JOIN tblICItem Item 
			ON BillDtl.intItemId = Item.intItemId 
			AND Item.strType <> 'Other Charge'
			AND BillDtl.intContractDetailId IS NOT NULL
		LEFT JOIN tblAPBillDetail BillDtl2
			ON BillDtl2.intBillId = Bill.intBillId
			AND isnull(BillDtl2.intInventoryReceiptItemId, isnull(BillDtl.intInventoryReceiptItemId, 0)) = isnull(BillDtl.intInventoryReceiptItemId, 0)
			AND ((ISNULL(BillDtl2.intLinkingId, 0) = ISNULL(BillDtl.intLinkingId, 0) OR ISNULL(BillDtl2.intLinkingId,-90) = -90) and (BillDtl.dblQtyReceived = ABS(BillDtl2.dblQtyReceived) OR ABS(BillDtl2.dblQtyReceived) = 1))
		LEFT JOIN tblAPBill Bill2 
			ON BillDtl2.intBillId = Bill2.intBillId --and Bill.intTransactionType = 1
		LEFT JOIN tblICItem Item2 
			ON BillDtl2.intItemId = Item2.intItemId
		LEFT JOIN vyuAPBillDetailTax Tax 
			ON BillDtl2.intBillDetailId = Tax.intBillDetailId
		LEFT JOIN tblSMTaxClass TaxClass 
			ON Tax.intTaxClassId = TaxClass.intTaxClassId
		LEFT JOIN tblICInventoryReceiptCharge INVRCPTCHR 
			ON INVRCPTCHR.intInventoryReceiptChargeId = BillDtl2.intInventoryReceiptChargeId	
		LEFT JOIN tblICInventoryReceipt INVRCPT 
			ON INVRCPT.intInventoryReceiptId = INVRCPTCHR.intInventoryReceiptId
		LEFT JOIN tblGRStorageHistory StrgHstry 
			ON StrgHstry.intBillId = Bill.intBillId	
				and (BillDtl.intContractHeaderId is null or (BillDtl.intContractHeaderId = isnull(StrgHstry.intContractHeaderId, 0) ) )
		LEFT JOIN (
					SELECT 
						QM.intTicketId
					   ,isnull(QMII.intItemId, DCode.intItemId) as intItemId
					   ,QM.dblGradeReading
					   ,QM.dblShrinkPercent
					FROM tblQMTicketDiscount QM
					LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
						on QM.intTicketDiscountId = QMII.intTicketDiscountId						
					JOIN tblGRDiscountScheduleCode DCode 
						ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					WHERE QM.strSourceType = 'Scale'
			  ) ScaleDiscount 
				ON ScaleDiscount.intTicketId = BillDtl2.intScaleTicketId 
					AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId 
					AND INVRCPT.intSourceType = 1	
		LEFT JOIN (
					 SELECT 
						 QM.intTicketFileId
					  	,isnull(QMII.intItemId, DCode.intItemId) as intItemId
						,QM.dblGradeReading
						,QM.dblShrinkPercent
					FROM tblQMTicketDiscount QM
					LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
						on QM.intTicketDiscountId = QMII.intTicketDiscountId	
					JOIN tblGRDiscountScheduleCode DCode 
						ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					WHERE QM.strSourceType = 'Storage'
			  ) StorageDiscount 
				ON StorageDiscount.intTicketFileId = BillDtl2.intCustomerStorageId 
					AND StorageDiscount.intItemId = BillDtl2.intItemId
		WHERE Item2.strType = 'Other Charge'
			--AND ((StrgHstry.intContractHeaderId IS NOT NULL) --settlement with contract
				--OR (BillDtl.intInventoryReceiptChargeId IS NOT NULL AND BillDtl.intContractDetailId IS NOT NULL)) 
   )t3 
	WHERE t3.intItemId IS NOT NULL 
)t	
