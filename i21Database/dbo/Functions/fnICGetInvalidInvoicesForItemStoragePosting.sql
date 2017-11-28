CREATE FUNCTION [dbo].[fnICGetInvalidInvoicesForItemStoragePosting]
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
	INSERT INTO @returntable (
			[intInvoiceId]			
			,[strInvoiceNumber]		
			,[strTransactionType]	
			,[intInvoiceDetailId]	
			,[intItemId]			
			,[strBatchId]			
			,[strPostingError]		
	)
	SELECT 
			 [intInvoiceId]			= vi.[intTransactionId]
			,[strInvoiceNumber]		= vi.[strTransactionId]		
			,[strTransactionType]	= 'Invoice'
			,[intInvoiceDetailId]	= vi.[intTransactionDetailId] 
			,[intItemId]			= vi.[intItemId] 
			,[strBatchId]			= ''
			,[strPostingError]		= Errors.strText
	FROM	@Items vi 
			CROSS APPLY dbo.fnGetItemCostingOnPostStorageErrors(
				vi.intItemId
				, vi.intItemLocationId
				, vi.intItemUOMId
				, vi.intSubLocationId
				, vi.intStorageLocationId
				, vi.dblQty
				, vi.intLotId
				, vi.dblCost
			) Errors
																												
	RETURN
END
