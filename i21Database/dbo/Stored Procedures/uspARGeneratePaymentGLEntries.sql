CREATE PROCEDURE [dbo].[uspARGeneratePaymentGLEntries]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
    ,@UserId            INT             = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal    DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Receive Payments'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

IF @Post = 1
BEGIN
    DECLARE @OverrideCompanySegment         BIT
           ,@OverrideLocationSegment        BIT
           ,@OverrideLineOfBusinessSegment  BIT

    SELECT TOP 1 
         @OverrideCompanySegment        = ysnOverrideCompanySegment
        ,@OverrideLocationSegment       = ysnOverrideLocationSegment
        ,@OverrideLineOfBusinessSegment = ysnOverrideLineOfBusinessSegment
    FROM tblARCompanyPreference

    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	--DEBIT PAYMENT HEADER
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = ACCOUNT.intAccountId
		,[dblDebit]                     = CASE WHEN P.[dblBaseAmountPaid] < 0 THEN @ZeroDecimal ELSE ABS(P.[dblBaseAmountPaid]) END
		,[dblCredit]                    = CASE WHEN P.[dblBaseAmountPaid] < 0 THEN ABS(P.[dblBaseAmountPaid]) ELSE @ZeroDecimal END
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Payment from ' + P.strCustomerName
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = CASE WHEN P.[dblAmountPaid] < 0 THEN @ZeroDecimal ELSE ABS(P.[dblAmountPaid]) END
		,[dblDebitReport]               = CASE WHEN P.[dblBaseAmountPaid] < 0 THEN @ZeroDecimal ELSE ABS(P.[dblBaseAmountPaid]) END
		,[dblCreditForeign]             = CASE WHEN P.[dblAmountPaid] < 0 THEN ABS(P.[dblAmountPaid]) ELSE @ZeroDecimal END
		,[dblCreditReport]              = CASE WHEN P.[dblBaseAmountPaid] < 0 THEN ABS(P.[dblBaseAmountPaid]) ELSE @ZeroDecimal END
		,[dblReportingRate]             = P.[dblExchangeRate]
		,[dblForeignRate]               = P.[dblExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentHeader P
    OUTER APPLY (
	    SELECT TOP 1 intAccountId = intOverrideAccount
        FROM dbo.[fnARGetOverrideAccount](
                 P.[intARAccountId]
                ,CASE WHEN UPPER(RTRIM(LTRIM(P.[strPaymentMethod]))) = UPPER('Write Off') THEN P.[intWriteOffAccountId]
				    WHEN UPPER(RTRIM(LTRIM(P.[strPaymentMethod]))) = UPPER('CF Invoice') THEN ISNULL(P.[intWriteOffAccountId], P.[intCFAccountId])
			        ELSE P.[intAccountId]
				 END
                ,@OverrideCompanySegment
				,@OverrideLocationSegment
				,0
			 )
    ) ACCOUNT
	WHERE
		P.[ysnPost] = 1

    --CREDIT OVERPAYMENT
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intARAccountId]
		,[dblDebit]                     = @ZeroDecimal
		,[dblCredit]                    = P.[dblBaseUnappliedAmount]
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Overpayment for ' + P.strTransactionId
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = @ZeroDecimal
		,[dblDebitReport]               = @ZeroDecimal
		,[dblCreditForeign]             = P.[dblUnappliedAmount]
		,[dblCreditReport]              = P.[dblBaseUnappliedAmount]
		,[dblReportingRate]             = P.[dblExchangeRate]
		,[dblForeignRate]               = P.[dblExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentHeader P
	INNER JOIN #ARPostOverPayment OP
		ON P.[intTransactionId] = OP.[intTransactionId]
	WHERE
			P.[ysnPost] = 1
		AND (P.[dblBaseUnappliedAmount] <> @ZeroDecimal OR P.[dblUnappliedAmount] <> @ZeroDecimal)

    --CREDIT PREPAYMENT
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intSalesAdvAcct]
		,[dblDebit]                     = @ZeroDecimal
		,[dblCredit]                    = P.[dblBaseAmountPaid]
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Prepayment for ' + P.strTransactionId
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = @ZeroDecimal
		,[dblDebitReport]               = @ZeroDecimal
		,[dblCreditForeign]             = P.[dblAmountPaid]
		,[dblCreditReport]              = P.[dblBaseAmountPaid]
		,[dblReportingRate]             = P.[dblExchangeRate]
		,[dblForeignRate]               = P.[dblExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentHeader P
	INNER JOIN #ARPostPrePayment OP
		ON P.[intTransactionId] = OP.[intTransactionId]
	WHERE
			P.[ysnPost] = 1
		AND (P.[dblAmountPaid] <> @ZeroDecimal OR P.[dblBaseAmountPaid] <> @ZeroDecimal)

    --DEBIT DISCOUNT
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intDiscountAccount]
		,[dblDebit]                     = P.[dblAdjustedBaseDiscount]
		,[dblCredit]                    = @ZeroDecimal
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Discount for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.dblExchangeRate, 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = P.[dblDiscount]
		,[dblDebitReport]               = P.[dblBaseDiscount]
		,[dblCreditForeign]             = @ZeroDecimal
		,[dblCreditReport]              = @ZeroDecimal
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.dblExchangeRate
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND ((P.[dblDiscount] <> @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
			OR
			(P.[dblBaseDiscount] <> @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

    --DEBIT WRITE OFF
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = WRITEOFFDETAIL.[intAccountId]
		,[dblDebit]                     = CASE WHEN P.[dblBaseWriteOffAmount] > 0 THEN P.[dblBaseWriteOffAmount] ELSE 0 END
		,[dblCredit]                    = CASE WHEN P.[dblBaseWriteOffAmount] < 0 THEN ABS(P.[dblBaseWriteOffAmount]) ELSE 0 END
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Write Off for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.dblExchangeRate, 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = CASE WHEN P.[dblBaseWriteOffAmount] > 0 THEN P.[dblWriteOffAmount] ELSE 0 END
		,[dblDebitReport]               = CASE WHEN P.[dblBaseWriteOffAmount] > 0 THEN P.[dblBaseWriteOffAmount] ELSE 0 END
		,[dblCreditForeign]             = CASE WHEN P.[dblBaseWriteOffAmount] < 0 THEN ABS(P.[dblWriteOffAmount]) ELSE 0 END
		,[dblCreditReport]              = CASE WHEN P.[dblBaseWriteOffAmount] < 0 THEN ABS(P.[dblBaseWriteOffAmount]) ELSE 0 END
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.dblExchangeRate
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
    OUTER APPLY (
	    SELECT TOP 1 intAccountId = intOverrideAccount
        FROM dbo.[fnARGetOverrideAccount](P.[intTransactionAccountId], P.[intWriteOffAccountDetailId], @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
    ) WRITEOFFDETAIL
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND (P.[dblWriteOffAmount] <> @ZeroDecimal OR P.[dblBaseWriteOffAmount] <> @ZeroDecimal)

    --DEBIT INTEREST
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intARAccountId]
		,[dblDebit]                     = P.[dblAdjustedBaseInterest]
		,[dblCredit]                    = @ZeroDecimal
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Interest for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.dblExchangeRate, 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = P.[dblInterest]
		,[dblDebitReport]               = P.[dblBaseInterest]
		,[dblCreditForeign]             = @ZeroDecimal
		,[dblCreditReport]              = @ZeroDecimal
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.dblExchangeRate
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND P.[dblInterest] <> @ZeroDecimal

    --CREDIT PAYMENT DETAILS
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intTransactionAccountId]
		,[dblDebit]                     = CASE WHEN P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal) < 0 THEN ABS(P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal)) ELSE @ZeroDecimal END
		,[dblCredit]                    = CASE WHEN P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal) < 0 THEN @ZeroDecimal ELSE ABS(P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal)) END
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Payment for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = CASE WHEN P.[dblPayment] < 0 THEN ABS(P.[dblPayment]) ELSE @ZeroDecimal END
		,[dblDebitReport]               = CASE WHEN P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal) < 0 THEN @ZeroDecimal ELSE ABS(P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal)) END
		,[dblCreditForeign]             = CASE WHEN P.[dblPayment] < 0 THEN @ZeroDecimal ELSE ABS(P.[dblPayment]) END
		,[dblCreditReport]              = CASE WHEN P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal) < 0 THEN ABS(P.[dblBasePayment] - ISNULL(GL.[dblGainLossAmount], @ZeroDecimal)) ELSE @ZeroDecimal END
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
	LEFT OUTER JOIN
		(
			SELECT
				 [dblGainLossAmount]        = SUM(CASE WHEN P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount] < P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount] THEN @ZeroDecimal ELSE ABS((P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount]) - (P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount])) END)
				,[intTransactionDetailId]   = P.[intTransactionDetailId]
			FROM
				#ARPostPaymentDetail P
			WHERE
					P.[ysnPost] = 1
				AND P.[strTransactionType] <> 'Claim'
				AND ((ISNULL(((((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]))) - P.[dblBasePayment]),0)))  <> @ZeroDecimal
        				AND ((P.[dblTransactionAmountDue] + P.[dblInterest]) - P.[dblDiscount] - P.[dblWriteOffAmount]) = ((P.[dblPayment] - P.[dblInterest]) + P.[dblDiscount] + P.[dblWriteOffAmount])
			GROUP BY
				P.[intTransactionDetailId]
		) GL
			ON P.[intTransactionDetailId] = GL.[intTransactionDetailId]
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND (P.[dblPayment] <> @ZeroDecimal OR P.[dblBasePayment] <> @ZeroDecimal)

    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = GAINLOSS.[intAccountId]
		,[dblDebit]                     = CASE WHEN P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount] < P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount] THEN ABS((P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount]) - (P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount])) ELSE @ZeroDecimal END
		,[dblCredit]                    = CASE WHEN P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount] < P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount] THEN @ZeroDecimal ELSE ABS((P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount]) - (P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount])) END
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Payment for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = FUNCTIONCURRENCY.[intCurrencyId]
		,[dblExchangeRate]              = 1
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = CASE WHEN P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount] < P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount] THEN ABS((P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount]) - (P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount])) ELSE @ZeroDecimal END
		,[dblDebitReport]               = CASE WHEN P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount] < P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount] THEN ABS((P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount]) - (P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount])) ELSE @ZeroDecimal END
		,[dblCreditForeign]             = CASE WHEN P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount] < P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount] THEN @ZeroDecimal ELSE ABS((P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount]) - (P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount])) END
		,[dblCreditReport]              = CASE WHEN P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount] < P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount] THEN @ZeroDecimal ELSE ABS((P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] + P.[dblAdjustedBaseInterest] - P.[dblAdjustedBaseDiscount]) - (P.[dblBasePayment] + P.[dblBaseWriteOffAmount] + P.[dblBaseInterest] - P.[dblBaseDiscount])) END
		,[dblReportingRate]             = 1
		,[dblForeignRate]               = 1
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
    OUTER APPLY (
	    SELECT TOP 1 intAccountId = intOverrideAccount
	    FROM dbo.[fnARGetOverrideAccount](P.[intTransactionAccountId], P.[intGainLossAccount], @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
    ) GAINLOSS
	OUTER APPLY (
		SELECT TOP 1 [intCurrencyId] = intDefaultCurrencyId FROM tblSMCompanyPreference
	) FUNCTIONCURRENCY
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND (P.[dblPayment] <> @ZeroDecimal OR P.[dblBasePayment] <> @ZeroDecimal)
		AND P.[dblAdjustedBasePayment] + P.[dblAdjustedBaseWriteOffAmount] <> P.[dblBasePayment] + P.[dblBaseWriteOffAmount]

    --CREDIT DISCOUNT
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intARAccountId]
		,[dblDebit]                     = @ZeroDecimal
		,[dblCredit]                    = P.[dblBaseDiscount]
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Discount for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = @ZeroDecimal
		,[dblDebitReport]               = @ZeroDecimal
		,[dblCreditForeign]             = P.[dblDiscount]
		,[dblCreditReport]              = P.[dblBaseDiscount]
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND ((P.[dblDiscount] <> @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
			OR
			(P.[dblBaseDiscount] <> @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

    --CREDIT WRITE OFF
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = WRITEOFF.[intAccountId]
		,[dblDebit]                     = CASE WHEN P.[dblBaseWriteOffAmount] < 0 THEN ABS(P.[dblBaseWriteOffAmount]) ELSE 0 END
		,[dblCredit]                    = CASE WHEN P.[dblBaseWriteOffAmount] > 0 THEN P.[dblBaseWriteOffAmount] ELSE 0 END
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Write Off for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = CASE WHEN P.[dblWriteOffAmount] < 0 THEN ABS(P.[dblBaseWriteOffAmount]) ELSE 0 END
		,[dblDebitReport]               = CASE WHEN P.[dblBaseWriteOffAmount] < 0 THEN ABS(P.[dblBaseWriteOffAmount]) ELSE 0 END
		,[dblCreditForeign]             = CASE WHEN P.[dblWriteOffAmount] > 0 THEN P.[dblWriteOffAmount] ELSE 0 END
		,[dblCreditReport]              = CASE WHEN P.[dblBaseWriteOffAmount] > 0 THEN P.[dblBaseWriteOffAmount] ELSE 0 END
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
    OUTER APPLY (
	    SELECT TOP 1 intAccountId = intOverrideAccount
        FROM dbo.[fnARGetOverrideAccount](P.[intTransactionAccountId], P.[intTransactionAccountId], @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
    ) WRITEOFF
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND (P.[dblWriteOffAmount] <> @ZeroDecimal OR P.[dblBaseWriteOffAmount] <> @ZeroDecimal)

    --CREDIT INTEREST
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intInterestAccount]
		,[dblDebit]                     = @ZeroDecimal
		,[dblCredit]                    = P.[dblBaseInterest]
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Interest for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = @ZeroDecimal
		,[dblDebitReport]               = @ZeroDecimal
		,[dblCreditForeign]             = P.[dblInterest]
		,[dblCreditReport]              = P.[dblBaseInterest]
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM
		#ARPostPaymentDetail P
	WHERE
			P.[ysnPost] = 1
		AND P.[strTransactionType] <> 'Claim'
		AND P.[dblInterest] <> @ZeroDecimal

    --CREDIT CONVENIENCE FEE
    INSERT #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
	SELECT
		 [dtmDate]                      = P.[dtmDatePaid]
		,[strBatchId]                   = P.[strBatchId]
		,[intAccountId]                 = P.[intCreditCardFeeAccountId]
		,[dblDebit]                     = @ZeroDecimal
		,[dblCredit]                    = P.[dblBaseCreditCardFee]
		,[dblDebitUnit]                 = @ZeroDecimal
		,[dblCreditUnit]                = @ZeroDecimal
		,[strDescription]               = 'Convenience Fee for ' + P.strTransactionNumber
		,[strCode]                      = @CODE
		,[strReference]                 = P.[strCustomerNumber]
		,[intCurrencyId]                = P.[intCurrencyId]
		,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
		,[dtmDateEntered]               = P.[dtmPostDate]
		,[dtmTransactionDate]           = P.[dtmDatePaid]
		,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
		,[intJournalLineNo]             = P.[intTransactionDetailId]
		,[ysnIsUnposted]                = 0
		,[intUserId]                    = P.[intUserId]
		,[intEntityId]                  = P.[intEntityId]
		,[strTransactionId]             = P.[strTransactionId]
		,[intTransactionId]             = P.[intTransactionId]
		,[strTransactionType]           = @SCREEN_NAME
		,[strTransactionForm]           = @SCREEN_NAME
		,[strModuleName]                = @MODULE_NAME
		,[intConcurrencyId]             = 1
		,[dblDebitForeign]              = @ZeroDecimal
		,[dblDebitReport]               = @ZeroDecimal
		,[dblCreditForeign]             = P.[dblCreditCardFee]
		,[dblCreditReport]              = P.[dblBaseCreditCardFee]
		,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
		,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
		,[strRateType]                  = P.[strRateType]
		,[strDocument]                  = NULL
		,[strComments]                  = NULL
		,[strSourceDocumentId]          = NULL
		,[intSourceLocationId]          = NULL
		,[intSourceUOMId]               = NULL
		,[dblSourceUnitDebit]           = NULL
		,[dblSourceUnitCredit]          = NULL
		,[intCommodityId]               = NULL
		,[intSourceEntityId]            = P.[intEntityCustomerId]
		,[ysnRebuild]                   = NULL
	FROM #ARPostPaymentDetail P
	WHERE P.[ysnPost] = 1
      AND P.[strTransactionType] <> 'Claim'
      AND (P.[dblCreditCardFee] <> @ZeroDecimal OR P.[dblBaseCreditCardFee] <> @ZeroDecimal)

    DECLARE @TempPaymentIds AS [dbo].[Id]
    DELETE FROM @TempPaymentIds
    INSERT INTO @TempPaymentIds
    SELECT DISTINCT [intTransactionId] FROM #ARPostPaymentDetail WHERE [ysnPost] = 1 AND [strTransactionType] = 'Claim'

    --CLAIMS
    INSERT INTO #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
        ,[ysnRebuild])
    SELECT
         [dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strRateType]
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
    FROM
        [dbo].[fnAPCreateClaimARGLEntries](@TempPaymentIds, @UserId, @BatchId)

    --GAINLOSS FROM ROUNDING DECIMALS
	IF NOT EXISTS(SELECT NULL FROM #ARPaymentGLEntries WHERE intAccountId IN (
		SELECT TOP 1 GAINLOSS.intAccountId FROM #ARPostPaymentDetail P
		OUTER APPLY (SELECT TOP 1 intAccountId = intOverrideAccount FROM dbo.[fnARGetOverrideAccount](P.[intTransactionAccountId], P.[intGainLossAccount], @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)) GAINLOSS)
	)
	BEGIN
		INSERT #ARPaymentGLEntries
			([dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[strDocument]
			,[strComments]
			,[strSourceDocumentId]
			,[intSourceLocationId]
			,[intSourceUOMId]
			,[dblSourceUnitDebit]
			,[dblSourceUnitCredit]
			,[intCommodityId]
			,[intSourceEntityId]
			,[ysnRebuild])
		SELECT TOP 1
			 [dtmDate]                      = P.[dtmDatePaid]
			,[strBatchId]                   = P.[strBatchId]
			,[intAccountId]                 = GAINLOSS.[intAccountId]
			,[dblDebit]                     = CASE WHEN ConversionRoundingGainLoss.dblConversionDifference < 0 THEN ABS(ConversionRoundingGainLoss.dblConversionDifference) ELSE @ZeroDecimal END
			,[dblCredit]                    = CASE WHEN ConversionRoundingGainLoss.dblConversionDifference < 0 THEN @ZeroDecimal ELSE ABS(ConversionRoundingGainLoss.dblConversionDifference) END
			,[dblDebitUnit]                 = @ZeroDecimal
			,[dblCreditUnit]                = @ZeroDecimal
			,[strDescription]               = 'Payment for ' + P.strTransactionNumber
			,[strCode]                      = @CODE
			,[strReference]                 = P.[strCustomerNumber]
			,[intCurrencyId]                = FUNCTIONCURRENCY.[intCurrencyId]
			,[dblExchangeRate]              = 1
			,[dtmDateEntered]               = P.[dtmPostDate]
			,[dtmTransactionDate]           = P.[dtmDatePaid]
			,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
			,[intJournalLineNo]             = P.[intTransactionDetailId]
			,[ysnIsUnposted]                = 0
			,[intUserId]                    = P.[intUserId]
			,[intEntityId]                  = P.[intEntityId]
			,[strTransactionId]             = P.[strTransactionId]
			,[intTransactionId]             = P.[intTransactionId]
			,[strTransactionType]           = @SCREEN_NAME
			,[strTransactionForm]           = @SCREEN_NAME
			,[strModuleName]                = @MODULE_NAME
			,[intConcurrencyId]             = 1
			,[dblDebitForeign]              = CASE WHEN ConversionRoundingGainLoss.dblConversionDifference < 0 THEN ABS(ConversionRoundingGainLoss.dblConversionDifference) ELSE @ZeroDecimal END
			,[dblDebitReport]               = CASE WHEN ConversionRoundingGainLoss.dblConversionDifference < 0 THEN ABS(ConversionRoundingGainLoss.dblConversionDifference) ELSE @ZeroDecimal END
			,[dblCreditForeign]             = CASE WHEN ConversionRoundingGainLoss.dblConversionDifference < 0 THEN @ZeroDecimal ELSE ABS(ConversionRoundingGainLoss.dblConversionDifference) END
			,[dblCreditReport]              = CASE WHEN ConversionRoundingGainLoss.dblConversionDifference < 0 THEN @ZeroDecimal ELSE ABS(ConversionRoundingGainLoss.dblConversionDifference) END
			,[dblReportingRate]             = 1
			,[dblForeignRate]               = 1
			,[strRateType]                  = P.[strRateType]
			,[strDocument]                  = NULL
			,[strComments]                  = NULL
			,[strSourceDocumentId]          = NULL
			,[intSourceLocationId]          = NULL
			,[intSourceUOMId]               = NULL
			,[dblSourceUnitDebit]           = NULL
			,[dblSourceUnitCredit]          = NULL
			,[intCommodityId]               = NULL
			,[intSourceEntityId]            = P.[intEntityCustomerId]
			,[ysnRebuild]                   = NULL
		FROM
			#ARPostPaymentDetail P
		OUTER APPLY (
			SELECT TOP 1 intAccountId = intOverrideAccount
			FROM dbo.[fnARGetOverrideAccount](P.[intTransactionAccountId], P.[intGainLossAccount], @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
		) GAINLOSS
		OUTER APPLY (
			SELECT TOP 1 [intCurrencyId] = intDefaultCurrencyId FROM tblSMCompanyPreference
		) FUNCTIONCURRENCY
		OUTER APPLY (
			SELECT [dblConversionDifference] = (SUM([dblDebit]) - SUM([dblCredit])) FROM #ARPaymentGLEntries
		) ConversionRoundingGainLoss
		WHERE
				P.[ysnPost] = 1
			AND P.[strTransactionType] <> 'Claim'
			AND (P.[dblPayment] <> @ZeroDecimal OR P.[dblBasePayment] <> @ZeroDecimal)
			AND ConversionRoundingGainLoss.dblConversionDifference BETWEEN -1 AND 1 
			AND ConversionRoundingGainLoss.dblConversionDifference <> 0
	END
END
					
IF @Post = 0
BEGIN
    INSERT INTO #ARPaymentGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId])
    SELECT 
         [dtmDate]						= GLD.[dtmDate]
        ,[strBatchId]					= @BatchId
        ,[intAccountId]					= GLD.[intAccountId]
        ,[dblDebit]						= GLD.[dblCredit]
        ,[dblCredit]					= GLD.[dblDebit]
        ,[dblDebitUnit]					= GLD.[dblCreditUnit]
        ,[dblCreditUnit]				= GLD.[dblDebitUnit]
        ,[strDescription]				= GLD.[strDescription]
        ,[strCode]						= GLD.[strCode]
        ,[strReference]					= GLD.[strReference]
        ,[intCurrencyId]				= GLD.[intCurrencyId]
        ,[dblExchangeRate]				= GLD.[dblExchangeRate]
        ,[dtmDateEntered]				= @PostDate
        ,[dtmTransactionDate]			= GLD.[dtmTransactionDate]
        ,[strJournalLineDescription]	= REPLACE(GLD.[strJournalLineDescription], 'Posted ', 'Unposted ')
        ,[intJournalLineNo]				= GLD.[intJournalLineNo]
        ,[ysnIsUnposted]				= 1
        ,[intUserId]					= GLD.[intUserId]
        ,[intEntityId]					= GLD.[intUserId]
        ,[strTransactionId]				= GLD.[strTransactionId]
        ,[intTransactionId]				= GLD.[intTransactionId]
        ,[strTransactionType]			= GLD.[strTransactionType]
        ,[strTransactionForm]			= GLD.[strTransactionForm]
        ,[strModuleName]				= GLD.[strModuleName]
        ,[intConcurrencyId]				= 1
        ,[dblDebitForeign]				= GLD.[dblCreditForeign]
        ,[dblDebitReport]				= GLD.[dblCreditReport]
        ,[dblCreditForeign]				= GLD.[dblDebitForeign]
        ,[dblCreditReport]				= GLD.[dblDebitReport]
        ,[dblReportingRate]				= GLD.[dblReportingRate]
        ,[dblForeignRate]				= GLD.[dblForeignRate]
        ,[strDocument]					= GLD.[strDocument]
        ,[strComments]					= GLD.[strComments]
        ,[strSourceDocumentId]			= GLD.[strSourceDocumentId]
        ,[intSourceLocationId]			= GLD.[intSourceLocationId]
        ,[intSourceUOMId]				= GLD.[intSourceUOMId]
        ,[dblSourceUnitDebit]			= GLD.[dblSourceUnitCredit]
        ,[dblSourceUnitCredit]			= GLD.[dblSourceUnitDebit]
        ,[intCommodityId]				= GLD.[intCommodityId]
        ,[intSourceEntityId]			= GLD.[intSourceEntityId]
    FROM
		#ARPostPaymentHeader PID
    INNER JOIN
        tblGLDetail GLD
            ON PID.[intTransactionId] = GLD.[intTransactionId]
            AND PID.[strTransactionId] = GLD.[strTransactionId]
    WHERE
         GLD.[ysnIsUnposted] = 0
    ORDER BY
        GLD.[intGLDetailId]
END

UPDATE #ARPaymentGLEntries
SET
     [dtmDateEntered] = @PostDate
	,[strBatchId]     = @BatchId