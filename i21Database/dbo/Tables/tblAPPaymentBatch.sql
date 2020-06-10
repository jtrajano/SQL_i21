CREATE TABLE [dbo].[tblAPPaymentBatch]
(
	[intPaymentBatchId] INT NOT NULL PRIMARY KEY IDENTITY,
    [strPaymentBatchId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dtmDatePaid] DATETIME NULL,
    [ysnShowDeferred] BIT NULL,
    [intBankAccountId] INT NULL,
    [dblUnpaidDeferredPayments] DECIMAL(18, 6) NULL,
    [intCountDeferredPayments] INT NULL,
    [intPaymentMethodId] INT NULL,
    [dblTotalAmount] DECIMAL(18, 6) NULL,
    [ysnPosted] BIT NULL DEFAULT 0,
    [ysnApproved] BIT NULL DEFAULT 0,
    [intUserId] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0,
)
