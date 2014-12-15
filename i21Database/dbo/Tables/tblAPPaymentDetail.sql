CREATE TABLE [dbo].[tblAPPaymentDetail] (
    [intPaymentDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intPaymentId]       INT             NOT NULL,
    [intBillId]          INT             NOT NULL,
    [intAccountId]       INT             NOT NULL,
    [dblDiscount]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblAmountDue]       DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblPayment]         DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblInterest]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblTotal] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dblWithheld] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_dbo.tblAPPaymentDetail] PRIMARY KEY CLUSTERED ([intPaymentDetailId] ASC),
    CONSTRAINT [FK_dbo.tblAPPaymentDetail_dbo.tblAPPayments_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblAPPayment] ([intPaymentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPPaymentDetail_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [tblAPBill]([intBillId]),
	CONSTRAINT [FK_tblAPPaymentDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
);


GO


CREATE NONCLUSTERED INDEX [IX_tblAPPaymentDetail_intPaymentId_intBillId] ON [dbo].[tblAPPaymentDetail] 
(
	[intBillId] ASC,
	[intPaymentId] ASC
)
WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
