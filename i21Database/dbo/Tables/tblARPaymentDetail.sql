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
	[dtmDiscountDate]				DATETIME		NULL,
    [intConcurrencyId]				INT             NOT NULL,
    CONSTRAINT [PK_tblARPaymentDetail_intPaymentDetailId] PRIMARY KEY CLUSTERED ([intPaymentDetailId] ASC),
    CONSTRAINT [FK_tblARPaymentDetail_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARPaymentDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARPaymentDetail_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblARPaymentDetail_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]),
	CONSTRAINT [FK_tblARPaymentDetail_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
	--CONSTRAINT [FK_tblARPaymentDetail_tblSMCurrencyExchangeRate_intCurrencyExchangeRateId] FOREIGN KEY ([intCurrencyExchangeRateId]) REFERENCES [tblSMCurrencyExchangeRate]([intCurrencyExchangeRateId])
);

GO
CREATE TRIGGER trg_tblARPaymentDetailUpdate
ON dbo.tblARPaymentDetail
INSTEAD OF UPDATE
AS
BEGIN
	--Apply changes to i21Database\Scripts\Post-Deployment\AR\DefaultData\99_ReCreateTriggers.sql

	--SELECT ysnPosted FROM inserted WHERE ysnPosted = 1
	DECLARE @ysnPosted AS VARCHAR(MAX) 
	DECLARE @ysnPostedNew as VARCHAR(MAX)
	SELECT @ysnPosted = P.ysnPosted FROM tblARPayment P inner join deleted d on d.intPaymentId = P.intPaymentId AND P.intCurrentStatus <> 5
	SELECT @ysnPostedNew = P.ysnPosted FROM tblARPayment P inner join deleted d on d.intPaymentId = P.intPaymentId
		
	IF(@ysnPosted = 1 and @ysnPostedNew != 0)
		RAISERROR('Cannot update detail of posted payment',16,1)
	ELSE
		UPDATE PD
		SET  PD.intInvoiceId                   =  i.intInvoiceId                 
			,PD.intBillId                      =  i.intBillId                    
			,PD.strTransactionNumber           =  i.strTransactionNumber         
			,PD.intTermId                      =  i.intTermId                    
			,PD.intAccountId                   =  i.intAccountId                 
			,PD.dblInvoiceTotal                =  i.dblInvoiceTotal              
			,PD.dblBaseInvoiceTotal            =  i.dblBaseInvoiceTotal          
			,PD.dblDiscount                    =  i.dblDiscount                  
			,PD.dblBaseDiscount                =  i.dblBaseDiscount              
			,PD.dblDiscountAvailable           =  i.dblDiscountAvailable         
			,PD.dblBaseDiscountAvailable       =  i.dblBaseDiscountAvailable     
			,PD.dblInterest                    =  i.dblInterest                  
			,PD.dblBaseInterest                =  i.dblBaseInterest              
			,PD.dblAmountDue                   =  i.dblAmountDue                 
			,PD.dblBaseAmountDue               =  i.dblBaseAmountDue             
			,PD.dblPayment                     =  i.dblPayment                   
			,PD.dblBasePayment                 =  i.dblBasePayment               
			,PD.strInvoiceReportNumber         =  i.strInvoiceReportNumber       
			,PD.intCurrencyExchangeRateTypeId  =  i.intCurrencyExchangeRateTypeId
			,PD.intCurrencyExchangeRateId      =  i.intCurrencyExchangeRateId    
			,PD.dblCurrencyExchangeRate        =  i.dblCurrencyExchangeRate      
			,PD.dtmDiscountDate                =  i.dtmDiscountDate              
			,PD.intConcurrencyId               =  i.intConcurrencyId             
		FROM tblARPaymentDetail PD
		INNER JOIN inserted i
			ON i.intPaymentDetailId = PD.intPaymentDetailId
END
GO

GO
CREATE NONCLUSTERED INDEX [PIndex_tblARPaymentDetail_intInvoiceId]
ON [dbo].[tblARPaymentDetail] ([intInvoiceId])

GO
CREATE NONCLUSTERED INDEX [PIndex_tblARPaymentDetail_intPaymentId]
ON [dbo].[tblARPaymentDetail] ([intPaymentId])
INCLUDE ([intInvoiceId],[dblInvoiceTotal],[dblPayment])