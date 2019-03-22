CREATE TABLE [dbo].[tblAPBillDeferredInterest]
(
	[intBillDeferredInterestId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intBillId] INT NOT NULL,
	[intTransactionId] INT NOT NULL,
	CONSTRAINT [FK_tblAPBillDeferredInterest_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]),
	CONSTRAINT [FK_tblAPBillDeferredInterest_intTransactionId] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblAPBill] ([intBillId])
)
