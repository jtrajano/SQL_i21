CREATE TRIGGER trgAPPaymentDetail
ON dbo.tblAPPaymentDetail
AFTER DELETE AS
BEGIN
INSERT INTO tblAPPaymentDetailDeleted
(
	[intPaymentDetailId]	,
	[intPaymentId]			,
	[intBillId]         	,
	[intAccountId]      	,
	[dblDiscount]       	,
	[dblAmountDue]      	,
	[dblPayment]        	,
	[dblInterest]       	,
	[dblTotal] 				,
	[intConcurrencyId] 		,
	[dblWithheld] 			,
	[intInvoiceId]			,
	[intOrigBillId]			,
	[intOrigInvoiceId]
)
SELECT 
	[intPaymentDetailId]	,
	[intPaymentId]			,
	[intBillId]         	,
	[intAccountId]      	,
	[dblDiscount]       	,
	[dblAmountDue]      	,
	[dblPayment]        	,
	[dblInterest]       	,
	[dblTotal] 				,
	[intConcurrencyId] 		,
	[dblWithheld] 			,
	[intInvoiceId]			,
	[intOrigBillId]			,
	[intOrigInvoiceId]
FROM DELETED
END
GO