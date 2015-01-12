CREATE TABLE [dbo].[tblARPaymentDetail] (
    [intPaymentDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intPaymentId]       INT             NOT NULL,
    [intInvoiceId]       INT             NOT NULL,
	[intTermId]			 INT             NULL,
    [intAccountId]       INT             NOT NULL,
    [dblInvoiceTotal]    NUMERIC (18, 6) NULL,
    [dblDiscount]        NUMERIC (18, 6) NULL,
    [dblAmountDue]       NUMERIC (18, 6) NULL,
    [dblPayment]         NUMERIC (18, 6) NULL,
    [intConcurrencyId]   INT             NOT NULL,
    CONSTRAINT [PK_tblARPaymentDetail] PRIMARY KEY CLUSTERED ([intPaymentDetailId] ASC),
    CONSTRAINT [FK_tblARPaymentDetail_tblARPayment] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId]) ON DELETE CASCADE
);



