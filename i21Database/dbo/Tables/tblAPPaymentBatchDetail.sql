CREATE TABLE [dbo].[tblAPPaymentBatchDetail]
(
	[intPaymentBatchDetailId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPaymentBatchId] INT NULL, 
    [intBillId] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0,
)
