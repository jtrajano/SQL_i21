CREATE TABLE [dbo].[tblAPProvisionalAppliedPrepaidAndDebit]
(
	[intId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intBillId] INT NULL, 
    [intBillDetailApplied] INT NULL, 
	[intLineApplied] INT NULL, 
	[intTransactionId] INT NOT NULL,
	[strTransactionNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intContractHeaderId] INT NULL,
	[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intPrepayType] INT NULL,
	[dblTotal] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblBillAmount] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblBalance] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblAmountApplied] DECIMAL(18, 6) NOT NULL DEFAULT 0,
    [ysnApplied] BIT NOT NULL DEFAULT 0,
	[intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblAPProvisionalAppliedPrepaidAndDebit_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPProvisional] ([intBillId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPProvisionalAppliedPrepaidAndDebit_intTransactionId] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblAPProvisional] ([intBillId]),
	CONSTRAINT [FK_tblAPProvisionalAppliedPrepaidAndDebit_intBillDetailApplied] FOREIGN KEY ([intBillDetailApplied]) REFERENCES [dbo].[tblAPProvisionalDetail] ([intBillDetailId]), -- this is used as checking if we are to execute the fix for the data
	 
)
GO