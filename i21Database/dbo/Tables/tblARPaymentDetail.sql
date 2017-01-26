CREATE TABLE [dbo].[tblARPaymentDetail] (
    [intPaymentDetailId]		INT             IDENTITY (1, 1) NOT NULL,
    [intPaymentId]				INT             NOT NULL,
    [intInvoiceId]				INT             NULL,
	[intBillId]					INT             NULL,
	[intTermId]					INT             NULL,
    [intAccountId]				INT             NOT NULL,
    [dblInvoiceTotal]			NUMERIC (18, 6) NULL,
    [dblDiscount]				NUMERIC (18, 6) NULL,	
	[dblDiscountAvailable]		NUMERIC (18, 6) NULL DEFAULT 0,	
	[dblInterest]				NUMERIC (18, 6) NULL,
    [dblAmountDue]				NUMERIC (18, 6) NULL,
    [dblPayment]				NUMERIC (18, 6) NULL,	
	[strInvoiceReportNumber]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]			INT             NOT NULL,
    CONSTRAINT [PK_tblARPaymentDetail_intPaymentDetailId] PRIMARY KEY CLUSTERED ([intPaymentDetailId] ASC),
    CONSTRAINT [FK_tblARPaymentDetail_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARPaymentDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARPaymentDetail_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblARPaymentDetail_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId])
);



