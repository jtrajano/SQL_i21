﻿CREATE VIEW [dbo].[vyuGRSettlementSummaryReport]
AS

	-- We are using this view to directly insert table to an API Export table
	-- If there are changes in the view please update the insert in uspGRAPISettlementReportExport as well

SELECT  
	 intPaymentId				    = intPaymentId	
	,strPaymentNo				    = strPaymentNo
	,InboundNetWeight			    = SUM(InboundNetWeight)
	,InboundGrossDollars		    = SUM(InboundGrossDollars)
	,InboundTax					    = SUM(InboundTax) --+ isnull(AdditionalTax.dblTax,0)
	,InboundDiscount			    = SUM(InboundDiscount)
	,InboundNetDue				    = SUM(InboundNetDue)
	,OutboundNetWeight			    = OutboundNetWeight		
	,OutboundGrossDollars		    = OutboundGrossDollars	
	,OutboundTax				    = OutboundTax			
	,OutboundDiscount			    = OutboundDiscount		
	,OutboundNetDue				    = OutboundNetDue			
	,SalesAdjustment			    = SalesAdjustment	
	,VoucherAdjustment			    = SUM(VoucherAdjustment) + BillAdjustments.dblTotalAdjustment
	,dblVendorPrepayment		    = VendorPrepayment.dblVendorPrepayment
	,lblVendorPrepayment		    = lblVendorPrepayment		 
	,dblCustomerPrepayment		    = dblCustomerPrepayment		 
	,lblCustomerPrepayment		    = lblCustomerPrepayment		 
	,dblGradeFactorTax			    = dblGradeFactorTax			 
	,lblFactorTax				    = lblFactorTax				 
	,dblPartialPrepaymentSubTotal   = dblPartialPrepaymentSubTotal
	,lblPartialPrepayment		    = lblPartialPrepayment		 
	,dblPartialPrepayment		    = sum(isnull(dblPartialPrepayment, 0))
	,CheckAmount				    = CheckAmount				 			
FROM 
(
	SELECT 
		intPaymentId					= PYMT.intPaymentId
		,strPaymentNo					= PYMT.strPaymentRecordNum
		,strBillId						= Bill.strBillId
		,InboundNetWeight				= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
													ELSE BillDtl.dblQtyReceived
												END
											)
		,InboundGrossDollars			= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
													ELSE BillDtl.dblTotal													
												END
											)
		,InboundTax						= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
													ELSE BillDtl.dblTax
												END
											) +
											-- Include tax for discounts/other charges
											CASE 
												WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTax,0) 
												ELSE ISNULL(BillByReceipt.dblTax, 0)
											END
		,InboundDiscount				= CASE 
											WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTotal,0) 
											ELSE ISNULL(BillByReceipt.dblTotal, 0)
										END
		,InboundNetDue					= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
													ELSE BillDtl.dblTotal + BillDtl.dblTax +BillDtl.dblDiscount
												END
											) +											
											( 
												CASE 													
													WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTotal,0) 
													ELSE ISNULL(BillByReceipt.dblTotal, 0) --+ ISNULL(BillByReceiptManuallyAdded.dblTotal, 0)
												END
											) +
											-- Include tax for discounts/other charges
											CASE 
												WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTax,0) 
												ELSE ISNULL(BillByReceipt.dblTax, 0)
											END
		,OutboundNetWeight				= 0
		,OutboundGrossDollars			= 0
		,OutboundTax					= 0
		,OutboundDiscount				= 0
		,OutboundNetDue					= 0
		,SalesAdjustment				= ISNULL(Invoice.dblPayment,0)
		,VoucherAdjustment				= ISNULL(BillAdjustments.dblTotal, 0)
		,lblVendorPrepayment			= 'Vendor Prepay' COLLATE Latin1_General_CI_AS
		,dblCustomerPrepayment			= CASE 
											WHEN ISNULL(Invoice.dblPayment, 0) <> 0 THEN Invoice.dblPayment
											ELSE NULL 
										END
		,lblCustomerPrepayment			= 'Customer Prepay' COLLATE Latin1_General_CI_AS
		,dblGradeFactorTax				= CASE 
											WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax, 0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax
											ELSE NULL 
										END
		,lblFactorTax					= 'Factor Tax' COLLATE Latin1_General_CI_AS
		,dblPartialPrepaymentSubTotal	= CASE 
											WHEN ISNULL(PartialPayment.dblPayment, 0) <> 0 THEN PartialPayment.dblPayment 
											ELSE NULL 
										END
		,lblPartialPrepayment			= 'Basis Adv/Debit Memo' COLLATE Latin1_General_CI_AS
		,dblPartialPrepayment		  = CASE 
											WHEN ISNULL(BasisPayment.dblVendorPrepayment, 0) <> 0 THEN BasisPayment.dblVendorPrepayment -- PartialPayment.dblTotals 
											ELSE NULL 
										END
		,CheckAmount				  = PYMT.dblAmountPaid
		,intMark					  = 1
	FROM tblAPPayment PYMT 
	JOIN tblAPPaymentDetail PYMTDTL 
		ON PYMT.intPaymentId = PYMTDTL.intPaymentId				
		and PYMTDTL.dblPayment <> 0
	JOIN tblAPBill Bill 
		ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl 
		ON Bill.intBillId = BillDtl.intBillId 
			AND BillDtl.intInventoryReceiptChargeId IS NULL
	LEFT JOIN tblICItem Item 
		ON Item.intItemId = BillDtl.intItemId
	LEFT JOIN (
		SELECT 
			SUM(dblAmount) dblTotal
			,SUM(dblTax) dblTax
			,strId
			,intBillDetailId
		FROM vyuGRSettlementSubReport 
		GROUP BY strId, intBillDetailId
	) tblOtherCharge
		ON tblOtherCharge.strId = Bill.strBillId 
			and BillDtl.intBillDetailId = tblOtherCharge.intBillDetailId
	-- LEFT JOIN (
	-- 	SELECT 
	-- 		A.intBillId
	-- 		,SUM(dblTotal) dblTotal
	-- 	FROM tblAPBillDetail A
	-- 	JOIN tblICItem B 
	-- 		ON A.intItemId = B.intItemId 
	-- 			AND B.strType = 'Other Charge'
	-- 	GROUP BY A.intBillId
	-- ) tblOtherCharge 
	-- 	ON tblOtherCharge.intBillId = Bill.intBillId
	LEFT JOIN (
		SELECT 
			a.intBillId
			,a.intInventoryReceiptItemId
			,SUM(a.dblTotal) dblTotal
			,SUM(a.dblTax) dblTax
		FROM tblAPBillDetail a 
			join tblAPBill  b
				on a.intBillId = b.intBillId --and b.intTransactionType = 1
		WHERE a.intInventoryReceiptChargeId IS NOT NULL
		GROUP BY a.intBillId
			,a.intInventoryReceiptItemId
	) BillByReceipt ON BillByReceipt.intBillId = BillDtl.intBillId
		AND BillByReceipt.intInventoryReceiptItemId = BillDtl.intInventoryReceiptItemId
	-- MANUALLY ADDED LINE ITEMS IN THE MAIN VOUCHER FROM SCALE TICKET
	LEFT JOIN (
		SELECT 
			Bill.intBillId
			,APD.intPaymentId
			,SUM(BD.dblTotal) dblTotal
		FROM tblAPPaymentDetail APD
		JOIN tblAPBill Bill 
			ON Bill.intBillId = APD.intBillId 				
				and APD.dblPayment <> 0
				AND Bill.intTransactionType <> 2 -- Exclude vendor prepay
		JOIN tblAPBillDetail BD
			ON BD.intBillId = Bill.intBillId
			AND BD.intScaleTicketId IS NULL
		GROUP BY Bill.intBillId, APD.intPaymentId
	) BillAdjustments ON BillAdjustments.intPaymentId = PYMT.intPaymentId	
		AND BillAdjustments.intBillId = Bill.intBillId
	LEFT JOIN (
		SELECT 
			PYMT.intPaymentId
			,SUM(BillDtl.dblTax) AS dblGradeFactorTax
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL 
			ON PYMT.intPaymentId = PYMTDTL.intPaymentId								
				and PYMTDTL.dblPayment <> 0
		JOIN tblAPBillDetail BillDtl 
			ON BillDtl.intBillId = PYMTDTL.intBillId
		JOIN tblICItem B 
			ON B.intItemId = BillDtl.intItemId 
				AND B.strType = 'Other Charge'
		WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL
		GROUP BY PYMT.intPaymentId
	) ScaleDiscountTax ON ScaleDiscountTax.intPaymentId = PYMT.intPaymentId			 
	LEFT JOIN (
		SELECT 
			intPaymentId
			,SUM(dblPayment) dblPayment
		FROM tblAPPaymentDetail
		WHERE intInvoiceId IS NOT NULL and dblPayment <> 0
		GROUP BY intPaymentId
	) Invoice ON Invoice.intPaymentId = PYMT.intPaymentId
	LEFT JOIN (
		SELECT 
			intPaymentId
			,SUM(APD.dblTotal) dblTotals
			,SUM(APD.dblPayment) dblPayment
		FROM tblAPPaymentDetail APD
		JOIN tblAPBill APB on APB.intBillId = APD.intBillId
		WHERE APD.intBillId IS NOT NULL and (APB.intTransactionType = 13 OR APB.intTransactionType = 3)				
			and APD.dblPayment <> 0
		GROUP BY intPaymentId
		HAVING SUM(APD.dblTotal) <> SUM(APD.dblPayment)
	) PartialPayment ON PartialPayment.intPaymentId = PYMT.intPaymentId
	LEFT JOIN (
		SELECT
			a.intBillId
			,SUM(a.dblAmountApplied* -1) AS dblVendorPrepayment 
		FROM tblAPAppliedPrepaidAndDebit  a join tblAPBill b on a.intTransactionId = b.intBillId and b.intTransactionType in (13, 3)
		WHERE a.ysnApplied = 1
		GROUP BY a.intBillId
	) BasisPayment ON BasisPayment.intBillId = Bill.intBillId	
	WHERE ((
			BillDtl.intInventoryReceiptChargeId IS NOT NULL
			OR BillDtl.intInventoryReceiptItemId IS NOT NULL
		)
		AND Item.strType <> 'Other Charge' )
	GROUP BY 
		PYMT.intPaymentId
		,PYMT.strPaymentRecordNum
		,Bill.strBillId
		,BillByReceipt.dblTotal
		,BillByReceipt.dblTax
		,Invoice.dblPayment
		,BillAdjustments.dblTotal
		-- ,VendorPrepayment.dblVendorPrepayment
		,Invoice.dblPayment
		,ScaleDiscountTax.dblGradeFactorTax
		,PartialPayment.dblPayment
		,PartialPayment.dblPayment
		,PartialPayment.dblTotals
		,PYMT.dblAmountPaid 	
		,BillDtl.intCustomerStorageId
		,BillDtl.intInventoryReceiptItemId
		,tblOtherCharge.dblTotal
		,tblOtherCharge.dblTax
		,BillDtl.intInventoryReceiptChargeId
		,BasisPayment.dblVendorPrepayment
	--------------------------------------------------------
	-- SCALE --> Storage --> Settle Storage
	--------------------------------------------------------
			
	UNION ALL
			
	SELECT DISTINCT
		intPaymentId					= PYMT.intPaymentId
		,strPaymentNo					= PYMT.strPaymentRecordNum
		,strBillId						= Bill.strBillId
		,InboundNetWeight				= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													ELSE BillDtl.dblQtyReceived
												END
											)
		,InboundGrossDollars			= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													ELSE BillDtl.dblTotal													
												END
											)
		,InboundTax						= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													ELSE BillDtl.dblTax
												END
											)
											+ ISNULL(tblOtherCharge.dblTax,0)
		,InboundDiscount				= ISNULL(tblOtherCharge.dblTotal,0) - ISNULL(BillAdjustments.dblTotal, 0)
		,InboundNetDue					= SUM(
												CASE 
													WHEN Bill.intTransactionType = 2 then 0
													-- Inline voucher adjustments should not be included in the net due as they have a separate computation in the summary
													ELSE BillDtl.dblTotal + BillDtl.dblTax
												END
											) + ISNULL(tblOtherCharge.dblTax,0)
											-- Inline voucher adjustments should not be included in the net due as they have a separate computation in the summary
											+ isnull(tblOtherCharge.dblTotal, 0) - ISNULL(BillAdjustments.dblTotal, 0)
		,OutboundNetWeight				= 0 
		,OutboundGrossDollars			= 0 
		,OutboundTax		            = 0
		,OutboundDiscount				= 0 
		,OutboundNetDue					= 0 
		,SalesAdjustment				= ISNULL(Invoice.dblPayment,0) 
		,VoucherAdjustment				= ISNULL(BillAdjustments.dblTotal, 0)
		,lblVendorPrepayment			= 'Vendor Prepay' COLLATE Latin1_General_CI_AS
		,dblCustomerPrepayment			= CASE 
											WHEN ISNULL(Invoice.dblPayment,0) <> 0 THEN Invoice.dblPayment 
											ELSE NULL 
										END 
		,lblCustomerPrepayment			=  'Customer Prepay' COLLATE Latin1_General_CI_AS
		,dblGradeFactorTax				= CASE 
											WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax
											ELSE NULL 
										END 
		,lblFactorTax					= 'Factor Tax' COLLATE Latin1_General_CI_AS
		,dblPartialPrepaymentSubTotal	= CASE 
											WHEN ISNULL(PartialPayment.dblPayment,0) <> 0 THEN PartialPayment.dblPayment--PartialPayment.dblPayment
											ELSE NULL 
										END
		,lblPartialPrepayment			= 'Basis Adv/Debit Memo' COLLATE Latin1_General_CI_AS
		,dblPartialPrepayment			= sum(ISNULL(BasisPayment.dblVendorPrepayment,0))
		,CheckAmount				    = PYMT.dblAmountPaid 
		,intMark					  	= 2	    
	FROM tblAPPayment PYMT 
	JOIN tblAPPaymentDetail PYMTDTL	
		ON PYMT.intPaymentId = PYMTDTL.intPaymentId				
			and PYMTDTL.dblPayment <> 0
	JOIN tblAPBill Bill 
		ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl 
		ON Bill.intBillId = BillDtl.intBillId 
			AND BillDtl.intInventoryReceiptChargeId IS NULL
	LEFT JOIN tblICItem Item 
		ON Item.intItemId = BillDtl.intItemId
	LEFT JOIN (
		SELECT 
			SUM(dblAmount) dblTotal
			,SUM(dblTax) dblTax
			,strId
			,intBillDetailId
		FROM vyuGRSettlementSubReport
		GROUP BY strId
			,intBillDetailId
	) tblOtherCharge
		ON tblOtherCharge.strId = Bill.strBillId
			and BillDtl.intBillDetailId = tblOtherCharge.intBillDetailId
	-- LEFT JOIN (
	-- 	SELECT 
	-- 		A.intBillId
	-- 		,SUM(dblTotal) dblTotal
	-- 	FROM tblAPBillDetail A
	-- 	JOIN tblICItem B 
	-- 		ON A.intItemId = B.intItemId 
	-- 			AND B.strType = 'Other Charge'
	-- 	GROUP BY A.intBillId
	-- ) tblOtherCharge ON tblOtherCharge.intBillId = Bill.intBillId			
	JOIN (
		SELECT 
			A.intBillId
			,SUM(dblTax) dblTax
		FROM tblAPBillDetail A		  
		GROUP BY A.intBillId
	) tblTax ON tblTax.intBillId = Bill.intBillId
	-- -- MANUALLY ADDED LINE ITEMS IN THE MAIN VOUCHER FROM SETTLEMENT
	LEFT JOIN (
		SELECT 
			Bill.intBillId
			,APD.intPaymentId
			,SUM(BD.dblTotal) dblTotal
		FROM tblAPPaymentDetail APD
		JOIN tblAPBill Bill 
			ON Bill.intBillId = APD.intBillId 				
				and APD.dblPayment <> 0
				AND Bill.intTransactionType <> 2 -- Exclude vendor prepay
		JOIN tblAPBillDetail BD
			ON BD.intBillId = Bill.intBillId
				AND BD.intCustomerStorageId IS NULL
				AND BD.intSettleStorageId IS NULL
		GROUP BY Bill.intBillId, APD.intPaymentId
	) BillAdjustments ON BillAdjustments.intPaymentId = PYMT.intPaymentId	
		AND BillAdjustments.intBillId = Bill.intBillId
	LEFT JOIN (
		SELECT
			PYMT.intPaymentId
			,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL 
			ON PYMT.intPaymentId = PYMTDTL.intPaymentId				
				and PYMTDTL.dblPayment <> 0
		JOIN tblAPBillDetail BillDtl 
			ON BillDtl.intBillId = PYMTDTL.intBillId
		JOIN tblICItem B 
			ON B.intItemId = BillDtl.intItemId 
				AND B.strType = 'Other Charge'
		GROUP BY PYMT.intPaymentId
	) ScaleDiscountTax ON ScaleDiscountTax.intPaymentId = PYMT.intPaymentId			
	LEFT JOIN (
		SELECT 
			intPaymentId
			,SUM(dblPayment) dblPayment 
		FROM tblAPPaymentDetail 		
		WHERE intInvoiceId IS NOT NULL and dblPayment <> 0
		GROUP BY intPaymentId
	) Invoice ON Invoice.intPaymentId = PYMT.intPaymentId			
	LEFT JOIN (
		SELECT 
			intPaymentId
			,SUM(APD.dblTotal) dblTotals
			,SUM(APD.dblPayment) dblPayment
		FROM tblAPPaymentDetail APD
		JOIN tblAPBill APB on APB.intBillId = APD.intBillId
		WHERE APD.intBillId IS NOT NULL and (APB.intTransactionType = 13 OR APB.intTransactionType = 3)				
			and APD.dblPayment <> 0
		GROUP BY intPaymentId
		HAVING SUM(APD.dblTotal) <> SUM(APD.dblPayment)
	) PartialPayment ON PartialPayment.intPaymentId = PYMT.intPaymentId
	LEFT JOIN (
		SELECT
			a.intBillId
			,SUM(a.dblAmountApplied* -1) AS dblVendorPrepayment 
		FROM tblAPAppliedPrepaidAndDebit  a join tblAPBill b on a.intTransactionId = b.intBillId and b.intTransactionType  in (13, 3)
		WHERE a.ysnApplied = 1
		GROUP BY a.intBillId
	) BasisPayment ON BasisPayment.intBillId = Bill.intBillId	
	WHERE Item.strType <> 'Other Charge' 
		AND (intInventoryReceiptChargeId IS NULL AND BillDtl.intInventoryReceiptItemId IS NULL)
		AND (intSettleStorageId IS NOT NULL OR intCustomerStorageId IS NOT NULL)
	GROUP BY 
		PYMT.intPaymentId
		,PYMT.strPaymentRecordNum
		,Bill.strBillId
		,tblOtherCharge.dblTotal
		,tblOtherCharge.dblTax
		,Invoice.dblPayment
		,BillAdjustments.dblTotal
		,Invoice.dblPayment
		,ScaleDiscountTax.dblGradeFactorTax
		,PartialPayment.dblPayment
		,PartialPayment.dblPayment
		,PartialPayment.dblTotals
		,PYMT.dblAmountPaid	
		--,BasisPayment.dblVendorPrepayment
	UNION ALL
	--DIRECT SHIPMENTS
	SELECT 
		intPaymentId					= PYMT.intPaymentId
		,strPaymentNo					= PYMT.strPaymentRecordNum
		,strBillId						= Bill.strBillId
		,InboundNetWeight				= SUM(
												--CASE 
												--	WHEN Bill.intTransactionType = 2 then 0
												--	WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
												--	ELSE BillDtl.dblQtyReceived
												--END
												BillDtl.dblQtyReceived
											)
		,InboundGrossDollars			= SUM(
												--CASE 
												--	WHEN Bill.intTransactionType = 2 then 0
												--	WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
												--	ELSE BillDtl.dblTotal													
												--END
												BillDtl.dblTotal
											)
		,InboundTax						= SUM(
												--CASE 
												--	WHEN Bill.intTransactionType = 2 then 0
												--	WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
												--	ELSE BillDtl.dblTax
												--END
												BillDtl.dblTax
											) +
											-- Include tax for discounts/other charges
											--CASE 
											--	WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTax,0) 
											--	ELSE ISNULL(BillByReceipt.dblTax, 0)
											--END
											ISNULL(tblOtherCharge.dblTax,0)
		,InboundDiscount				= ISNULL(tblOtherCharge.dblTotal,0) 
										--CASE 
										--	WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTotal,0) 
										--	ELSE ISNULL(BillByReceipt.dblTotal, 0)
										--END
		,InboundNetDue					= SUM(
												--CASE 
												--	WHEN Bill.intTransactionType = 2 then 0
												--	WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 
												--	ELSE BillDtl.dblTotal + BillDtl.dblTax +BillDtl.dblDiscount
												--END
												BillDtl.dblTotal + BillDtl.dblTax + BillDtl.dblDiscount
											) +											
											( 
												--CASE 													
												--	WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTotal,0) 
												--	ELSE ISNULL(BillByReceipt.dblTotal, 0) --+ ISNULL(BillByReceiptManuallyAdded.dblTotal, 0)
												--END
												ISNULL(tblOtherCharge.dblTotal,0) 
											) +
											-- Include tax for discounts/other charges
											--CASE 
											--	WHEN BillDtl.intInventoryReceiptItemId IS NOT NULL THEN ISNULL(tblOtherCharge.dblTax,0) 
											--	ELSE ISNULL(BillByReceipt.dblTax, 0)
											--END
											ISNULL(tblOtherCharge.dblTax,0) 
		,OutboundNetWeight				= 0
		,OutboundGrossDollars			= 0
		,OutboundTax					= 0
		,OutboundDiscount				= 0
		,OutboundNetDue					= 0
		,SalesAdjustment				= ISNULL(Invoice.dblPayment,0)
		,VoucherAdjustment				= ISNULL(BillAdjustments.dblTotal, 0)
		,lblVendorPrepayment			= 'Vendor Prepay' COLLATE Latin1_General_CI_AS
		,dblCustomerPrepayment			= CASE 
											WHEN ISNULL(Invoice.dblPayment, 0) <> 0 THEN Invoice.dblPayment
											ELSE NULL 
										END
		,lblCustomerPrepayment			= 'Customer Prepay' COLLATE Latin1_General_CI_AS
		,dblGradeFactorTax				= CASE 
											WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax, 0) <> 0 THEN ScaleDiscountTax.dblGradeFactorTax
											ELSE NULL 
										END
		,lblFactorTax					= 'Factor Tax' COLLATE Latin1_General_CI_AS
		,dblPartialPrepaymentSubTotal	= CASE 
											WHEN ISNULL(PartialPayment.dblPayment, 0) <> 0 THEN PartialPayment.dblPayment 
											ELSE NULL 
										END
		,lblPartialPrepayment			= 'Basis Adv/Debit Memo' COLLATE Latin1_General_CI_AS
		,dblPartialPrepayment		  = CASE 
											WHEN ISNULL(BasisPayment.dblVendorPrepayment, 0) <> 0 THEN BasisPayment.dblVendorPrepayment -- PartialPayment.dblTotals 
											ELSE NULL 
										END
		,CheckAmount				  = PYMT.dblAmountPaid
		,intMark					  = 1
	FROM tblAPPayment PYMT 
	JOIN tblAPPaymentDetail PYMTDTL 
		ON PYMT.intPaymentId = PYMTDTL.intPaymentId				
		and PYMTDTL.dblPayment <> 0
	JOIN tblAPBill Bill 
		ON PYMTDTL.intBillId = Bill.intBillId
	JOIN tblAPBillDetail BillDtl 
		ON Bill.intBillId = BillDtl.intBillId 
			AND BillDtl.intInventoryReceiptChargeId IS NULL
	LEFT JOIN tblICItem Item 
		ON Item.intItemId = BillDtl.intItemId
	LEFT JOIN (
		SELECT 
			SUM(dblAmount) dblTotal
			,SUM(dblTax) dblTax
			,strId
			,intBillDetailId
		FROM vyuGRSettlementSubReport 
		GROUP BY strId, intBillDetailId
	) tblOtherCharge
		ON tblOtherCharge.strId = Bill.strBillId 
			and BillDtl.intBillDetailId = tblOtherCharge.intBillDetailId
	--LEFT JOIN (
	--	SELECT 
	--		a.intBillId
	--		,a.intInventoryReceiptItemId
	--		,SUM(a.dblTotal) dblTotal
	--		,SUM(a.dblTax) dblTax
	--	FROM tblAPBillDetail a 
	--		join tblAPBill  b
	--			on a.intBillId = b.intBillId --and b.intTransactionType = 1
	--	WHERE a.intInventoryReceiptChargeId IS NOT NULL
	--	GROUP BY a.intBillId
	--		,a.intInventoryReceiptItemId
	--) BillByReceipt ON BillByReceipt.intBillId = BillDtl.intBillId
	--	AND BillByReceipt.intInventoryReceiptItemId = BillDtl.intInventoryReceiptItemId
	-- MANUALLY ADDED LINE ITEMS IN THE MAIN VOUCHER FROM SCALE TICKET
	LEFT JOIN (
		SELECT 
			Bill.intBillId
			,APD.intPaymentId
			,SUM(BD.dblTotal) dblTotal
		FROM tblAPPaymentDetail APD
		JOIN tblAPBill Bill 
			ON Bill.intBillId = APD.intBillId 				
				and APD.dblPayment <> 0
				AND Bill.intTransactionType <> 2 -- Exclude vendor prepay
		JOIN tblAPBillDetail BD
			ON BD.intBillId = Bill.intBillId
			AND BD.intScaleTicketId IS NULL
		GROUP BY Bill.intBillId, APD.intPaymentId
	) BillAdjustments ON BillAdjustments.intPaymentId = PYMT.intPaymentId	
		AND BillAdjustments.intBillId = Bill.intBillId
	LEFT JOIN (
		SELECT 
			PYMT.intPaymentId
			,SUM(BillDtl.dblTax) AS dblGradeFactorTax
		FROM tblAPPayment PYMT
		JOIN tblAPPaymentDetail PYMTDTL 
			ON PYMT.intPaymentId = PYMTDTL.intPaymentId								
				and PYMTDTL.dblPayment <> 0
		JOIN tblAPBillDetail BillDtl 
			ON BillDtl.intBillId = PYMTDTL.intBillId
		JOIN tblICItem B 
			ON B.intItemId = BillDtl.intItemId 
				AND B.strType = 'Other Charge'
		WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL
		GROUP BY PYMT.intPaymentId
	) ScaleDiscountTax ON ScaleDiscountTax.intPaymentId = PYMT.intPaymentId			 
	LEFT JOIN (
		SELECT 
			intPaymentId
			,SUM(dblPayment) dblPayment
		FROM tblAPPaymentDetail
		WHERE intInvoiceId IS NOT NULL and dblPayment <> 0
		GROUP BY intPaymentId
	) Invoice ON Invoice.intPaymentId = PYMT.intPaymentId
	LEFT JOIN (
		SELECT 
			intPaymentId
			,SUM(APD.dblTotal) dblTotals
			,SUM(APD.dblPayment) dblPayment
		FROM tblAPPaymentDetail APD
		JOIN tblAPBill APB on APB.intBillId = APD.intBillId
		WHERE APD.intBillId IS NOT NULL and (APB.intTransactionType = 13 OR APB.intTransactionType = 3)				
			and APD.dblPayment <> 0
		GROUP BY intPaymentId
		HAVING SUM(APD.dblTotal) <> SUM(APD.dblPayment)
	) PartialPayment ON PartialPayment.intPaymentId = PYMT.intPaymentId
	LEFT JOIN (
		SELECT
			a.intBillId
			,SUM(a.dblAmountApplied* -1) AS dblVendorPrepayment 
		FROM tblAPAppliedPrepaidAndDebit  a join tblAPBill b on a.intTransactionId = b.intBillId and b.intTransactionType in (13, 3)
		WHERE a.ysnApplied = 1
		GROUP BY a.intBillId
	) BasisPayment ON BasisPayment.intBillId = Bill.intBillId	
	WHERE (BillDtl.intInventoryReceiptChargeId IS NULL AND BillDtl.intInventoryReceiptItemId IS NULL)
		AND (intSettleStorageId IS NULL AND intCustomerStorageId IS NULL)
		AND Item.strType <> 'Other Charge'
	GROUP BY 
		PYMT.intPaymentId
		,PYMT.strPaymentRecordNum
		,Bill.strBillId
		--,BillByReceipt.dblTotal
		--,BillByReceipt.dblTax
		,Invoice.dblPayment
		,BillAdjustments.dblTotal
		-- ,VendorPrepayment.dblVendorPrepayment
		,Invoice.dblPayment
		,ScaleDiscountTax.dblGradeFactorTax
		,PartialPayment.dblPayment
		,PartialPayment.dblPayment
		,PartialPayment.dblTotals
		,PYMT.dblAmountPaid 	
		,BillDtl.intCustomerStorageId
		,BillDtl.intInventoryReceiptItemId
		,tblOtherCharge.dblTotal
		,tblOtherCharge.dblTax
		,BillDtl.intInventoryReceiptChargeId
		,BasisPayment.dblVendorPrepayment
) t

--This is added for GRN-2639
-- The focus of this fix is for the tax part of the settlement report
-- the issue is that the manually added other charge item is used to offset the tax
-- we cannot link those taxes to the settlement because we do not have link to it. 
-- so the best way, I think, is to get all the tax and just add it at the end of this query.
-- Only applicable to the scale part :) 
-- MonGonzales 20210414
outer apply (
	select 
		sum(BillDetail.dblTax) dblTax
	from tblAPPaymentDetail PaymentDetail
		join tblAPBillDetail BillDetail
			on BillDetail.intBillId = PaymentDetail.intBillId
		join tblICItem Item
			on Item.intItemId = BillDetail.intItemId
				and Item.strType = 'Other Charge'
		join tblAPPayment Payment
			on PaymentDetail.intPaymentId = Payment.intPaymentId
		where Payment.intPaymentId = t.intPaymentId
			and (BillDetail.intCustomerStorageId is null 
					and BillDetail.intSettleStorageId is null
					and BillDetail.intScaleTicketId is null
					and BillDetail.intInventoryReceiptChargeId IS NULL
				)
			and t.intMark = 1
			and BillDetail.ysnStage = 0
) AdditionalTax

-- Only compute the vendor prepayment once for vouchers generated from scale ticket and storage settlement
OUTER APPLY (
	SELECT 
		[dblVendorPrepayment] = SUM(VendorPrepayment.dblVendorPrepayment)
	FROM tblAPPaymentDetail PD
	INNER JOIN tblAPBill B
		ON B.intBillId = PD.intBillId
	INNER JOIN tblAPPayment P
		ON PD.intPaymentId = P.intPaymentId
	OUTER APPLY (
		SELECT 
			a.intBillId
			,SUM(a.dblAmountApplied * - 1) AS dblVendorPrepayment
		FROM tblAPAppliedPrepaidAndDebit a join tblAPBill b on a.intTransactionId = b.intBillId and b.intTransactionType  not in (13, 3)
		WHERE a.ysnApplied = 1
		AND b.intBillId = B.intBillId
		GROUP BY a.intBillId		

		union all
		
		select 
			ap.intBillId,
			[dblVendorPrepayment] = pay.dblPayment --(ISNULL(ap.dblTotal, 0) + ISNULL(ap.dblTax, 0)) * (CASE pay.ysnOffset WHEN 1 THEN -1 ELSE 1 END)
		from 
		tblAPBill ap
		inner join tblAPPaymentDetail pay
			ON pay.intBillId = ap.intBillId
		where ap.intTransactionType = 2
		and ap.intBillId = B.intBillId
		and pay.intPaymentId = P.intPaymentId						
		and pay.dblPayment <> 0
	) VendorPrepayment
	WHERE P.intPaymentId = t.intPaymentId
) VendorPrepayment

-- VOUCHER ADJUSTMENTS ON SEPARATE VOUCHER
-- These are vouchers that are not generated via storage settlement or via ticket distribution
OUTER APPLY (
	SELECT
		SUM(APD.dblPayment) dblTotalAdjustment
	FROM tblAPPaymentDetail APD
	JOIN tblAPBill Bill
		ON Bill.intBillId = APD.intBillId 				
			and APD.dblPayment <> 0
			AND Bill.intTransactionType <> 2 -- Exclude vendor prepay
	-- Exclude vouchers generated from scale or settlement
	WHERE NOT EXISTS (
		SELECT 1 FROM tblGRSettleStorageBillDetail SSBH
		WHERE SSBH.intBillId = Bill.intBillId

		UNION ALL

		SELECT 1 FROM tblAPBillDetail BD2
		INNER JOIN tblSCTicket SC ON SC.intTicketId = BD2.intScaleTicketId
		WHERE BD2.intBillId = Bill.intBillId
	)
	AND APD.intPaymentId = t.intPaymentId
) BillAdjustments

GROUP BY 			
	intPaymentId	
	,strPaymentNo
	,OutboundNetWeight		
	,OutboundGrossDollars	
	,OutboundTax			
	,OutboundDiscount		
	,OutboundNetDue			
	,SalesAdjustment	
	,BillAdjustments.dblTotalAdjustment
	,VendorPrepayment.dblVendorPrepayment
	,lblVendorPrepayment		 
	,dblCustomerPrepayment		 
	,lblCustomerPrepayment		 
	,dblGradeFactorTax			 
	,lblFactorTax				 
	,dblPartialPrepaymentSubTotal
	,lblPartialPrepayment		 
	--,dblPartialPrepayment		 
	,CheckAmount
	,ISNULL(AdditionalTax.dblTax, 0)
GO