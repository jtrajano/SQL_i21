CREATE FUNCTION [dbo].[fnARGetInvalidInvoicesForInvoiceSplits]
(
	 @Invoices	[dbo].[InvoicePostingTable] READONLY
	,@Post		BIT	= 0
)
RETURNS @returntable TABLE
(
	 [intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)
AS
BEGIN

	DECLARE @ZeroDecimal DECIMAL(18,6)
	SET @ZeroDecimal = 0.000000	

--IF(ISNULL(@Post,0)) = 1
--	BEGIN
--		INSERT INTO @returntable(
--			 [intInvoiceId]
--			,[strInvoiceNumber]
--			,[strTransactionType]
--			,[intInvoiceDetailId]
--			,[intItemId]
--			,[strBatchId]
--			,[strPostingError])

--		--ALREADY POSTED
--		SELECT
--			 [intInvoiceId]			= I.[intInvoiceId]
--			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
--			,[strTransactionType]	= I.[strTransactionType]
--			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
--			,[intItemId]			= I.[intItemId] 
--			,[strBatchId]			= I.[strBatchId]
--			,[strPostingError]		= 'The transaction is already posted.'
--		FROM 
--			@Invoices I
--		INNER JOIN 
--			(SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice) ARI
--				ON I.[intInvoiceId] = ARI.[intInvoiceId]
--		WHERE  
--			ARI.[ysnPosted] = 1			
																																			
--	END
--ELSE
--	BEGIN
--		INSERT INTO @returntable(
--			 [intInvoiceId]
--			,[strInvoiceNumber]
--			,[strTransactionType]
--			,[intInvoiceDetailId]
--			,[intItemId]
--			,[strBatchId]
--			,[strPostingError])

--		--NOT YET POSTED
--		SELECT
--			 [intInvoiceId]			= I.[intInvoiceId]
--			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
--			,[strTransactionType]	= I.[strTransactionType]
--			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
--			,[intItemId]			= I.[intItemId]
--			,[strBatchId]			= I.[strBatchId]
--			,[strPostingError]		= 'The transaction has not been posted yet.'
--		FROM 
--			@Invoices I
--		INNER JOIN 
--			(SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice) ARI
--				ON I.[intInvoiceId] = ARI.[intInvoiceId]
--		WHERE  
--			ARI.[ysnPosted] = 0
		

--	END
																												
	RETURN
END
