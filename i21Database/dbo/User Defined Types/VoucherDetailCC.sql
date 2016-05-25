CREATE TYPE [dbo].[VoucherDetailCC] AS TABLE
(
	[intAccountId]					INT NOT NULL,
	[intSiteDetailId]				INT	NOT NULL,
	[strMiscDescription]			NVARCHAR(500) NULL,
	[dblCost]						DECIMAL(18, 6)	NOT NULL, 
	[dblQtyReceived]				DECIMAL(18, 6)	NOT NULL
)
