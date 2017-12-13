CREATE TABLE [dbo].[tblBBBuybackCharge](
	[intBuybackChargeId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] INT NOT NULL, 
    [intBuybackId] INT NOT NULL, 
    [dblReimbursementAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intBillId] INT NULL, 
    [intInvoiceId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblBBBuybackCharge] PRIMARY KEY ([intBuybackChargeId]),
	CONSTRAINT [FK_tblBBBuybackCharge_tblBBBuyback] FOREIGN KEY (intBuybackId) REFERENCES [tblBBBuyback](intBuybackId) ON DELETE CASCADE, 
	
)
GO
