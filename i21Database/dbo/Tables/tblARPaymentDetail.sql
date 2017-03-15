CREATE TABLE [dbo].[tblARPaymentDetail] (
    [intPaymentDetailId]			INT             IDENTITY (1, 1) NOT NULL,
    [intPaymentId]					INT             NOT NULL,
    [intInvoiceId]					INT             NULL,
	[intBillId]						INT             NULL,
	[strTransactionNumber]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[intTermId]						INT             NULL,
    [intAccountId]					INT             NOT NULL,
    [dblInvoiceTotal]				NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblInvoiceTotal] DEFAULT ((0)) NULL,
	[dblBaseInvoiceTotal]			NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblBaseInvoiceTotal] DEFAULT ((0)) NULL,
    [dblDiscount]					NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblDiscount] DEFAULT ((0)) NULL,	
	[dblBaseDiscount]				NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblBaseDiscount] DEFAULT ((0)) NULL,	
	[dblDiscountAvailable]			NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblDiscountAvailable] DEFAULT ((0)) NULL,
	[dblBaseDiscountAvailable]		NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblBaseDiscountAvailable] DEFAULT ((0)) NULL,
	[dblInterest]					NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblInterest] DEFAULT ((0)) NULL,
	[dblBaseInterest]				NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblBaseInterest] DEFAULT ((0)) NULL,
    [dblAmountDue]					NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblAmountDue] DEFAULT ((0)) NULL,
	[dblBaseAmountDue]				NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblBaseAmountDue] DEFAULT ((0)) NULL,
    [dblPayment]					NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblPayment] DEFAULT ((0)) NULL,	
	[dblBasePayment]				NUMERIC (18, 6) CONSTRAINT [DF_tblARPaymentDetail_dblBasePayment] DEFAULT ((0)) NULL,	
	[strInvoiceReportNumber]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyExchangeRateTypeId]	INT				NULL,
	[intCurrencyExchangeRateId]		INT				NULL,
	[dblCurrencyExchangeRate]		NUMERIC(18, 6)	CONSTRAINT [DF_tblARPaymentDetail_dblCurrencyExchangeRate] DEFAULT ((1)) NULL,
    [intConcurrencyId]				INT             NOT NULL,
    CONSTRAINT [PK_tblARPaymentDetail_intPaymentDetailId] PRIMARY KEY CLUSTERED ([intPaymentDetailId] ASC),
    CONSTRAINT [FK_tblARPaymentDetail_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARPaymentDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	--CONSTRAINT [FK_tblARPaymentDetail_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]), --Activate this on 17.3 for AR-3714
	CONSTRAINT [FK_tblARPaymentDetail_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]),
	CONSTRAINT [FK_tblARPaymentDetail_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
	--CONSTRAINT [FK_tblARPaymentDetail_tblSMCurrencyExchangeRate_intCurrencyExchangeRateId] FOREIGN KEY ([intCurrencyExchangeRateId]) REFERENCES [tblSMCurrencyExchangeRate]([intCurrencyExchangeRateId])
);



