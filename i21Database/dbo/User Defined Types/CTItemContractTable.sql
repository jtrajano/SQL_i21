CREATE TYPE [dbo].[CTItemContractTable] AS TABLE
(
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	
		-- Header
		,[intTransactionId]				INT             NOT NULL		
		,[strTransactionId]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS
		,[intEntityCustomerId]			INT             NOT NULL
		,[strTransactionType]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS
		,[dtmDate]						DATETIME        NOT NULL
		,[intCurrencyId]				INT             NOT NULL
		,[intCompanyLocationId]			INT             NULL

		-- Detail 
		,[intInvoiceDetailId]			INT             NOT NULL
		,[intItemId]					INT             NULL
		,[strItemNo]					NVARCHAR (250)  COLLATE Latin1_General_CI_AS  NULL
		,[strItemDescription]			NVARCHAR (250)  COLLATE Latin1_General_CI_AS  NULL
		,[intItemUOMId]					INT             NULL
		,[dblQtyOrdered]				NUMERIC (38, 20) NULL
		,[dblQtyShipped]				NUMERIC (38, 20) NULL
		,[dblDiscount]					NUMERIC (18, 6) NULL
		,[dblPrice]						NUMERIC (18, 6) NULL
		,[dblTotalTax]					NUMERIC (18, 6) NULL
		,[dblTotal]						NUMERIC (18, 6) NULL		

		,[intItemContractHeaderId]		INT				NULL
		,[intItemContractDetailId]		INT				NULL
		,[intItemContractLineNo]		INT				NULL  
)
