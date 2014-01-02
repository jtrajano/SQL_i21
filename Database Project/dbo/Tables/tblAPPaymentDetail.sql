CREATE TABLE [dbo].[tblAPPaymentDetail] (
    [intPaymentDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intPaymentId]       INT             NOT NULL,
    [intBillId]          INT             NOT NULL,
    [intTermsId]         INT             NOT NULL,
    [intAccountId]       INT             NOT NULL,
    [dtmDueDate]         DATETIME        NOT NULL,
    [dblDiscount]        DECIMAL (18, 2) NOT NULL,
    [dblAmountDue]       DECIMAL (18, 2) NOT NULL,
    [dblPayment]         DECIMAL (18, 2) NOT NULL,
	[dblInterest]        DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.tblAPPaymentDetail] PRIMARY KEY CLUSTERED ([intPaymentDetailId] ASC),
    CONSTRAINT [FK_dbo.tblAPPaymentDetail_dbo.tblAPPayments_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblAPPayment] ([intPaymentId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_intPaymentId]
    ON [dbo].[tblAPPaymentDetail]([intPaymentId] ASC);

