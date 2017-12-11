CREATE TABLE [dbo].[tblBBBuybackDetail](
	[intBuybackDetailId] [int] IDENTITY(1,1)  ,
	[intBuybackId] [int] NOT NULL,
	[intInvoiceDetailId ][int] NOT NULL,
    [dblBuybackQuantity] NUMERIC(18, 6) NOT NULL, 
    [intItemId] INT NOT NULL DEFAULT 0, 
    [intProgramRateId] INT NULL, 
    [dblBuybackRate] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblReimbursementAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intBillDetailId] INT NULL, 
    [intProgramId] INT NOT NULL, 
    CONSTRAINT [PK_tblBBBuybackDetail] PRIMARY KEY ([intBuybackDetailId]), 
	
)
GO
