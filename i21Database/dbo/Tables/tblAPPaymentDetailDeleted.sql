CREATE TABLE [dbo].[tblAPPaymentDetailDeleted] (
    [intPaymentDetailId] INT             NOT NULL,
    [intPaymentId]       INT             NOT NULL,
    [intBillId]          INT             NULL,
    [intAccountId]       INT             NOT NULL,
    [dblDiscount]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblAmountDue]       DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblPayment]         DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblInterest]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblTotal] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dblWithheld] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intInvoiceId] INT NULL,
	[dtmDateDeleted] DATETIME DEFAULT GETDATE()
)