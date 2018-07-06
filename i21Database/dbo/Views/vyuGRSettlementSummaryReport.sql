CREATE VIEW [dbo].[vyuGRSettlementSummaryReport]
AS
SELECT  
 intPaymentId				    = intPaymentId	
,strPaymentNo				    = strPaymentNo
,InboundNetWeight			    = SUM(InboundNetWeight)
,InboundGrossDollars		    = SUM(InboundGrossDollars)
,InboundTax					    = SUM(InboundTax)
,InboundDiscount			    = SUM(InboundDiscount)
,InboundNetDue				    = SUM(InboundNetDue)
,OutboundNetWeight			    = OutboundNetWeight		
,OutboundGrossDollars		    = OutboundGrossDollars	
,OutboundTax				    = OutboundTax			
,OutboundDiscount			    = OutboundDiscount		
,OutboundNetDue				    = OutboundNetDue			
,SalesAdjustment			    = SalesAdjustment	
,VoucherAdjustment			    = VoucherAdjustment
,dblVendorPrepayment		    = SUM(dblVendorPrepayment)	 
,lblVendorPrepayment		    = lblVendorPrepayment		 
,dblCustomerPrepayment		    = dblCustomerPrepayment		 
,lblCustomerPrepayment		    = lblCustomerPrepayment		 
,dblGradeFactorTax			    = dblGradeFactorTax			 
,lblFactorTax				    = lblFactorTax				 
,dblPartialPrepaymentSubTotal   = dblPartialPrepaymentSubTotal
,lblPartialPrepayment		    = lblPartialPrepayment		 
,dblPartialPrepayment		    = dblPartialPrepayment		 
,CheckAmount				    = CheckAmount				 			
FROM 
(
			 SELECT 
			 intPaymentId				  = PYMT.intPaymentId
			,strPaymentNo				  = PYMT.strPaymentRecordNum
			,strBillId					  = Bill.strBillId
			,InboundNetWeight			  = SUM(CASE WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 ELSE BillDtl.dblQtyOrdered												  END)
			,InboundGrossDollars		  = SUM(CASE WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 ELSE BillDtl.dblTotal													  END)
			,InboundTax					  = SUM(CASE WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 ELSE BillDtl.dblTax														  END)
			,InboundDiscount			  = ISNULL(BillByReceipt.dblTotal, 0)
			,InboundNetDue				  = SUM(CASE WHEN BillDtl.intInventoryReceiptItemId IS NULL AND BillDtl.intInventoryReceiptChargeId IS NULL THEN 0 ELSE BillDtl.dblTotal + BillDtl.dblTax END)+ ISNULL(BillByReceipt.dblTotal, 0)
			,OutboundNetWeight			  = 0
			,OutboundGrossDollars		  = 0
			,OutboundTax				  = 0
			,OutboundDiscount			  = 0
			,OutboundNetDue				  = 0
			,SalesAdjustment			  = ISNULL(Invoice.dblPayment,0)
			,VoucherAdjustment			  = ISNULL(BillByReceiptItem.dblTotal, 0)
			,dblVendorPrepayment		  = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment, 0) <> 0 THEN VendorPrepayment.dblVendorPrepayment			     ELSE NULL END
			,lblVendorPrepayment		  = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment, 0) <> 0 THEN 'Vendor Prepay'									     ELSE NULL END
			,dblCustomerPrepayment		  = CASE WHEN ISNULL(Invoice.dblPayment, 0) <> 0				   THEN Invoice.dblPayment								     ELSE NULL END
			,lblCustomerPrepayment		  = CASE WHEN ISNULL(Invoice.dblPayment, 0) <> 0				   THEN 'Customer Prepay'								     ELSE NULL END
			,dblGradeFactorTax			  = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax, 0) <> 0   THEN ScaleDiscountTax.dblGradeFactorTax				     ELSE NULL END
			,lblFactorTax				  = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax, 0) <> 0   THEN 'Factor Tax'										 ELSE NULL END
			,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment, 0) <> 0		       THEN PartialPayment.dblTotals							 ELSE NULL END
			,lblPartialPrepayment		  = CASE WHEN ISNULL(PartialPayment.dblPayment, 0) <> 0		       THEN 'Partial Payment Adj'								 ELSE NULL END
			,dblPartialPrepayment		  = CASE WHEN ISNULL(PartialPayment.dblPayment, 0) <> 0		       THEN PartialPayment.dblPayment - PartialPayment.dblTotals ELSE NULL END
			,CheckAmount				  = PYMT.dblAmountPaid
			 FROM tblAPPayment PYMT 
			 JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			 JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			 JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
			 LEFT JOIN tblICItem Item ON Item.intItemId = BillDtl.intItemId
			 LEFT JOIN (
			 				SELECT intBillId ,SUM(dblTotal) dblTotal
			 				FROM tblAPBillDetail
			 				WHERE intInventoryReceiptChargeId IS NOT NULL
			 				GROUP BY intBillId
			 		   ) BillByReceipt ON BillByReceipt.intBillId = BillDtl.intBillId
			 
			 LEFT JOIN (
			  			  SELECT intPaymentId,SUM(APD.dblPayment) dblTotal
						  FROM tblAPPaymentDetail APD
						  JOIN tblAPBill Bill ON Bill.intBillId =APD.intBillId AND Bill.intTransactionType =3
						  GROUP BY intPaymentId
					   )BillByReceiptItem ON BillByReceiptItem.intPaymentId=PYMT.intPaymentId
			 
			 LEFT JOIN (
			 			 SELECT PYMT.intPaymentId ,SUM(BillDtl.dblTax) AS dblGradeFactorTax
			 			 FROM tblAPPayment PYMT
			 			 JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			 			 JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
			 			 JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
			 			 WHERE BillDtl.intInventoryReceiptChargeId IS NOT NULL
			 			 GROUP BY PYMT.intPaymentId
			 		   ) ScaleDiscountTax ON ScaleDiscountTax.intPaymentId = PYMT.intPaymentId
			 
			 LEFT JOIN (
			 				SELECT intBillId,SUM(dblAmountApplied * - 1) AS dblVendorPrepayment
			 				FROM tblAPAppliedPrepaidAndDebit
			 				WHERE ysnApplied = 1
			 				GROUP BY intBillId
			 		   ) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId

			 LEFT JOIN (
			 			  SELECT intPaymentId,SUM(dblPayment) dblPayment
			 			  FROM tblAPPaymentDetail
			 			  WHERE intInvoiceId IS NOT NULL
			 			  GROUP BY intPaymentId
			 		    ) Invoice ON Invoice.intPaymentId = PYMT.intPaymentId

			 LEFT JOIN (
			 				SELECT intPaymentId,SUM(dblTotal) dblTotals,SUM(dblPayment) dblPayment
			 				FROM tblAPPaymentDetail
			 				WHERE intBillId IS NOT NULL
			 				GROUP BY intPaymentId
							HAVING  SUM(dblTotal) <> SUM(dblPayment)
			 		   ) PartialPayment ON PartialPayment.intPaymentId = PYMT.intPaymentId

			 WHERE (
			 		intInventoryReceiptChargeId IS NOT NULL
			 		OR BillDtl.intInventoryReceiptItemId IS NOT NULL
			 		)
			 	AND Item.strType <> 'Other Charge' 
			 GROUP BY 
			 PYMT.intPaymentId
			,PYMT.strPaymentRecordNum
			,Bill.strBillId
			,BillByReceipt.dblTotal
			,Invoice.dblPayment
			,BillByReceiptItem.dblTotal
			,VendorPrepayment.dblVendorPrepayment
			,Invoice.dblPayment
			,ScaleDiscountTax.dblGradeFactorTax
			,PartialPayment.dblPayment
			,PartialPayment.dblPayment
			,PartialPayment.dblTotals
			,PYMT.dblAmountPaid 	

			--------------------------------------------------------
			-- SCALE --> Storage --> Settle Storage
			--------------------------------------------------------
			
			UNION ALL
			
			SELECT DISTINCT
			    intPaymentId		         = PYMT.intPaymentId
			   ,strPaymentNo		         = PYMT.strPaymentRecordNum
			   ,strBillId				     = Bill.strBillId
			   ,InboundNetWeight	         = SUM(BillDtl.dblQtyOrdered)
			   ,InboundGrossDollars          = SUM(BillDtl.dblTotal) 
			   ,InboundTax					 = SUM(BillDtl.dblTax) 
			   ,InboundDiscount				 = ISNULL(tblOtherCharge.dblTotal, 0)
			   ,InboundNetDue		         = SUM(BillDtl.dblTotal + ISNULL(BillDtl.dblTax, 0) + ISNULL(tblOtherCharge.dblTotal, 0))
			   ,OutboundNetWeight	         = 0 
			   ,OutboundGrossDollars         = 0 
			   ,OutboundTax		             = 0
			   ,OutboundDiscount	         = 0 
			   ,OutboundNetDue		         = 0 
			   ,SalesAdjustment              = ISNULL(Invoice.dblPayment,0) 
			   ,VoucherAdjustment            = ISNULL(tblAdjustment.dblTotal, 0) 
			   ,dblVendorPrepayment          = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN VendorPrepayment.dblVendorPrepayment				 ELSE NULL END 
			   ,lblVendorPrepayment          = CASE WHEN ISNULL(VendorPrepayment.dblVendorPrepayment,0) <> 0 THEN 'Vendor Prepay'									 ELSE NULL END
			   ,dblCustomerPrepayment        = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					 THEN Invoice.dblPayment								 ELSE NULL END 
			   ,lblCustomerPrepayment        = CASE WHEN ISNULL(Invoice.dblPayment,0) <> 0					 THEN 'Customer Prepay'									 ELSE NULL END
			   ,dblGradeFactorTax		     = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0	 THEN ScaleDiscountTax.dblGradeFactorTax				 ELSE NULL END 
			   ,lblFactorTax			     = CASE WHEN ISNULL(ScaleDiscountTax.dblGradeFactorTax,0) <> 0	 THEN 'Factor Tax'										 ELSE NULL END
			   ,dblPartialPrepaymentSubTotal = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN PartialPayment.dblTotals							 ELSE NULL END
			   ,lblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN 'Partial Payment Adj'								 ELSE NULL END
			   ,dblPartialPrepayment		 = CASE WHEN ISNULL(PartialPayment.dblPayment,0) <> 0			 THEN PartialPayment.dblPayment-PartialPayment.dblTotals ELSE NULL END
			   ,CheckAmount				     = PYMT.dblAmountPaid 		    
			FROM tblAPPayment PYMT 
			JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId IS NULL
			LEFT JOIN tblICItem Item ON Item.intItemId = BillDtl.intItemId 			
			LEFT JOIN (
						SELECT 
						 A.intBillId
						,SUM(dblTotal) dblTotal
						FROM tblAPBillDetail A
						JOIN tblICItem B ON A.intItemId = B.intItemId AND B.strType = 'Other Charge'
						GROUP BY A.intBillId
				      ) tblOtherCharge ON tblOtherCharge.intBillId = Bill.intBillId
			
			JOIN (
					SELECT 
					 A.intBillId
					,SUM(dblTax) dblTax
					FROM tblAPBillDetail A		  
					GROUP BY A.intBillId
				  ) tblTax ON tblTax.intBillId = Bill.intBillId
			
			LEFT JOIN (
						 SELECT intPaymentId,SUM(APD.dblPayment) dblTotal
						  FROM tblAPPaymentDetail APD
						  JOIN tblAPBill Bill ON Bill.intBillId =APD.intBillId AND Bill.intTransactionType =3
						  GROUP BY intPaymentId
				      ) tblAdjustment ON tblAdjustment.intPaymentId=PYMT.intPaymentId  
			
			LEFT JOIN (
						 SELECT
						 PYMT.intPaymentId
						,SUM(BillDtl.dblTax) AS dblGradeFactorTax	
						FROM tblAPPayment PYMT
						JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
						JOIN tblAPBillDetail BillDtl ON BillDtl.intBillId = PYMTDTL.intBillId
						JOIN tblICItem B ON B.intItemId = BillDtl.intItemId AND B.strType = 'Other Charge'
						GROUP BY  PYMT.intPaymentId
					  )ScaleDiscountTax ON ScaleDiscountTax.intPaymentId=PYMT.intPaymentId
			
			LEFT JOIN (
						 SELECT
						 intBillId
						,SUM(dblAmountApplied* -1) AS dblVendorPrepayment 
						FROM tblAPAppliedPrepaidAndDebit WHERE ysnApplied=1
						GROUP BY intBillId
						) VendorPrepayment ON VendorPrepayment.intBillId = Bill.intBillId
			
			LEFT JOIN (
						  SELECT 
						  intPaymentId
						 ,SUM(dblPayment) dblPayment 
						 FROM tblAPPaymentDetail WHERE intInvoiceId IS NOT NULL
						 GROUP BY intPaymentId
					    ) Invoice ON Invoice.intPaymentId=PYMT.intPaymentId
			
			LEFT JOIN (   SELECT 
						  intPaymentId
						 ,SUM(dblTotal) dblTotals
						 ,SUM(dblPayment) dblPayment 
						  FROM tblAPPaymentDetail
						  WHERE intBillId IS NOT NULL
						  GROUP BY intPaymentId
						  HAVING  SUM(dblTotal) <> SUM(dblPayment)
					    ) PartialPayment ON PartialPayment.intPaymentId=PYMT.intPaymentId
            WHERE  Item.strType <> 'Other Charge' 
			AND
			(
			 		    intInventoryReceiptChargeId IS NULL
			 		AND BillDtl.intInventoryReceiptItemId IS NULL
			)
			GROUP BY 
			 PYMT.intPaymentId
			,PYMT.strPaymentRecordNum
			,Bill.strBillId
			,tblOtherCharge.dblTotal
			,Invoice.dblPayment
			,tblAdjustment.dblTotal
			,VendorPrepayment.dblVendorPrepayment
			,Invoice.dblPayment
			,ScaleDiscountTax.dblGradeFactorTax
			,PartialPayment.dblPayment
			,PartialPayment.dblPayment
			,PartialPayment.dblTotals
			,PYMT.dblAmountPaid 
						
 ) t							
GROUP BY 			
 intPaymentId	
,strPaymentNo
,OutboundNetWeight		
,OutboundGrossDollars	
,OutboundTax			
,OutboundDiscount		
,OutboundNetDue			
,SalesAdjustment	
,VoucherAdjustment		 
,lblVendorPrepayment		 
,dblCustomerPrepayment		 
,lblCustomerPrepayment		 
,dblGradeFactorTax			 
,lblFactorTax				 
,dblPartialPrepaymentSubTotal
,lblPartialPrepayment		 
,dblPartialPrepayment		 
,CheckAmount
