CREATE FUNCTION [dbo].[fnICGetInvalidInvoicesForCosting]
(
	 @Items	[dbo].[ItemCostingTableType] READONLY
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

--		SELECT
--			 [intInvoiceId]			= I.[intTransactionId]
--			,[strInvoiceNumber]		= I.[strTransactionId]		
--			,[strTransactionType]	= 'Invoice'
--			,[intInvoiceDetailId]	= I.[intTransactionDetailId] 
--			,[intItemId]			= I.[intItemId] 
--			,[strBatchId]			= ''
--			,[strPostingError]		= ''
--		FROM 
--			@Items I			
																																			
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

--		SELECT
--			 [intInvoiceId]			= I.[intTransactionId]
--			,[strInvoiceNumber]		= I.[strTransactionId]		
--			,[strTransactionType]	= 'Invoice'
--			,[intInvoiceDetailId]	= I.[intTransactionDetailId] 
--			,[intItemId]			= I.[intItemId] 
--			,[strBatchId]			= ''
--			,[strPostingError]		= ''
--		FROM 
--			@Items I
		

--	END
																												
	RETURN
END
