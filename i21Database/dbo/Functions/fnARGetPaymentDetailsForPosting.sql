CREATE FUNCTION [dbo].[fnARGetPaymentDetailsForPosting]
(
     @PaymentIds	[dbo].[Id]      READONLY
    ,@PostDate      DATETIME        = NULL
    ,@BatchId       NVARCHAR(40)    = NULL
    ,@BankAccountId INT             = NULL
    ,@Post          BIT             = NULL
    ,@Recap         BIT             = 0
    ,@UserId        BIT             = NULL
)
RETURNS @returntable TABLE
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
AS
BEGIN

DECLARE	@ARAccount              INT
       ,@DiscountAccount        INT
       ,@WriteOffAccount        INT
       ,@IncomeInterestAccount  INT
       ,@GainLossAccount        INT
       ,@DefaultCurrencyId      INT
       ,@CFAccount              INT
       ,@NewAccountId           INT
       ,@AllowOtherUserToPost   BIT
       ,@ZeroDecimal            DECIMAL(18,6)

SET @ZeroDecimal = 0.000000
SET @ARAccount = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0)
SET @DiscountAccount = (SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
SET @WriteOffAccount = (SELECT TOP 1 intWriteOffAccountId FROM tblARCompanyPreference WHERE intWriteOffAccountId IS NOT NULL AND intWriteOffAccountId <> 0)
SET @IncomeInterestAccount = (SELECT TOP 1 intInterestIncomeAccountId FROM tblARCompanyPreference WHERE intInterestIncomeAccountId IS NOT NULL AND intInterestIncomeAccountId <> 0)
SET @GainLossAccount = (SELECT TOP 1 intAccountsReceivableRealizedId FROM tblSMMultiCurrency WHERE intAccountsReceivableRealizedId IS NOT NULL AND intAccountsReceivableRealizedId <> 0)
SET @CFAccount = (SELECT TOP 1 intGLAccountId FROM tblCFCompanyPreference WHERE intGLAccountId IS NOT NULL AND intGLAccountId <> 0)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WHERE intEntityUserSecurityId = @UserId)
SET @NewAccountId = (SELECT TOP 1 [intGLAccountId] FROM tblCMBankAccount WHERE [intBankAccountId] = @BankAccountId)

DECLARE @Header AS [dbo].[ReceivePaymentPostingTable]
INSERT @Header
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
    ,[dtmDatePaid]
    ,[dtmPostDate]
    ,[intWriteOffAccountId]
    ,[intAccountId]
    ,[intBankAccountId]
    ,[intARAccountId]
    ,[intDiscountAccount]
    ,[intInterestAccount]
    ,[intCFAccountId]
    ,[intGainLossAccount]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]

    ,[dblAmountPaid]
    ,[dblBaseAmountPaid]
    ,[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]
    ,[dblPayment]
    ,[dblBasePayment]
    ,[dblDiscount]
    ,[dblBaseDiscount]
    ,[dblInterest]
    ,[dblBaseInterest]
    ,[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]
    ,[dblAmountDue]
    ,[dblBaseAmountDue]

    ,[intInvoiceId]
    ,[ysnExcludedFromPayment]
    ,[ysnForgiven]
	,[intBillId]
    ,[strTransactionNumber]
    ,[strTransactionType]
    ,[strType]
    ,[intTransactionAccountId]
    ,[ysnTransactionPosted]
	,[ysnTransactionPaid]
    ,[ysnTransactionProcessed]
    ,[dtmTransactionPostDate]
	,[dblTransactionDiscount]
    ,[dblBaseTransactionDiscount]
    ,[dblTransactionInterest]
    ,[dblBaseTransactionInterest]
    ,[dblTransactionAmountDue]
    ,[dblBaseTransactionAmountDue]
    ,[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]
    ,[strRateType])
SELECT 
     [intTransactionId]                 = ARP.[intPaymentId]
    ,[intTransactionDetailId]           = NULL
    ,[strTransactionId]                 = ARP.[strRecordNumber]
    ,[strReceivePaymentType]            = ARP.[strReceivePaymentType]
    ,[intEntityCustomerId]              = ARP.[intEntityCustomerId]
    ,[strCustomerNumber]                = ARC.[strCustomerNumber]
    ,[intCompanyLocationId]             = ARP.[intLocationId]
    ,[strLocationName]                  = SMCL.[strLocationName]
    ,[intUndepositedFundsId]            = CASE WHEN @BankAccountId IS NULL
                                               THEN (
											        CASE WHEN (CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARP.[strPaymentMethod],'')))) > 0 THEN RTRIM(LTRIM(ARP.[strPaymentMethod])) ELSE RTRIM(LTRIM(ISNULL(SMPM.[strPaymentMethod],''))) END) <> 'CF Invoice' 
                                                         THEN ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId])
                                                         ELSE ARP.intAccountId
                                                    END
                                                    )
                                                ELSE
												(SELECT [intGLAccountId] FROM tblCMBankAccount WHERE [intBankAccountId] = @BankAccountId)
                                           END
    ,[intSalesAdvAcct]                  = SMCL.[intSalesAdvAcct]
    ,[intCurrencyId]                    = ARP.[intCurrencyId]
    ,[intPaymentMethodId]               = ARP.[intPaymentMethodId]
    ,[strPaymentMethod]                 = CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARP.[strPaymentMethod],'')))) > 0 THEN RTRIM(LTRIM(ARP.[strPaymentMethod])) ELSE RTRIM(LTRIM(ISNULL(SMPM.[strPaymentMethod],''))) END
    ,[strNotes]                         = ARP.[strNotes]
    ,[dtmDatePaid]                      = ARP.[dtmDatePaid]
    ,[dtmPostDate]                      = @PostDate
    ,[intWriteOffAccountId]             = ISNULL(ARP.[intWriteOffAccountId], @WriteOffAccount)
    ,[intAccountId]                     = ISNULL(ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId]), ARP.[intAccountId])
    ,[intBankAccountId]                 = ARP.[intBankAccountId]
    ,[intARAccountId]                   = ISNULL(SMCL.[intARAccount], @ARAccount)
    ,[intDiscountAccount]               = ISNULL(SMCL.[intSalesDiscounts], @DiscountAccount)
    ,[intInterestAccount]               = ISNULL(SMCL.[intInterestAccountId], @IncomeInterestAccount)
    ,[intCFAccountId]                   = @CFAccount
    ,[intGainLossAccount]               = @GainLossAccount
	,[ysnPosted]                        = ARP.[ysnPosted]
    ,[ysnInvoicePrepayment]             = ARP.[ysnInvoicePrepayment]
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARP.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]   = @AllowOtherUserToPost

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ARP.[dblBaseAmountPaid]
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ARP.[dblBaseUnappliedAmount]
    ,[dblPayment]                       = @ZeroDecimal
    ,[dblBasePayment]                   = @ZeroDecimal
    ,[dblDiscount]                      = @ZeroDecimal
    ,[dblBaseDiscount]                  = @ZeroDecimal
    ,[dblInterest]                      = @ZeroDecimal
    ,[dblBaseInterest]                  = @ZeroDecimal
    ,[dblInvoiceTotal]                  = @ZeroDecimal
    ,[dblBaseInvoiceTotal]              = @ZeroDecimal
    ,[dblAmountDue]                     = @ZeroDecimal
    ,[dblBaseAmountDue]                 = @ZeroDecimal

    ,[intInvoiceId]                     = NULL
    ,[ysnExcludedFromPayment]           = 0
    ,[ysnForgiven]                      = 0
	,[intBillId]                        = NULL
    ,[strTransactionNumber]             = ''
    ,[strTransactionType]               = ''
    ,[strType]                          = ''
    ,[intTransactionAccountId]          = NULL
    ,[ysnTransactionPosted]             = 0
	,[ysnTransactionPaid]               = 0
    ,[ysnTransactionProcessed]          = 0
    ,[dtmTransactionPostDate]           = NULL
	,[dblTransactionDiscount]           = @ZeroDecimal
    ,[dblBaseTransactionDiscount]       = @ZeroDecimal
    ,[dblTransactionInterest]           = @ZeroDecimal
    ,[dblBaseTransactionInterest]       = @ZeroDecimal
    ,[dblTransactionAmountDue]          = @ZeroDecimal
    ,[dblBaseTransactionAmountDue]      = @ZeroDecimal
    ,[intCurrencyExchangeRateTypeId]    = NULL
    ,[dblCurrencyExchangeRate]          = @ZeroDecimal
    ,[strRateType]                      = ''
    
FROM
    tblARPayment ARP
INNER JOIN
    @PaymentIds P
        ON ARP.[intPaymentId] = P.[intId]
INNER JOIN
    (
    SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH(NoLock)
    ) ARC
        ON ARP.[intEntityCustomerId] = ARC.[intEntityId]
LEFT OUTER JOIN
    (
    SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId], [intSalesAdvAcct], [intInterestAccountId], [intSalesDiscounts], [intARAccount] FROM tblSMCompanyLocation  WITH(NoLock)
    ) SMCL
        ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
    (
    SELECT [intPaymentMethodID], [strPaymentMethod] FROM tblSMPaymentMethod WITH(NoLock)
    ) SMPM
        ON ARP.[intPaymentMethodId] = SMPM.[intPaymentMethodID]
OPTION(recompile)

DECLARE @Detail AS [dbo].[ReceivePaymentPostingTable]
INSERT @Detail
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
    ,[dtmDatePaid]
    ,[dtmPostDate]
    ,[intWriteOffAccountId]
    ,[intAccountId]
    ,[intBankAccountId]
    ,[intARAccountId]
    ,[intDiscountAccount]
    ,[intInterestAccount]
    ,[intCFAccountId]
    ,[intGainLossAccount]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]

    ,[dblAmountPaid]
    ,[dblBaseAmountPaid]
    ,[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]
    ,[dblPayment]
    ,[dblBasePayment]
    ,[dblDiscount]
    ,[dblBaseDiscount]
    ,[dblInterest]
    ,[dblBaseInterest]
    ,[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]
    ,[dblAmountDue]
    ,[dblBaseAmountDue]

    ,[intInvoiceId]
    ,[ysnExcludedFromPayment]
    ,[ysnForgiven]
	,[intBillId]
    ,[strTransactionNumber]
    ,[strTransactionType]
    ,[strType]
    ,[intTransactionAccountId]
    ,[ysnTransactionPosted]
	,[ysnTransactionPaid]
    ,[ysnTransactionProcessed]
    ,[dtmTransactionPostDate]
	,[dblTransactionDiscount]
    ,[dblBaseTransactionDiscount]
    ,[dblTransactionInterest]
    ,[dblBaseTransactionInterest]
    ,[dblTransactionAmountDue]
    ,[dblBaseTransactionAmountDue]
    ,[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]
    ,[strRateType])
SELECT 
     [intTransactionId]                 = ARP.[intTransactionId]
    ,[intTransactionDetailId]           = ARPD.[intPaymentDetailId]
    ,[strTransactionId]                 = ARP.[strTransactionId]
    ,[strReceivePaymentType]            = ARP.[strReceivePaymentType]
    ,[intEntityCustomerId]              = ARP.[intEntityCustomerId]
    ,[strCustomerNumber]                = ARP.[strCustomerNumber]
    ,[intCompanyLocationId]             = ARP.[intCompanyLocationId]
    ,[strLocationName]                  = ARP.[strLocationName]
    ,[intUndepositedFundsId]            = ARP.[intUndepositedFundsId]
    ,[intSalesAdvAcct]                  = ARP.[intSalesAdvAcct]
    ,[intCurrencyId]                    = ARP.[intCurrencyId]
    ,[intPaymentMethodId]               = ARP.[intPaymentMethodId]
    ,[strPaymentMethod]                 = ARP.[strPaymentMethod]
    ,[strNotes]                         = ARP.[strNotes]
    ,[dtmDatePaid]                      = CAST(ARP.[dtmDatePaid] AS DATE)
    ,[dtmPostDate]                      = ARP.[dtmPostDate]
    ,[intWriteOffAccountId]             = ARP.[intWriteOffAccountId]
    ,[intAccountId]                     = ARP.[intAccountId]
    ,[intBankAccountId]                 = ARP.[intBankAccountId]
    ,[intARAccountId]                   = ARP.[intARAccountId]
    ,[intDiscountAccount]               = ARP.[intDiscountAccount]
    ,[intInterestAccount]               = ARP.[intInterestAccount]
    ,[intCFAccountId]                   = ARP.[intCFAccountId]
    ,[intGainLossAccount]               = ARP.[intGainLossAccount]
	,[ysnPosted]                        = ARP.[ysnPosted]
    ,[ysnInvoicePrepayment]             = ARP.[ysnInvoicePrepayment]
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARP.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]   = @AllowOtherUserToPost

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ARP.[dblBaseAmountPaid]
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ARP.[dblBaseUnappliedAmount]
    ,[dblPayment]                       = ARPD.[dblPayment]
    ,[dblBasePayment]                   = ARPD.[dblBasePayment]
    ,[dblDiscount]                      = ARPD.[dblDiscount]
    ,[dblBaseDiscount]                  = ARPD.[dblBaseDiscount]
    ,[dblInterest]                      = ARPD.[dblInterest]
    ,[dblBaseInterest]                  = ARPD.[dblBaseInterest]
    ,[dblInvoiceTotal]                  = ARPD.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ARPD.[dblBaseInvoiceTotal]
    ,[dblAmountDue]                     = ARPD.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARPD.[dblBaseAmountDue]

    ,[intInvoiceId]                     = ARI.[intInvoiceId]
    ,[ysnExcludedFromPayment]           = ARI.[ysnExcludeFromPayment]
    ,[ysnForgiven]                      = ARI.[ysnForgiven]
	,[intBillId]                        = NULL
    ,[strTransactionNumber]             = ARI.[strInvoiceNumber]
    ,[strTransactionType]               = ARI.[strTransactionType]
    ,[strType]                          = ARI.[strType]
    ,[intTransactionAccountId]          = ARPD.[intAccountId]
    ,[ysnTransactionPosted]             = ARI.[ysnPosted]
	,[ysnTransactionPaid]               = ARI.[ysnPaid]
    ,[ysnTransactionProcessed]          = ARI.[ysnProcessed]
    ,[dtmTransactionPostDate]           = ARI.[dtmPostDate]
	,[dblTransactionDiscount]           = ARI.[dblDiscount]
    ,[dblBaseTransactionDiscount]       = ARI.[dblBaseDiscount]
    ,[dblTransactionInterest]           = ARI.[dblInterest]
    ,[dblBaseTransactionInterest]       = ARI.[dblBaseInterest]
    ,[dblTransactionAmountDue]          = ARI.[dblAmountDue]
    ,[dblBaseTransactionAmountDue]      = ARI.[dblBaseAmountDue]
 	,[intCurrencyExchangeRateTypeId]    = ARPD.[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]          = ARPD.[dblCurrencyExchangeRate]
    ,[strRateType]                      = SMCER.[strCurrencyExchangeRateType]
FROM
    tblARPaymentDetail ARPD
INNER JOIN
    @PaymentIds P
        ON ARPD.[intPaymentId] = P.[intId]
INNER JOIN
    @Header ARP
        ON ARPD.[intPaymentId] = ARP.[intTransactionId]
INNER JOIN
    (SELECT [intInvoiceId], [ysnExcludeFromPayment], [ysnForgiven], [strInvoiceNumber], [strTransactionType], [strType], [ysnPosted], [ysnPaid], [ysnProcessed], [dtmPostDate], [dblDiscount], [dblBaseDiscount], [dblInterest], [dblBaseInterest], [dblAmountDue], [dblBaseAmountDue] FROM tblARInvoice) ARI
        ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
LEFT OUTER JOIN
    (SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType) SMCER
        ON ARP.[intCurrencyExchangeRateTypeId] = SMCER.[intCurrencyExchangeRateTypeId]

UNION

SELECT 
     [intTransactionId]                 = ARP.[intTransactionId]
    ,[intTransactionDetailId]           = ARPD.[intPaymentDetailId]
    ,[strTransactionId]                 = ARP.[strTransactionId]
    ,[strReceivePaymentType]            = ARP.[strReceivePaymentType]
    ,[intEntityCustomerId]              = ARP.[intEntityCustomerId]
    ,[strCustomerNumber]                = ARP.[strCustomerNumber]
    ,[intCompanyLocationId]             = ARP.[intCompanyLocationId]
    ,[strLocationName]                  = ARP.[strLocationName]
    ,[intUndepositedFundsId]            = ARP.[intUndepositedFundsId]
    ,[intSalesAdvAcct]                  = ARP.[intSalesAdvAcct]
    ,[intCurrencyId]                    = ARP.[intCurrencyId]
    ,[intPaymentMethodId]               = ARP.[intPaymentMethodId]
    ,[strPaymentMethod]                 = ARP.[strPaymentMethod]
    ,[strNotes]                         = ARP.[strNotes]
    ,[dtmDatePaid]                      = ARP.[dtmDatePaid]
    ,[dtmPostDate]                      = ARP.[dtmPostDate]
    ,[intWriteOffAccountId]             = ARP.[intWriteOffAccountId]
    ,[intAccountId]                     = ARP.[intAccountId]
    ,[intBankAccountId]                 = ARP.[intBankAccountId]
    ,[intARAccountId]                   = ARP.[intARAccountId]
    ,[intDiscountAccount]               = ARP.[intDiscountAccount]
    ,[intInterestAccount]               = ARP.[intInterestAccount]
    ,[intCFAccountId]                   = ARP.[intCFAccountId]
    ,[intGainLossAccount]               = ARP.[intGainLossAccount]
	,[ysnPosted]                        = ARP.[ysnPosted]
    ,[ysnInvoicePrepayment]             = ARP.[ysnInvoicePrepayment]
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARP.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]   = @AllowOtherUserToPost

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ARP.[dblBaseAmountPaid]
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ARP.[dblBaseUnappliedAmount]
    ,[dblPayment]                       = ARPD.[dblPayment]
    ,[dblBasePayment]                   = ARPD.[dblBasePayment]
    ,[dblDiscount]                      = ARPD.[dblDiscount]
    ,[dblBaseDiscount]                  = ARPD.[dblBaseDiscount]
    ,[dblInterest]                      = ARPD.[dblInterest]
    ,[dblBaseInterest]                  = ARPD.[dblBaseInterest]
    ,[dblInvoiceTotal]                  = ARPD.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ARPD.[dblBaseInvoiceTotal]
    ,[dblAmountDue]                     = ARPD.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARPD.[dblBaseAmountDue]

    ,[intInvoiceId]                     = NULL
    ,[ysnExcludedFromPayment]           = 0
    ,[ysnForgiven]                      = 0
	,[intBillId]                        = APB.[intBillId]
    ,[strTransactionNumber]             = APB.[strBillId]
    ,[strTransactionType]               = (CASE WHEN APB.[intTransactionType] = 1 THEN 'Voucher'
												WHEN APB.[intTransactionType] = 2 THEN 'Vendor Prepayment'
												WHEN APB.[intTransactionType] = 3 THEN 'Debit Memo'
												WHEN APB.[intTransactionType] = 7 THEN 'Invalid Type'
												WHEN APB.[intTransactionType] = 9 THEN '1099 Adjustment'
												WHEN APB.[intTransactionType] = 11 THEN 'Claim'
												WHEN APB.[intTransactionType] = 13 THEN 'Basis Advance'
												WHEN APB.[intTransactionType] = 14 THEN 'Deferred Interest'
												ELSE 'Invalid Type' COLLATE Latin1_General_CI_AS
										   END)
    ,[strType]                          = ''
    ,[intTransactionAccountId]          = ARPD.[intAccountId]
    ,[ysnTransactionPosted]             = APB.[ysnPosted]
	,[ysnTransactionPaid]               = APB.[ysnPaid]
	,[ysnTransactionProcessed]          = 0
    ,[dtmTransactionPostDate]           = APB.[dtmBillDate]
	,[dblTransactionDiscount]           = APB.[dblDiscount]
    ,[dblBaseTransactionDiscount]       = APB.[dblDiscount]
    ,[dblTransactionInterest]           = APB.[dblInterest]
    ,[dblBaseTransactionInterest]       = APB.[dblInterest]
    ,[dblTransactionAmountDue]          = APB.[dblAmountDue]
    ,[dblBaseTransactionAmountDue]      = APB.[dblAmountDue]
 	,[intCurrencyExchangeRateTypeId]    = ARPD.[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]          = ARPD.[dblCurrencyExchangeRate]
    ,[strRateType]                      = SMCER.[strCurrencyExchangeRateType]    
FROM
    tblARPaymentDetail ARPD
INNER JOIN
    @PaymentIds P
        ON ARPD.[intPaymentId] = P.[intId]
INNER JOIN
    @Header ARP
        ON ARP.[intTransactionId] = ARPD.[intPaymentId]
INNER JOIN
    (SELECT [intBillId], [strBillId], [ysnPosted], [ysnPaid], [dtmBillDate], [dblDiscount], [dblInterest], [dblAmountDue], [intAccountId], [intTransactionType] FROM tblAPBill) APB
        ON ARPD.[intBillId] = APB.[intBillId]
LEFT OUTER JOIN
    (SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType) SMCER
        ON ARP.[intCurrencyExchangeRateTypeId] = SMCER.[intCurrencyExchangeRateTypeId]
OPTION(recompile)


INSERT INTO @returntable
SELECT * FROM @Header
UNION
SELECT * FROM @Detail



	RETURN
END
