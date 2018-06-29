CREATE TYPE [dbo].[ReceivePaymentPostingTable] AS TABLE
(
     [intTransactionId]                 INT             NOT NULL
    ,[intTransactionDetailId]           INT             NULL
    ,[strTransactionId]                 NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strReceivePaymentType]            NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[intEntityCustomerId]              INT             NOT NULL
    ,[strCustomerNumber]                NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
    ,[intCompanyLocationId]             INT             NULL
    ,[strLocationName]                  NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[intUndepositedFundsId]            INT             NULL
    ,[intSalesAdvAcct]                  INT             NULL
    ,[intCurrencyId]                    INT             NOT NULL
    ,[intPaymentMethodId]               INT             NOT NULL
    ,[strPaymentMethod]                 NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[strNotes]                         NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[dtmDatePaid]                      DATETIME        NOT NULL
    ,[dtmPostDate]                      DATETIME        NOT NULL
    ,[intWriteOffAccountId]             INT             NULL
    ,[intAccountId]                     INT             NULL
    ,[intBankAccountId]                 INT             NULL
    ,[intARAccountId]                   INT             NULL
    ,[intDiscountAccount]               INT             NULL
    ,[intInterestAccount]               INT             NULL
    ,[intCFAccountId]                   INT             NULL
    ,[intGainLossAccount]               INT             NULL
	,[ysnPosted]                        BIT             NULL
	,[ysnInvoicePrepayment]             BIT             NULL
    ,[strBatchId]                       NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnPost]                          BIT             NULL
    ,[ysnRecap]                         BIT             NULL
    ,[intEntityId]                      INT             NOT NULL
    ,[intUserId]                        INT             NOT NULL
    ,[ysnUserAllowedToPostOtherTrans]   BIT             NULL

    ,[dblAmountPaid]                    NUMERIC(18,6)   NULL
    ,[dblBaseAmountPaid]                NUMERIC(18,6)   NULL
    ,[dblUnappliedAmount]               NUMERIC(18,6)   NULL
    ,[dblBaseUnappliedAmount]           NUMERIC(18,6)   NULL
    ,[dblPayment]                       NUMERIC(18,6)   NULL
    ,[dblBasePayment]                   NUMERIC(18,6)   NULL
    ,[dblDiscount]                      NUMERIC(18,6)   NULL
    ,[dblBaseDiscount]                  NUMERIC(18,6)   NULL
    ,[dblInterest]                      NUMERIC(18,6)   NULL
    ,[dblBaseInterest]                  NUMERIC(18,6)   NULL
    ,[dblInvoiceTotal]                  NUMERIC(18,6)   NULL
    ,[dblBaseInvoiceTotal]              NUMERIC(18,6)   NULL
    ,[dblAmountDue]                     NUMERIC(18,6)   NULL
    ,[dblBaseAmountDue]                 NUMERIC(18,6)   NULL

    ,[intInvoiceId]                     INT             NULL
    ,[ysnExcludedFromPayment]           BIT             NULL
    ,[ysnForgiven]                      BIT             NULL
	,[intBillId]                        INT             NULL
    ,[strTransactionNumber]             NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]               NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strType]                          NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
	,[intTransactionAccountId]          INT             NULL
    ,[ysnTransactionPosted]             BIT             NULL
	,[ysnTransactionPaid]               BIT             NULL
	,[ysnTransactionProcessed]          BIT             NULL    
    ,[dtmTransactionPostDate]           DATETIME        NULL
	,[dblTransactionDiscount]           NUMERIC(18,6)   NULL
    ,[dblBaseTransactionDiscount]       NUMERIC(18,6)   NULL
    ,[dblTransactionInterest]           NUMERIC(18,6)   NULL
    ,[dblBaseTransactionInterest]       NUMERIC(18,6)   NULL
    ,[dblTransactionAmountDue]          NUMERIC(18,6)   NULL
    ,[dblBaseTransactionAmountDue]      NUMERIC(18,6)   NULL
	,[intCurrencyExchangeRateTypeId]    INT             NULL
    ,[dblCurrencyExchangeRate]          NUMERIC(18,6)   NULL
    ,[strRateType]                      NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL

			
)
