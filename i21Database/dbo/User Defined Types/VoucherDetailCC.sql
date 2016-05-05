CREATE TYPE [dbo].[VoucherDetailCC] AS TABLE
(
	[intBillId]						INT NOT NULL,
	[intAccountId]					INT NOT NULL,
	[intSiteDetailId]				INT	NOT NULL,
	[strMiscDescription]			NVARCHAR(500) NULL,
	[dblCost]						DECIMAL(18, 6)	NOT NULL, 
	[dblQtyReceived]				DECIMAL(18, 6)	NOT NULL,
	PRIMARY KEY CLUSTERED ([intBillId] ASC, [intSiteDetailId] ASC) 
)
