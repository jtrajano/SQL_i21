CREATE TABLE [dbo].[tblPOApprover]
(
	[intPOApproverId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPurchaseId] INT NOT NULL, 
	[intApproverId] INT NOT NULL,
    [intAlternateApproverId] INT NULL, 
	[intApproverLevel] INT NOT NULL, 
    [ysnApproved] BIT NOT NULL DEFAULT 0, 
	[ysnAlternateApproved] BIT NOT NULL DEFAULT 0,
    [dtmDateApproved] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblPOApproval_tblPOPurchase] FOREIGN KEY ([intPurchaseId]) REFERENCES [dbo].[tblPOPurchase] ([intPurchaseId]) ON DELETE CASCADE,
)
GO

CREATE NONCLUSTERED INDEX [IX_tblPOApprover_intPurchaseId] ON [dbo].[tblPOApprover] ([intPurchaseId], [intApproverId], [intAlternateApproverId])
