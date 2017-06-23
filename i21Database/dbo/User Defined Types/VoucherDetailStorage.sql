CREATE TYPE [dbo].[VoucherDetailStorage] AS TABLE
(
	[intCustomerStorageId]		INT NOT NULL,
	[intItemId]					INT	NOT NULL,
	[intAccountId]					INT	NOT NULL,
	[dblQtyReceived]				DECIMAL(18, 6)	NOT NULL, 
	[strMiscDescription]			NVARCHAR(500)	NULL, 
    [dblCost]					DECIMAL(18, 6)	NOT NULL,
	[intContractDetailId]		INT NULL,
	[intContractHeaderId]		INT NULL
	PRIMARY KEY CLUSTERED ([intCustomerStorageId] ASC) 
)
