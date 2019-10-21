CREATE TABLE [dbo].[tblAPVoucherApprover]
(
	[intVoucherApproverId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intVoucherId] INT NOT NULL, 
	[intApproverId] INT NOT NULL,
    [intAlternateApproverId] INT NULL, 
	[intApproverLevel] INT NOT NULL, 
    [ysnApproved] BIT NOT NULL DEFAULT 0, 
	[ysnAlternateApproved] BIT NOT NULL DEFAULT 0,
    [dtmDateApproved] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblAPVoucherApproval_tblAPBill] FOREIGN KEY ([intVoucherId]) REFERENCES [dbo].[tblAPBill] ([intBillId]) ON DELETE CASCADE,
)

GO

CREATE NONCLUSTERED INDEX [IX_tblAPVoucherApprover_intVoucherId] ON [dbo].[tblAPVoucherApprover] ([intVoucherId], [intApproverId], [intAlternateApproverId])
