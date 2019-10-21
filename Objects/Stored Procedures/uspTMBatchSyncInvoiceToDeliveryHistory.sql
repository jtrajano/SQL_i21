CREATE PROCEDURE uspTMBatchSyncInvoiceToDeliveryHistory 
	@Invoices	[dbo].[InvoicePostingTable] READONLY
AS
BEGIN
	DECLARE @invoiceId INT
	DECLARE @userId INT
	DECLARE @ResultLog NVARCHAR(MAX) 

	SELECT *
	INTO #tmpInvoice
	FROM @Invoices

	

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpInvoice)
	BEGIN
		SELECT TOP 1 
			@invoiceId = intInvoiceId 
			,@userId = intUserId
		FROM #tmpInvoice

		SET @ResultLog = ''

		EXEC uspTMSyncInvoiceToDeliveryHistory @invoiceId, @userId, @ResultLog

		DELETE FROM #tmpInvoice WHERE intInvoiceId = @invoiceId
	END
	
END
	
GO
