GO
IF NOT EXISTS(SELECT 1 FROM tblAPDeferredPaymentInterest)
BEGIN
	INSERT INTO tblAPDeferredPaymentInterest (
		[dtmCalculationDate], 
		[dtmPaymentPostDate], 
		[dtmPaymentInvoiceDate], 
		[dtmPaymentDueDateOverride], 
		[strTerm]
	)
	SELECT
		[dtmCalculationDate]		=	GETDATE(), 
		[dtmPaymentPostDate]		=	GETDATE(), 
		[dtmPaymentInvoiceDate]		=	GETDATE(), 
		[dtmPaymentDueDateOverride]	=	GETDATE(), 
		[strTerm]					=	'Due on Receipt'
END