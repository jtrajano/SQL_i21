CREATE PROCEDURE [dbo].[uspARPopulatePaymentDetailForPosting]
     @Param             NVARCHAR(MAX)   = NULL
    ,@BeginDate         DATE            = NULL
    ,@EndDate           DATE            = NULL
    ,@BeginTransaction  NVARCHAR(50)    = NULL
    ,@EndTransaction    NVARCHAR(50)    = NULL
    ,@IntegrationLogId  INT             = NULL
    ,@PaymemntIds       [PaymentId]     READONLY
    ,@BankAccountId     INT             = NULL
    ,@Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
    ,@UserId            INT				= 1
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE	@ARAccount              INT
       ,@DiscountAccount        INT
       ,@WriteOffAccount        INT
       ,@IncomeInterestAccount  INT
       ,@GainLossAccount        INT
       ,@DefaultCurrencyId      INT
       ,@CFAccount              INT
       ,@NewAccountId           INT
       ,@AllowOtherUserToPost   BIT
       ,@ZeroBit                BIT
       ,@OneBit                 BIT
       ,@ZeroDecimal            DECIMAL(18,6)
       ,@OneDecimal             DECIMAL(18,6)
       ,@OneHundredDecimal      DECIMAL(18,6)
       ,@Param2                 NVARCHAR(MAX)

SET @ZeroDecimal = 0.000000
SET @OneDecimal = 1.000000
SET @OneHundredDecimal = 100.000000
SET @OneBit = CAST(1 AS BIT)
SET @ZeroBit = CAST(0 AS BIT)

SET @ZeroDecimal = 0.000000
SET @ARAccount = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0)
SET @DiscountAccount = (SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
SET @WriteOffAccount = (SELECT TOP 1 intWriteOffAccountId FROM tblARCompanyPreference WHERE intWriteOffAccountId IS NOT NULL AND intWriteOffAccountId <> 0)
SET @IncomeInterestAccount = (SELECT TOP 1 intInterestIncomeAccountId FROM tblARCompanyPreference WHERE intInterestIncomeAccountId IS NOT NULL AND intInterestIncomeAccountId <> 0)
SET @GainLossAccount = (SELECT TOP 1 intAccountsReceivableRealizedId FROM tblSMMultiCurrency WHERE intAccountsReceivableRealizedId IS NOT NULL AND intAccountsReceivableRealizedId <> 0)
SET @CFAccount = (SELECT TOP 1 intGLAccountId FROM tblCFCompanyPreference WHERE intGLAccountId IS NOT NULL AND intGLAccountId <> 0)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @NewAccountId = (SELECT TOP 1 [intGLAccountId] FROM tblCMBankAccount WHERE [intBankAccountId] = @BankAccountId)
SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WHERE intEntityUserSecurityId = @UserId)
SET @Param2 = (CASE WHEN UPPER(@Param) = 'ALL' THEN '' ELSE @Param END)

--Header
INSERT INTO #ARPostPaymentHeader
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
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
    ,[intEntityCardInfoId]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]
    ,[ysnApplytoBudget]

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
    ,[strCustomerNumber]                = ARC.[strEntityNo]
    ,[strCustomerName]                  = ARC.[strName]
    ,[intCompanyLocationId]             = ARP.[intLocationId]
    ,[strLocationName]                  = SMCL.[strLocationName]
    ,[intUndepositedFundsId]            = CASE WHEN @BankAccountId IS NULL
                                               THEN (
											        CASE WHEN (CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARP.[strPaymentMethod],'')))) > 0 THEN RTRIM(LTRIM(ARP.[strPaymentMethod])) ELSE RTRIM(LTRIM(ISNULL(SMPM.[strPaymentMethod],''))) END) <> 'CF Invoice' 
                                                         THEN ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId])
                                                         ELSE ISNULL(ARP.intAccountId,ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId]))
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
	,[intExchangeRateTypeId]			= ARP.[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]					= ARP.[dblExchangeRate]
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
    ,[intEntityCardInfoId]              = ARP.[intEntityCardInfoId]
	,[ysnPosted]                        = ARP.[ysnPosted]
    ,[ysnInvoicePrepayment]             = ARP.[ysnInvoicePrepayment]
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARP.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]   = @AllowOtherUserToPost
    ,[ysnWithinAccountingDate]          = @ZeroBit --ISNULL(dbo.isOpenAccountingDate(ARP.[dtmDatePaid]), @ZeroBit)
    ,[ysnProcessCreditCard]             = ARP.[ysnProcessCreditCard]
    ,[ysnApplytoBudget]                 = ARP.[ysnApplytoBudget]

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ROUND(ARP.[dblAmountPaid] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ROUND(ARP.[dblUnappliedAmount] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
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
    ,[ysnExcludedFromPayment]           = @ZeroBit
    ,[ysnForgiven]                      = @ZeroBit
	,[intBillId]                        = NULL
    ,[strTransactionNumber]             = ''
    ,[strTransactionType]               = ''
    ,[strType]                          = ''
    ,[intTransactionAccountId]          = NULL
    ,[ysnTransactionPosted]             = @ZeroBit
	,[ysnTransactionPaid]               = @ZeroBit
    ,[ysnTransactionProcessed]          = @ZeroBit
    ,[dtmTransactionPostDate]           = NULL
	,[dblTransactionDiscount]           = @ZeroDecimal
    ,[dblBaseTransactionDiscount]       = @ZeroDecimal
    ,[dblTransactionInterest]           = @ZeroDecimal
    ,[dblBaseTransactionInterest]       = @ZeroDecimal
    ,[dblTransactionAmountDue]          = @ZeroDecimal
    ,[dblBaseTransactionAmountDue]      = @ZeroDecimal
    ,[intCurrencyExchangeRateTypeId]    = ARP.intCurrencyExchangeRateTypeId
    ,[dblCurrencyExchangeRate]          = @ZeroDecimal
    ,[strRateType]                      = ISNULL(SMCER.[strCurrencyExchangeRateType], '')
    
FROM
    tblARPayment ARP
INNER JOIN
    (
	    SELECT DISTINCT 
               intEntityId	= EM.intEntityId
			 , strEntityNo	= EM.strEntityNo
			 , strName		= EM.strName
		FROM tblEMEntity EM
		INNER JOIN tblEMEntityType EMT ON EM.intEntityId = EMT.intEntityId
		WHERE EMT.strType IN ('Customer', 'Vendor')
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
LEFT OUTER JOIN
    (SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType) SMCER
        ON ARP.[intCurrencyExchangeRateTypeId] = SMCER.[intCurrencyExchangeRateTypeId]
WHERE
	NOT EXISTS(SELECT NULL FROM #ARPostPaymentHeader PH WHERE PH.[intTransactionId] = ARP.[intPaymentId])
    AND (
            (
				RTRIM(LTRIM(ISNULL(@Param,''))) <> ''
				AND
				(
					(UPPER(@Param) = 'ALL' AND ARP.[ysnPosted] = 0)
					OR
					(UPPER(@Param) <> 'ALL' AND EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@Param2) DV WHERE DV.[intID] = ARP.[intPaymentId]))
				)
            )
			OR
            (
				@BeginDate IS NOT NULL
				AND CAST(ARP.[dtmDatePaid] AS DATE) BETWEEN CAST(@BeginDate AS DATE) AND CAST(@EndDate AS DATE)
            )
			OR
            (
				@BeginTransaction IS NOT NULL
				AND ARP.[intPaymentId] BETWEEN @BeginTransaction AND @EndTransaction
            )
        )
OPTION(recompile)

INSERT INTO #ARPostPaymentHeader
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
    ,[intExchangeRateTypeId]
    ,[dblExchangeRate]
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
    ,[ysnWithinAccountingDate]

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
    ,[strCustomerNumber]                = ARC.[strEntityNo]
    ,[strCustomerName]                  = ARC.[strName]
    ,[intCompanyLocationId]             = ARP.[intLocationId]
    ,[strLocationName]                  = SMCL.[strLocationName]
    ,[intUndepositedFundsId]            = CASE WHEN @BankAccountId IS NULL
                                                THEN (
		    									    CASE WHEN (CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARP.[strPaymentMethod],'')))) > 0 THEN RTRIM(LTRIM(ARP.[strPaymentMethod])) ELSE RTRIM(LTRIM(ISNULL(SMPM.[strPaymentMethod],''))) END) <> 'CF Invoice' 
                                                            THEN ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId])
                                                            ELSE ISNULL(ARP.intAccountId,ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId]))
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
	,[intExchangeRateTypeId]			= ARP.[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]					= ARP.[dblExchangeRate]
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
    ,[ysnWithinAccountingDate]          = @ZeroBit --ISNULL(dbo.isOpenAccountingDate(ARP.[dtmDatePaid]), @ZeroBit)

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ROUND(ARP.[dblAmountPaid] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ROUND(ARP.[dblUnappliedAmount] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
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
    ,[ysnExcludedFromPayment]           = @ZeroBit
    ,[ysnForgiven]                      = @ZeroBit
    ,[intBillId]                        = NULL
    ,[strTransactionNumber]             = ''
    ,[strTransactionType]               = ''
    ,[strType]                          = ''
    ,[intTransactionAccountId]          = NULL
    ,[ysnTransactionPosted]             = @ZeroBit
    ,[ysnTransactionPaid]               = @ZeroBit
    ,[ysnTransactionProcessed]          = @ZeroBit
    ,[dtmTransactionPostDate]           = NULL
    ,[dblTransactionDiscount]           = @ZeroDecimal
    ,[dblBaseTransactionDiscount]       = @ZeroDecimal
    ,[dblTransactionInterest]           = @ZeroDecimal
    ,[dblBaseTransactionInterest]       = @ZeroDecimal
    ,[dblTransactionAmountDue]          = @ZeroDecimal
    ,[dblBaseTransactionAmountDue]      = @ZeroDecimal
    ,[intCurrencyExchangeRateTypeId]    = ARP.intCurrencyExchangeRateTypeId
    ,[dblCurrencyExchangeRate]          = @ZeroDecimal
    ,[strRateType]                      = ISNULL(SMCER.[strCurrencyExchangeRateType], '')
    
FROM
    tblARPayment ARP
INNER JOIN
    (
    SELECT [intPaymentId] FROM tblARPaymentIntegrationLogDetail 
    WHERE [ysnPost] IS NOT NULL AND [ysnPost] = @Post AND ISNULL([ysnPosted],0) <> @Post AND [ysnHeader] = 1 AND [intIntegrationLogId] = @IntegrationLogId
    ) ARPILD
        ON ARP.[intPaymentId] = ARPILD.[intPaymentId]
INNER JOIN
    (
        SELECT DISTINCT
               intEntityId	= EM.intEntityId
			 , strEntityNo	= EM.strEntityNo
			 , strName		= EM.strName
		FROM tblEMEntity EM
		INNER JOIN tblEMEntityType EMT ON EM.intEntityId = EMT.intEntityId
		WHERE EMT.strType IN ('Customer', 'Vendor')
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
LEFT OUTER JOIN
    (SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType) SMCER
        ON ARP.[intCurrencyExchangeRateTypeId] = SMCER.[intCurrencyExchangeRateTypeId]
OPTION(recompile)

INSERT INTO #ARPostPaymentHeader
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
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
    ,[intEntityCardInfoId]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]
    ,[ysnApplytoBudget]

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
    ,[strCustomerNumber]                = ARC.[strEntityNo]
    ,[strCustomerName]                  = ARC.[strName]
    ,[intCompanyLocationId]             = ARP.[intLocationId]
    ,[strLocationName]                  = SMCL.[strLocationName]
    ,[intUndepositedFundsId]            = CASE WHEN @BankAccountId IS NULL
                                               THEN (
											        CASE WHEN (CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARP.[strPaymentMethod],'')))) > 0 THEN RTRIM(LTRIM(ARP.[strPaymentMethod])) ELSE RTRIM(LTRIM(ISNULL(SMPM.[strPaymentMethod],''))) END) <> 'CF Invoice' 
                                                         THEN ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId])
                                                         ELSE ISNULL(ARP.intAccountId,ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId]))
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
	,[intExchangeRateTypeId]			= ARP.[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]					= ARP.[dblExchangeRate]
    ,[dtmDatePaid]                      = ARP.[dtmDatePaid]
    ,[dtmPostDate]                      = @PostDate
    ,[intWriteOffAccountId]             = ISNULL(P.[intWriteOffAccountId], ISNULL(ARP.[intWriteOffAccountId], @WriteOffAccount))
    ,[intAccountId]                     = ISNULL(ISNULL(@NewAccountId, SMCL.[intUndepositedFundsId]), ARP.[intAccountId])
    ,[intBankAccountId]                 = ISNULL(P.[intBankAccountId], ARP.[intBankAccountId])
    ,[intARAccountId]                   = ISNULL(SMCL.[intARAccount], @ARAccount)
    ,[intDiscountAccount]               = ISNULL(P.[intDiscountAccountId], ISNULL(SMCL.[intSalesDiscounts], @DiscountAccount))
    ,[intInterestAccount]               = ISNULL(P.[intInterestAccountId], ISNULL(SMCL.[intInterestAccountId], @IncomeInterestAccount))
    ,[intCFAccountId]                   = ISNULL(P.[intCFAccountId], @CFAccount)
    ,[intGainLossAccount]               = ISNULL(P.[intGainLossAccountId], @GainLossAccount)
    ,[intEntityCardInfoId]              = ARP.[intEntityCardInfoId]
	,[ysnPosted]                        = ARP.[ysnPosted]
    ,[ysnInvoicePrepayment]             = ARP.[ysnInvoicePrepayment]
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARP.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]   = @AllowOtherUserToPost
    ,[ysnWithinAccountingDate]          = @ZeroBit --ISNULL(dbo.isOpenAccountingDate(ARP.[dtmDatePaid]), @ZeroBit)
    ,[ysnProcessCreditCard]             = ARP.[ysnProcessCreditCard]
    ,[ysnApplytoBudget]                 = ARP.[ysnApplytoBudget]

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ROUND(ARP.[dblAmountPaid] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ROUND(ARP.[dblUnappliedAmount] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
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
    ,[ysnExcludedFromPayment]           = @ZeroBit
    ,[ysnForgiven]                      = @ZeroBit
	,[intBillId]                        = NULL
    ,[strTransactionNumber]             = ''
    ,[strTransactionType]               = ''
    ,[strType]                          = ''
    ,[intTransactionAccountId]          = NULL
    ,[ysnTransactionPosted]             = @ZeroBit
	,[ysnTransactionPaid]               = @ZeroBit
    ,[ysnTransactionProcessed]          = @ZeroBit
    ,[dtmTransactionPostDate]           = NULL
	,[dblTransactionDiscount]           = @ZeroDecimal
    ,[dblBaseTransactionDiscount]       = @ZeroDecimal
    ,[dblTransactionInterest]           = @ZeroDecimal
    ,[dblBaseTransactionInterest]       = @ZeroDecimal
    ,[dblTransactionAmountDue]          = @ZeroDecimal
    ,[dblBaseTransactionAmountDue]      = @ZeroDecimal
    ,[intCurrencyExchangeRateTypeId]    = ARP.intCurrencyExchangeRateTypeId
    ,[dblCurrencyExchangeRate]          = @ZeroDecimal
    ,[strRateType]                      = ISNULL(SMCER.[strCurrencyExchangeRateType], '')
    
FROM
    (
    SELECT LD.[intHeaderId] AS [intPaymentId], [intBankAccountId], [intDiscountAccountId], [intInterestAccountId], [intWriteOffAccountId], [intGainLossAccountId], [intCFAccountId] FROM @PaymemntIds LD
    WHERE 
        NOT EXISTS(SELECT NULL FROM #ARPostPaymentHeader IH WHERE LD.[intHeaderId] = IH.[intTransactionId])
        AND LD.[ysnPost] IS NOT NULL 
		AND LD.[ysnPost] = @Post
    ) P
INNER JOIN
    tblARPayment ARP
        ON P.[intPaymentId] = ARP.[intPaymentId]
INNER JOIN
    (
	    SELECT DISTINCT 
               intEntityId	= EM.intEntityId
			 , strEntityNo	= EM.strEntityNo
			 , strName		= EM.strName
		FROM tblEMEntity EM
		INNER JOIN tblEMEntityType EMT ON EM.intEntityId = EMT.intEntityId
		WHERE EMT.strType IN ('Customer', 'Vendor')
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
LEFT OUTER JOIN
    (SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType) SMCER
        ON ARP.[intCurrencyExchangeRateTypeId] = SMCER.[intCurrencyExchangeRateTypeId]
OPTION(recompile)    

--Detail
INSERT INTO #ARPostPaymentDetail
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
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
    ,[intEntityCardInfoId]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]
    ,[ysnApplytoBudget]

    ,[dblAmountPaid]
    ,[dblBaseAmountPaid]
    ,[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]
    ,[dblPayment]
    ,[dblBasePayment]
    ,[dblAdjustedBasePayment]
    ,[dblDiscount]
    ,[dblBaseDiscount]
    ,[dblAdjustedBaseDiscount]
    ,[dblWriteOffAmount]
	,[dblBaseWriteOffAmount]
    ,[dblAdjustedBaseWriteOffAmount]
    ,[dblInterest]
    ,[dblBaseInterest]
    ,[dblAdjustedBaseInterest]
    ,[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]
    ,[dblAmountDue]
    ,[dblBaseAmountDue]

    ,[intInvoiceId]
    ,[ysnExcludedFromPayment]
    ,[ysnForgiven]
	,[intBillId]
    ,[intWriteOffAccountDetailId]
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
    ,[dblTransactionPayment]
    ,[dblBaseTransactionPayment]
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
    ,[strCustomerName]                  = ARP.[strCustomerName]
    ,[intCompanyLocationId]             = ARP.[intCompanyLocationId]
    ,[strLocationName]                  = ARP.[strLocationName]
    ,[intUndepositedFundsId]            = ARP.[intUndepositedFundsId]
    ,[intSalesAdvAcct]                  = ARP.[intSalesAdvAcct]
    ,[intCurrencyId]                    = ARP.[intCurrencyId]
    ,[intPaymentMethodId]               = ARP.[intPaymentMethodId]
    ,[strPaymentMethod]                 = ARP.[strPaymentMethod]
    ,[strNotes]                         = ARP.[strNotes]
	,[intExchangeRateTypeId]			= ARP.[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]					= ARP.[dblExchangeRate]
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
    ,[intEntityCardInfoId]              = ARP.[intEntityCardInfoId]
	,[ysnPosted]                        = ARP.[ysnPosted]
    ,[ysnInvoicePrepayment]             = ARP.[ysnInvoicePrepayment]
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARP.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]   = @AllowOtherUserToPost
    ,[ysnWithinAccountingDate]          = ARP.[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]             = ARP.[ysnProcessCreditCard]
    ,[ysnApplytoBudget]                 = ARP.[ysnApplytoBudget]

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ROUND(ARP.[dblAmountPaid] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ARP.[dblBaseUnappliedAmount]
    ,[dblPayment]                       = ARPD.[dblPayment]
    ,[dblBasePayment]                   = ROUND(ARPD.[dblPayment] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBasePayment]           = ROUND(ARPD.[dblPayment] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblDiscount]                      = ARPD.[dblDiscount]
    ,[dblBaseDiscount]                  = ROUND(ARPD.[dblDiscount] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBaseDiscount]          = ROUND(ARPD.[dblDiscount] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblWriteOffAmount]                = ARPD.[dblWriteOffAmount]
	,[dblBaseWriteOffAmount]            = ROUND(ARPD.[dblWriteOffAmount] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBaseWriteOffAmount]    = ROUND(ARPD.[dblWriteOffAmount] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblInterest]                      = ARPD.[dblInterest]
    ,[dblBaseInterest]                  = ROUND(ARPD.[dblInterest] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBaseInterest]          = ROUND(ARPD.[dblInterest] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblInvoiceTotal]                  = ARPD.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ROUND(ARPD.[dblInvoiceTotal] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAmountDue]                     = ARPD.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ROUND(ARPD.[dblAmountDue] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())

    ,[intInvoiceId]                     = ARI.[intInvoiceId]
    ,[ysnExcludedFromPayment]           = ARI.[ysnExcludeFromPayment]
    ,[ysnForgiven]                      = ARI.[ysnForgiven]
	,[intBillId]                        = NULL
    ,[intWriteOffAccountDetailId]       = ARPD.[intWriteOffAccountId]
    ,[strTransactionNumber]             = ARI.[strInvoiceNumber]
    ,[strTransactionType]               = ARI.[strTransactionType]
    ,[strType]                          = ARI.[strType]
    ,[intTransactionAccountId]          = ARPD.[intAccountId]
    ,[ysnTransactionPosted]             = ARI.[ysnPosted]
	,[ysnTransactionPaid]               = ARI.[ysnPaid]
    ,[ysnTransactionProcessed]          = ARI.[ysnProcessed]
    ,[dtmTransactionPostDate]           = ARI.[dtmPostDate]
	,[dblTransactionDiscount]           = ARI.[dblDiscount]
    ,[dblBaseTransactionDiscount]       = ROUND(ARI.[dblDiscount] * ARI.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblTransactionInterest]           = ARI.[dblInterest]
    ,[dblBaseTransactionInterest]       = ROUND(ARI.[dblInterest] * ARI.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblTransactionAmountDue]          = ARI.[dblAmountDue]
    ,[dblBaseTransactionAmountDue]      = CASE WHEN ARI.strTransactionType IN ('Credit Memo', 'Overpayment')
                                               THEN ROUND(ARI.[dblAmountDue] * ARI.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]()) * -1
                                               ELSE ROUND(ARI.[dblAmountDue] * ARI.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
                                          END
    ,[dblTransactionPayment]			= ARI.[dblPayment]
    ,[dblBaseTransactionPayment]		= ROUND(ARI.[dblPayment] * ARI.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
 	,[intCurrencyExchangeRateTypeId]    = ARPD.[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]          = ARPD.[dblCurrencyExchangeRate]
    ,[strRateType]                      = ISNULL(SMCER.[strCurrencyExchangeRateType], '')
FROM
    tblARPaymentDetail ARPD
INNER JOIN
    #ARPostPaymentHeader ARP
        ON ARPD.[intPaymentId] = ARP.[intTransactionId]
INNER JOIN
    (SELECT [intInvoiceId], [ysnExcludeFromPayment], [ysnForgiven], [strInvoiceNumber], [strTransactionType], [strType], [ysnPosted], [ysnPaid], [ysnProcessed], [dtmPostDate], [dblDiscount], [dblBaseDiscount], [dblInterest], [dblBaseInterest], [dblAmountDue], [dblBaseAmountDue], [dblPayment], [dblBasePayment], [dblCurrencyExchangeRate] FROM tblARInvoice) ARI
        ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
LEFT OUTER JOIN
    (SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType) SMCER
        ON ARPD.[intCurrencyExchangeRateTypeId] = SMCER.[intCurrencyExchangeRateTypeId]

INSERT INTO #ARPostPaymentDetail
    ([intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[strReceivePaymentType]
    ,[intEntityCustomerId]
    ,[strCustomerNumber]
    ,[strCustomerName]
    ,[intCompanyLocationId]
    ,[strLocationName]
    ,[intUndepositedFundsId]
    ,[intSalesAdvAcct]
    ,[intCurrencyId]
    ,[intPaymentMethodId]
    ,[strPaymentMethod]
    ,[strNotes]
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
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
    ,[intEntityCardInfoId]
	,[ysnPosted]
    ,[ysnInvoicePrepayment]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]
    ,[ysnApplytoBudget]

    ,[dblAmountPaid]
    ,[dblBaseAmountPaid]
    ,[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]
    ,[dblPayment]
    ,[dblBasePayment]
    ,[dblAdjustedBasePayment]
    ,[dblDiscount]
    ,[dblBaseDiscount]
    ,[dblAdjustedBaseDiscount]
    ,[dblWriteOffAmount]
	,[dblBaseWriteOffAmount]
    ,[dblAdjustedBaseWriteOffAmount]
    ,[dblInterest]
    ,[dblBaseInterest]
    ,[dblAdjustedBaseInterest]
    ,[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]
    ,[dblAmountDue]
    ,[dblBaseAmountDue]

    ,[intInvoiceId]
    ,[ysnExcludedFromPayment]
    ,[ysnForgiven]
	,[intBillId]
    ,[intWriteOffAccountDetailId]
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
    ,[dblTransactionPayment]
    ,[dblBaseTransactionPayment]
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
    ,[strCustomerName]                  = ARP.[strCustomerName]
    ,[intCompanyLocationId]             = ARP.[intCompanyLocationId]
    ,[strLocationName]                  = ARP.[strLocationName]
    ,[intUndepositedFundsId]            = ARP.[intUndepositedFundsId]
    ,[intSalesAdvAcct]                  = ARP.[intSalesAdvAcct]
    ,[intCurrencyId]                    = ARP.[intCurrencyId]
    ,[intPaymentMethodId]               = ARP.[intPaymentMethodId]
    ,[strPaymentMethod]                 = ARP.[strPaymentMethod]
    ,[strNotes]                         = ARP.[strNotes]
	,[intExchangeRateTypeId]			= ARP.[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]					= ARP.[dblExchangeRate]
    ,[dtmDatePaid]                      = ARP.[dtmDatePaid]
    ,[dtmPostDate]                      = ARP.[dtmPostDate]
    ,[intWriteOffAccountId]             = ARP.[intWriteOffAccountId]
    ,[intAccountId]                     = ARP.[intAccountId]
    ,[intBankAccountId]                 = ARP.[intBankAccountId]
    ,[intARAccountId]                   = APB.[intAccountId]
    ,[intDiscountAccount]               = CL.[intDiscountAccountId]
    ,[intInterestAccount]               = ARP.[intInterestAccount]
    ,[intCFAccountId]                   = ARP.[intCFAccountId]
    ,[intGainLossAccount]               = ARP.[intGainLossAccount]
    ,[intEntityCardInfoId]              = ARP.[intEntityCardInfoId]
	,[ysnPosted]                        = ARP.[ysnPosted]
    ,[ysnInvoicePrepayment]             = ARP.[ysnInvoicePrepayment]
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARP.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]   = @AllowOtherUserToPost
    ,[ysnWithinAccountingDate]          = ARP.[ysnWithinAccountingDate]
    ,[ysnProcessCreditCard]             = ARP.[ysnProcessCreditCard]
    ,[ysnApplytoBudget]                 = ARP.[ysnApplytoBudget]

    ,[dblAmountPaid]                    = ARP.[dblAmountPaid]
    ,[dblBaseAmountPaid]                = ROUND(ARP.[dblAmountPaid] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblUnappliedAmount]               = ARP.[dblUnappliedAmount]
    ,[dblBaseUnappliedAmount]           = ARP.[dblBaseUnappliedAmount]
    ,[dblPayment]                       = ARPD.[dblPayment]
    ,[dblBasePayment]                   = ROUND(ARPD.[dblPayment] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBasePayment]           = ROUND(ARPD.[dblPayment] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblDiscount]                      = ARPD.[dblDiscount]
    ,[dblBaseDiscount]                  = ROUND(ARPD.[dblDiscount] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBaseDiscount]          = ROUND(ARPD.[dblDiscount] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblWriteOffAmount]                = ARPD.[dblWriteOffAmount]
	,[dblBaseWriteOffAmount]            = ROUND(ARPD.[dblWriteOffAmount] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBaseWriteOffAmount]    = ROUND(ARPD.[dblWriteOffAmount] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblInterest]                      = ARPD.[dblInterest]
    ,[dblBaseInterest]                  = ROUND(ARPD.[dblInterest] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAdjustedBaseInterest]          = ROUND(ARPD.[dblInterest] * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblInvoiceTotal]                  = ARPD.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ROUND(ARPD.[dblInvoiceTotal] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
    ,[dblAmountDue]                     = ARPD.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ROUND(ARPD.[dblAmountDue] * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())

    ,[intInvoiceId]                     = NULL
    ,[ysnExcludedFromPayment]           = @ZeroBit
    ,[ysnForgiven]                      = @ZeroBit
	,[intBillId]                        = APB.[intBillId]
    ,[intWriteOffAccountDetailId]       = ARPD.[intWriteOffAccountId]
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
	,[ysnTransactionProcessed]          = @ZeroBit
    ,[dtmTransactionPostDate]           = APB.[dtmBillDate]
	,[dblTransactionDiscount]           = APB.[dblDiscount]
    ,[dblBaseTransactionDiscount]       = APB.[dblDiscount]
    ,[dblTransactionInterest]           = APB.[dblInterest]
    ,[dblBaseTransactionInterest]       = APB.[dblInterest]
    ,[dblTransactionAmountDue]          = APB.[dblAmountDue]
    ,[dblBaseTransactionAmountDue]      = APB.[dblAmountDue]
    ,[dblTransactionPayment]			= @ZeroDecimal
    ,[dblBaseTransactionPayment]		= @ZeroDecimal
 	,[intCurrencyExchangeRateTypeId]    = ARPD.[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]          = ARPD.[dblCurrencyExchangeRate]
    ,[strRateType]                      = ISNULL(SMCER.[strCurrencyExchangeRateType], '') 
FROM tblARPaymentDetail ARPD
INNER JOIN #ARPostPaymentHeader ARP ON ARPD.[intPaymentId] = ARP.[intTransactionId]
INNER JOIN (SELECT [intBillId], [intStoreLocationId], [strBillId], [ysnPosted], [ysnPaid], [dtmBillDate], [dblDiscount], [dblInterest], [dblAmountDue], [intAccountId], [intTransactionType] FROM tblAPBill) APB ON ARPD.[intBillId] = APB.[intBillId]
INNER JOIN tblSMCompanyLocation CL ON APB.intStoreLocationId = CL.intCompanyLocationId
LEFT OUTER JOIN (SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType) SMCER ON ARPD.[intCurrencyExchangeRateTypeId] = SMCER.[intCurrencyExchangeRateTypeId]
OPTION(recompile)

INSERT INTO #ARPostZeroPayment([intTransactionId])
SELECT
     [intTransactionId]
FROM
	#ARPostPaymentDetail
WHERE
	[dblAmountPaid] = @ZeroDecimal
GROUP BY
	[intTransactionId]
HAVING
	SUM([dblPayment]) = @ZeroDecimal
	AND SUM([dblDiscount]) = @ZeroDecimal

RETURN 1
