CREATE TYPE [dbo].[PaymentDetailStaging] AS TABLE
(
	[intBillId]          INT             NULL,
	[intInvoiceId]		 INT NULL ,
    [intAccountId]       INT             NOT NULL,
    [dblDiscount]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblAmountDue]       DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblPayment]         DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblInterest]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblTotal]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblWithheld]		DECIMAL(18, 6) NOT NULL DEFAULT 0
)
GO