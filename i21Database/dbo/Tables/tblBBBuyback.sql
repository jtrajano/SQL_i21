CREATE TABLE [dbo].[tblBBBuyback](
	[intBuybackId] [int] IDENTITY(1,1) NOT NULL,
	[strReimbursementNo] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL, 
    [dtmReimbursementDate] DATETIME NOT NULL, 
    [dblReimbursementAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intBillId] INT NULL, 
    [intInvoiceId] INT NULL, 
    [intEntityId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [ysnPosted] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblBBBuyback] PRIMARY KEY ([intBuybackId]) 
	
	
)
GO
