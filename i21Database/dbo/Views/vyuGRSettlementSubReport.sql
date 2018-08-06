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
,ISNULL(dblGradeReading,'N/A')dblGradeReading
,SUM(dblAmount) dblAmount
,SUM(dblTax) dblTax
,SUM(dblNetTotal) dblNetTotal
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
	,t3.dblDiscountAmount * (t1.dblQtyOrdered / t2.dblTotalQty) dblDiscountAmount
	,t3.dblShrinkPercent * (t1.dblQtyOrdered / t2.dblTotalQty) dblShrinkPercent
	,t3.dblGradeReading
	,t3.dblAmount * (t1.dblQtyOrdered / t2.dblTotalQty)dblAmount	
	,t3.intContractDetailId
	,CASE WHEN t3.intContractDetailId = 0 THEN t3.dblTax ELSE 0 END AS dblTax
	,t3.dblNetTotal* (t1.dblQtyOrdered / t2.dblTotalQty) dblNetTotal
	FROM (
			 SELECT 
			 BillDtl.intBillDetailId
			,BillDtl.dblQtyOrdered
			,Bill.intBillId
			FROM tblAPBillDetail BillDtl
			JOIN tblAPBill Bill ON BillDtl.intBillId = Bill.intBillId 
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge' 
			WHERE BillDtl.intContractDetailId IS NULL
		  ) t1
	LEFT JOIN (
				 SELECT A.intBillId
				,SUM(dblQtyOrdered) dblTotalQty
				 FROM tblAPBillDetail A
				 JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType <> 'Other Charge'
				 WHERE A.intContractDetailId IS NULL
				 GROUP BY A.intBillId
			  ) t2 ON t1.intBillId = t2.intBillId
	LEFT JOIN

	(
		SELECT * 
		FROM
		(
		     SELECT 
			 strId = Bill.strBillId
			,intBillId = BillDtl.intBillId
			,intBillDetailId  = BillDtl.intBillDetailId
			,intItemId = BillDtl.intItemId
			,strDiscountCode =Item.strShortName
			,strDiscountCodeDescription= Item.strItemNo
			,dblDiscountAmount = CASE 
								 	WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN 
								 													CASE 
								 														WHEN INVRCPTCHR.strCostMethod = 'Per Unit' THEN INVRCPTCHR.dblRate
								 														WHEN INVRCPTCHR.strCostMethod = 'Amount'   THEN INVRCPTCHR.dblAmount
								 													END
								 	ELSE BillDtl.dblCost
								 END
			
			,dblShrinkPercent = CASE 
									WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN ISNULL(ScaleDiscount.dblShrinkPercent, 0)
									WHEN StrgHstry.intBillId	  IS NOT NULL THEN ISNULL(StorageDiscount.dblShrinkPercent, 0)
									ELSE 0
								END
			
			,dblGradeReading =  CASE 
									WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(ScaleDiscount.dblGradeReading)
									WHEN StrgHstry.intBillId	  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(StorageDiscount.dblGradeReading)
									ELSE 'N/A'
								END

			,dblAmount = BillDtl.dblTotal
			,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0)
			,dblTax = BillDtl.dblTax
			,dblNetTotal = BillDtl.dblTotal+ BillDtl.dblTax

		FROM tblAPBillDetail BillDtl
		JOIN tblAPBill Bill ON BillDtl.intBillId = Bill.intBillId
		JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
		LEFT JOIN tblICInventoryReceiptCharge INVRCPTCHR ON INVRCPTCHR.intInventoryReceiptChargeId = BillDtl.intInventoryReceiptChargeId	
		LEFT JOIN tblICInventoryReceipt INVRCPT ON INVRCPT.intInventoryReceiptId = INVRCPTCHR.intInventoryReceiptId
		LEFT JOIN tblGRStorageHistory StrgHstry ON StrgHstry.intBillId = Bill.intBillId
		
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
		 ON ScaleDiscount.intTicketId = BillDtl.intScaleTicketId AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId AND INVRCPT.intSourceType = 1
		
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

		WHERE  Item.strType = 'Other Charge' AND ISNULL(BillDtl.intContractDetailId, 0) = 0
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
	,dblNetTotal )t3 ON  t3.intBillId =t2.intBillId AND t3.intBillId =t1.intBillId
	WHERE t3.intItemId IS NOT NULL 

	UNION 

	--CONTRACT
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
	,t3.intContractDetailId
	,CASE WHEN t3.intContractDetailId <> 0 THEN t3.dblTax ELSE 0 END AS dblTax
	,t3.dblNetTotal* (t1.dblQtyOrdered / t2.dblTotalQty) dblNetTotal
	FROM (
			 SELECT 
			 BillDtl.intBillDetailId
			,BillDtl.dblQtyOrdered
			,Bill.intBillId
			FROM tblAPBillDetail BillDtl
			JOIN tblAPBill Bill ON BillDtl.intBillId = Bill.intBillId
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId AND Item.strType <> 'Other Charge'
			WHERE BillDtl.intContractDetailId IS NOT NULL
		  ) t1
	LEFT JOIN (
			 SELECT A.intBillId
			,SUM(dblQtyOrdered) dblTotalQty
			 FROM tblAPBillDetail A
			 JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType <> 'Other Charge'
			 WHERE A.intContractDetailId IS NOT NULL
			 GROUP BY A.intBillId
		  ) t2 ON t1.intBillId = t2.intBillId
	LEFT JOIN

	(
	   SELECT * FROM
	  ( 
		 SELECT 
		 strId = Bill.strBillId
		,intBillId = BillDtl.intBillId
		,intBillDetailId  = BillDtl.intBillDetailId
		,intItemId = BillDtl.intItemId
		,strDiscountCode =Item.strShortName
		,strDiscountCodeDescription= Item.strItemNo
		,dblDiscountAmount = CASE 
							 	WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN 
							 													CASE 
							 														WHEN INVRCPTCHR.strCostMethod = 'Per Unit' THEN INVRCPTCHR.dblRate
							 														WHEN INVRCPTCHR.strCostMethod = 'Amount'   THEN INVRCPTCHR.dblAmount
							 													END
							 	ELSE BillDtl.dblCost
							 END
		
		,dblShrinkPercent = CASE 
								WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN ISNULL(ScaleDiscount.dblShrinkPercent, 0)
								WHEN StrgHstry.intBillId	  IS NOT NULL THEN ISNULL(StorageDiscount.dblShrinkPercent, 0)
								ELSE 0
							END
		
		,dblGradeReading =  CASE 
								WHEN INVRCPTCHR.strCostMethod IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(ScaleDiscount.dblGradeReading)
								WHEN StrgHstry.intBillId	  IS NOT NULL THEN dbo.fnRemoveTrailingZeroes(StorageDiscount.dblGradeReading)
								ELSE 'N/A'
							END

		,dblAmount = BillDtl.dblTotal
		,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0)
		,dblTax = BillDtl.dblTax
		,dblNetTotal = BillDtl.dblTotal+ BillDtl.dblTax

	FROM tblAPBillDetail BillDtl
	JOIN tblAPBill Bill ON BillDtl.intBillId = Bill.intBillId
	JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
	LEFT JOIN tblICInventoryReceiptCharge INVRCPTCHR ON INVRCPTCHR.intInventoryReceiptChargeId = BillDtl.intInventoryReceiptChargeId	
	LEFT JOIN tblICInventoryReceipt INVRCPT ON INVRCPT.intInventoryReceiptId = INVRCPTCHR.intInventoryReceiptId
	LEFT JOIN tblGRStorageHistory StrgHstry ON StrgHstry.intBillId = Bill.intBillId
	
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
	 ON ScaleDiscount.intTicketId = BillDtl.intScaleTicketId AND ScaleDiscount.intItemId = INVRCPTCHR.intChargeId AND INVRCPT.intSourceType = 1
	
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

	WHERE  Item.strType = 'Other Charge' AND ISNULL(BillDtl.intContractDetailId, 0) > 0

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
   )t3 ON  t3.intBillId = t2.intBillId AND t3.intBillId =t1.intBillId
	WHERE t3.intItemId IS NOT NULL 
  )t	
   GROUP BY 
   intBillDetailId
  ,strId
  ,intItemId
  ,strDiscountCode
  ,strDiscountCodeDescription
  ,dblGradeReading
