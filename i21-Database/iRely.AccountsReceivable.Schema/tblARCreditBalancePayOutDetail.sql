CREATE TABLE [dbo].[tblARCreditBalancePayOutDetail]
(
	[intCreditBalancePayOutDetailId]    INT             IDENTITY (1, 1) NOT NULL,
	[intCreditBalancePayOutId]          INT             NOT NULL,
	[intEntityCustomerId]               INT             NULL,
	[intPaymentId]                      INT             NULL,
	[intBillId]                         INT             NULL,
	[intInvoiceId]                      INT             NULL,
	[ysnProcess]                        BIT             CONSTRAINT [DF_tblARCreditBalancePayOutDetail_ysnProcess] DEFAULT ((0)) NOT NULL,
	[ysnSuccess]                        BIT             CONSTRAINT [DF_tblARCreditBalancePayOutDetail_ysnSuccess] DEFAULT ((0)) NOT NULL,
	[strMessage]                        NVARCHAR(500)   COLLATE Latin1_General_CI_AS	NULL,
	[intConcurrencyId]                  INT             NOT NULL CONSTRAINT [DF_tblARCreditBalancePayOutDetail_intConcurrencyId] DEFAULT ((0)),
	CONSTRAINT [PK_tblARCreditBalancePayOutDetail_intCreditBalancePayOutDetailId] PRIMARY KEY CLUSTERED ([intCreditBalancePayOutDetailId] ASC),
	CONSTRAINT [FK_tblARCreditBalancePayOutDetail_tblARCreditBalancePayOut] FOREIGN KEY ([intCreditBalancePayOutId]) REFERENCES [dbo].[tblARCreditBalancePayOut] ([intCreditBalancePayOutId]) ON DELETE CASCADE,
	-- CONSTRAINT [FK_tblARCreditBalancePayOutDetail_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblARCreditBalancePayOutDetail_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblARCreditBalancePayOutDetail_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId]),
	CONSTRAINT [FK_tblARCreditBalancePayOutDetail_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]),
	CONSTRAINT [FK_tblARCreditBalancePayOutDetail_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId])
)
