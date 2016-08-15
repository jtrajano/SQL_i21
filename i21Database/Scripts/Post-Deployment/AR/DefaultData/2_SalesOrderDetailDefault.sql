---------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1530
-- Purpose: To default dblQtyShipped to Zero 
---------------------------------------------------------
print('/*******************  BEGIN Update NULL dblQtyShipped in tblSOSalesOrderDetail with zero  *******************/')
GO

UPDATE	dbo.tblSOSalesOrderDetail 
SET		dblQtyShipped = 0.00
WHERE	dblQtyShipped IS NULL 

GO
print('/*******************  END Update NULL dblQtyShipped in tblSOSalesOrderDetail with zero  *******************/')


print('/*******************  BEGIN Update NULL numeric fields in tblSOSalesOrder with zero  *******************/')
GO

UPDATE
	tblSOSalesOrder
SET
	 dblAmountDue			= ROUND(ISNULL(dblAmountDue,0),2)
	,dblDiscount 			= ROUND(ISNULL(dblDiscount,0),2)
	,dblSalesOrderSubtotal  = ROUND(ISNULL(dblSalesOrderSubtotal,0),2)
	,dblSalesOrderTotal		= ROUND(ISNULL(dblSalesOrderTotal,0),2)
	,dblPayment				= ROUND(ISNULL(dblPayment,0),2)
	,dblShipping 			= ROUND(ISNULL(dblShipping,0),2)
	,dblTax		 			= ROUND(ISNULL(dblTax,0),2)
WHERE	
	ysnProcessed = 0

GO
print('/*******************  END Update NULL numeric fields in tblSOSalesOrder with zero  *******************/')

print('/*******************  BEGIN Update NULL numeric fields in tblARPayment with zero  *******************/')
GO

UPDATE
	tblARPayment
SET
	 dblAmountPaid		= ROUND(ISNULL(dblAmountPaid,0),2)
	,dblBalance			= ROUND(ISNULL(dblBalance,0),2)
	,dblOverpayment 	= ROUND(ISNULL(dblOverpayment,0),2)
	,dblUnappliedAmount = ROUND(ISNULL(dblUnappliedAmount,0),2)
WHERE
	ysnPosted = 0

GO
print('/*******************  END Update NULL numeric fields in tblARPayment with zero  *******************/')


print('/*******************  BEGIN Update NULL numeric fields in tblARPayment with zero  *******************/')
GO

UPDATE
	tblARInvoice
SET
	 dblAmountDue		= ROUND(ISNULL(dblAmountDue,0),2)
	,dblDiscount 		= ROUND(ISNULL(dblDiscount,0),2)
	,dblInvoiceSubtotal = ROUND(ISNULL(dblInvoiceSubtotal,0),2)
	,dblInvoiceTotal	= ROUND(ISNULL(dblInvoiceTotal,0),2)
	,dblPayment			= ROUND(ISNULL(dblPayment,0),2)
	,dblShipping 		= ROUND(ISNULL(dblShipping,0),2)
	,dblTax		 		= ROUND(ISNULL(dblTax,0),2)
WHERE	
	ysnPosted = 0
	OR (ysnPosted = 1 AND strTransactionType IN ('Prepayment','Overpayment', 'Customer Prepayment'))

GO
print('/*******************  END Update NULL numeric fields in tblARPayment with zero  *******************/')