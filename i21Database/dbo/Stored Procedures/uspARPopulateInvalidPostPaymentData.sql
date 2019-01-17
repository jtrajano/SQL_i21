CREATE PROCEDURE [dbo].[uspARPopulateInvalidPostPaymentData]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @TransType NVARCHAR(50) 
SET @TransType = 'Receivable'


IF @Post = 1
BEGIN
    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Undeposited Funds Account	
    SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Undeposited Funds account in Company Location - ' + P.[strLocationName]  + ' was not set.'
    FROM
        #ARPostPaymentHeader P
    WHERE
        P.[ysnPost] = 1
        AND ISNULL(P.[intUndepositedFundsId], 0) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--AR Account
    SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The AR Account in Company Configuration was not set.'
    FROM
        #ARPostPaymentHeader P
    WHERE
        P.[ysnPost] = 1
        AND ISNULL(P.[intARAccountId], 0) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Payment without payment on detail (get all detail that has 0 payment)
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL--P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There was no payment to receive.'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[dblAmountPaid] = @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
		,P.[strTransactionId]
        --,P.[intTransactionDetailId]
        ,P.[strBatchId]
    HAVING
            SUM(P.dblPayment) = @ZeroDecimal
		AND MAX(P.dblPayment) = @ZeroDecimal
		AND MIN(P.dblPayment) = @ZeroDecimal

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Payment without detail
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There was no payment to receive.'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[dblAmountPaid] = @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
		,P.[strTransactionId]
        ,P.[intTransactionDetailId]
        ,P.[strBatchId]
    HAVING
        COUNT(P.[intTransactionDetailId]) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Unposted Invoice(s)
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Transaction - ' + P.[strTransactionNumber] + ' is not posted!'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[ysnTransactionPosted] = 0
        AND ISNULL(P.[dblPayment], 0) <> @ZeroDecimal
        AND P.[strTransactionType] <> 'Claim'

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Invoice Prepayment
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = P.[strTransactionId] + '''s payment amount must be equal to ' + P.[strTransactionNumber] + '''s prepay amount!'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[ysnInvoicePrepayment] = 1
        AND (P.[dblInvoiceTotal] <> P.[dblPayment] OR P.[dblInvoiceTotal] <> P.[dblAmountPaid])

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Forgiven Invoice(s)
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Invoice ' + P.[strTransactionNumber] + ' has been forgiven!'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[strType] = 'Service Charge'
        AND P.[ysnForgiven] = 1
        AND P.[dblPayment] <> @ZeroDecimal

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Negative Payment is not allowed.
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Return Payment is not allowed for non-ACH Payment Method.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND P.[strPaymentMethod] NOT IN ('ACH', 'CF Invoice', 'Cash', 'Debit Card', 'Credit Card', 'Manual Credit Card')
        AND P.[ysnInvoicePrepayment] = 0
        AND P.[dblAmountPaid] < @ZeroDecimal

 --   This is being handled by [uspGLValidateGLEntries]
 --   INSERT INTO #ARInvalidPaymentData
 --       ([intTransactionId]
 --       ,[strTransactionId]
 --       ,[strTransactionType]
 --       ,[intTransactionDetailId]
 --       ,[strBatchId]
 --       ,[strError])
	----Fiscal Year
	--SELECT
 --        [intTransactionId]         = P.[intTransactionId]
 --       ,[strTransactionId]         = P.[strTransactionId]
 --       ,[strTransactionType]       = @TransType
 --       ,[intTransactionDetailId]   = P.[intTransactionDetailId]
 --       ,[strBatchId]               = P.[strBatchId]
 --       ,[strError]                 = P.[strTransactionId] + '- Unable to find an open fiscal year period to match the transaction date.'
	--FROM
	--	#ARPostPaymentHeader P
 --   WHERE
 --           P.[ysnPost] = 1
 --       AND P.[ysnWithinAccountingDate] = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Company Location
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Company location of ' + P.[strTransactionId] + ' was not set.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND P.[intCompanyLocationId] IS NULL

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Sales Discount Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Discounts account in Company Configuration was not set.'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblDiscount] <> @ZeroDecimal
        AND ISNULL(P.[intDiscountAccount], 0) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Income Interest Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Income Interest account in Company Location or Company Configuration was not set.'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblInterest] <> @ZeroDecimal
        AND ISNULL(P.[intInterestAccount], 0) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Write Off Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Write Off account in Company Configuration was not set.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND UPPER(P.[strPaymentMethod]) = UPPER('Write Off')
        AND ISNULL(P.[intWriteOffAccountId], 0) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--CF Invoice Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The CF Invoice Account # in Company Configuration was not set.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND UPPER(P.[strPaymentMethod]) = UPPER('CF Invoice')
        AND ISNULL(P.[intCFAccountId], 0) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Payment Date
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment Date(' + CONVERT(NVARCHAR(30),P.[dtmDatePaid], 101) + ') cannot be earlier than the Invoice(' + P.[strTransactionNumber] + ') Post Date(' + CONVERT(NVARCHAR(30),P.[dtmTransactionPostDate], 101) + ')!'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND CAST(P.[dtmTransactionPostDate] AS DATE) > CAST(P.[dtmDatePaid] AS DATE)
        AND P.[dblPayment] <> @ZeroDecimal

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Realized Gain or Loss account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = CASE WHEN ISNULL(P.intCurrencyExchangeRateTypeId, 0) = 0 THEN 'The totals of the base amounts are not equal.' ELSE 'The Accounts Receivable Realized Gain or Loss account in Company Configuration was not set.' END
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND ISNULL(P.[intGainLossAccount],0) = 0
		AND P.[strTransactionType] <> 'Claim'
		AND ((ISNULL(((((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]))) - P.[dblBasePayment]),0)))  <> @ZeroDecimal
		AND ((P.[dblTransactionAmountDue] + P.[dblInterest]) - P.[dblDiscount]) = ((P.[dblPayment] - P.[dblInterest]) + P.[dblDiscount])

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Validate Bank Account for ACH Payment Method
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Bank Account is required for payment with ACH payment method!'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND ISNULL(P.[intBankAccountId], 0) = 0
        AND P.[strPaymentMethod] = 'ACH'

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Prepaid Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Customer Prepaid account in Company Location - ' + MAX(ISNULL(P.[strLocationName],''))  + ' was not set.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[strBatchId]
    HAVING
            MAX(ISNULL(P.[intSalesAdvAcct],0)) = 0
        AND AVG(P.[dblAmountPaid]) <> @ZeroDecimal
        AND SUM(P.[dblBasePayment]) = @ZeroDecimal

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--ALREADY POSTED
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The transaction is already posted.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND P.[ysnPosted] = 1
		AND @Recap = 0
		AND @Post = 1

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--RECEIVABLES(S) ALREADY PAID IN FULL
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = P.[strTransactionNumber] + ' already paid in full.'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblPayment] <> @ZeroDecimal
        AND P.[ysnTransactionPaid] = 1
		AND @Recap = 0
		AND @Post = 1

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--over the transaction''s amount due'
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment on ' + P.[strTransactionNumber] + ' is over the transaction''s amount due'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblPayment] <> @ZeroDecimal
        AND P.[ysnTransactionPaid] = 0
        AND [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]) < @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[intInvoiceId]
        ,P.[strTransactionNumber]
        ,P.[strBatchId]
    HAVING
         (-((AVG(P.[dblTransactionAmountDue]) + AVG(P.[dblTransactionInterest])) - AVG(P.[dblTransactionDiscount]))) > ((SUM(P.[dblPayment]) - SUM(P.[dblInterest])) + SUM(P.[dblDiscount]))

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--over the transaction''s amount due
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment on ' + P.[strTransactionNumber] + ' is over the transaction''s amount due'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = 1
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblPayment] <> @ZeroDecimal
        AND P.[ysnTransactionPaid] = 0
        AND [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]) > @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[intInvoiceId]
        ,P.[strTransactionNumber]
        ,P.[strBatchId]
    HAVING
        ((AVG(P.[dblTransactionAmountDue]) + AVG(P.[dblTransactionInterest])) - AVG(P.[dblTransactionDiscount])) < ((SUM(P.[dblPayment]) - SUM(P.[dblInterest])) + SUM(P.[dblDiscount]))

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--AllowOtherUserToPost
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot Post transaction(' + P.[strTransactionId] + ') you did not create.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND P.[intEntityId] <> [intUserId]
        AND P.[ysnUserAllowedToPostOtherTrans] = 1

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Unprocessed Credit Card
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Credit Card Needs Processed to continue with Posting.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 1
        AND ISNULL(P.[intEntityCardInfoId], 0) <> 0 
        AND ISNULL(P.[ysnProcessCreditCard], 0) = 0
        AND @Recap = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Processed Credit Card but didn't reached Vantiv
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Credit card payment was marked processed but didn''t hit Vantiv.'
	FROM
		#ARPostPaymentHeader P
    OUTER APPLY (
        SELECT TOP 1 intPaymentId
        FROM tblSMPayment SM
        WHERE SM.intTransactionId = P.intTransactionId
          AND SM.strTransactionNo = P.strTransactionId
          AND SM.strPaymentMethod = 'Credit Card'
    ) SMPAY
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND ISNULL(P.[intEntityCardInfoId], 0) <> 0 
        AND ISNULL(P.[ysnProcessCreditCard], 0) = 1
        AND ISNULL(SMPAY.intPaymentId, 0) = 0
        AND @Recap = 0

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Undeposited Funds Account not active.
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Undeposited Funds Account : ' + GLA.[strAccountId] + ' is not active.'
	FROM
		#ARPostPaymentHeader P
    INNER JOIN 
		#ARPaymentAccount GLA
			ON P.[intUndepositedFundsId] = GLA.[intAccountId] 
    WHERE
            P.[ysnPost] = 1
        AND P.[intCompanyLocationId] IS NOT NULL
        AND P.[intUndepositedFundsId] IS NOT NULL
        AND GLA.[ysnActive] != 1

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	-- GL Account Does not Exist
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Undeposited Funds Account : ' + GLA.[strAccountId] + ' does not exist.'
	FROM
		#ARPostPaymentHeader P
    LEFT OUTER JOIN 
		#ARPaymentAccount GLA
			ON P.[intUndepositedFundsId] = GLA.[intAccountId] 
    WHERE
            P.[ysnPost] = 1
        AND P.[intCompanyLocationId] IS NOT NULL
        AND P.[intUndepositedFundsId] IS NOT NULL
        AND GLA.[intAccountId] IS NULL

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--In-active Bank Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Bank Account ' + CMBA.[strBankAccountNo] + ' is not active.'
	FROM
		#ARPostPaymentHeader P
    INNER JOIN (SELECT [intBankAccountId], [ysnActive], [strBankAccountNo] FROM tblCMBankAccount) CMBA
        ON P.[intBankAccountId] = CMBA.[intBankAccountId] 
    WHERE
            P.[ysnPost] = 1
        AND CMBA.[ysnActive] != 1

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Bank Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Cash Account is not linked to any of the active Bank Account in Cash Management'
	FROM
		#ARPostPaymentHeader P
    INNER JOIN 
		#ARPaymentAccount GLAD
			ON P.[intAccountId] = GLAD.[intAccountId]
    LEFT OUTER JOIN 
		(SELECT [intBankAccountId], [ysnActive], [intGLAccountId] FROM tblCMBankAccount) CMBA
			ON P.[intAccountId] = CMBA.[intGLAccountId]
    WHERE
            P.[ysnPost] = 1
        AND GLAD.[strAccountCategory] = 'Cash Account'
        AND (CMBA.[ysnActive] != 1 OR  CMBA.[intGLAccountId] IS NULL)


	--DECLARE @InvoiceIdsForChecking TABLE (
	--	intInvoiceId int PRIMARY KEY,
	--	UNIQUE (intInvoiceId)
	--);

	--INSERT INTO @InvoiceIdsForChecking(intInvoiceId)
	--SELECT DISTINCT
	--	PD.intInvoiceId 
	--FROM
	--	tblARPaymentDetail PD 
	--INNER JOIN
	--	@Payments P
	--		ON PD.intPaymentId = P.intTransactionId
	--WHERE
	--	PD.dblPayment <> 0
	--GROUP BY
	--	PD.intInvoiceId
	--HAVING
	--	COUNT(PD.intInvoiceId) > 1
	--	AND @Post = 1
				
	--WHILE(EXISTS(SELECT TOP 1 NULL FROM @InvoiceIdsForChecking))
	--BEGIN
	--	DECLARE @InvID INT			
	--			,@InvoicePayment NUMERIC(18,6) = 0
					
	--	SELECT TOP 1 @InvID = intInvoiceId FROM @InvoiceIdsForChecking
				
	--	DECLARE @InvoicePaymentDetail TABLE(
	--		intPaymentId INT,
	--		intInvoiceId INT,
	--		dblInvoiceTotal NUMERIC(18,6),
	--		dblAmountDue NUMERIC(18,6),
	--		dblPayment NUMERIC(18,6),
	--		intPaymentDetailId INT,
	--		strBatchId nvarchar(100),
	--		strInvoiceNumber nvarchar(100)
	--	);
				
	--	INSERT INTO @InvoicePaymentDetail(intPaymentId, intInvoiceId, dblInvoiceTotal, dblAmountDue, dblPayment, intPaymentDetailId, strBatchId, strInvoiceNumber)
	--	SELECT distinct
	--		A.intPaymentId
	--		,C.intInvoiceId
	--		,C.dblInvoiceTotal
	--		,C.dblAmountDue
	--		,B.dblPayment
	--		,B.intPaymentDetailId
	--		,P.strBatchId
	--		,C.strInvoiceNumber
	--	FROM
	--		tblARPayment A
	--	INNER JOIN
	--		tblARPaymentDetail B
	--			ON A.intPaymentId = B.intPaymentId
	--	INNER JOIN
	--		tblARInvoice C
	--			ON B.intInvoiceId = C.intInvoiceId
	--	INNER JOIN
	--		@Payments P
	--			ON A.intPaymentId = P.intTransactionId
	--	WHERE
	--		C.intInvoiceId = @InvID
	--		AND @Post = 1
			
					
	--	WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicePaymentDetail)
	--	BEGIN
	--		DECLARE @PayID INT
	--				,@AmountDue NUMERIC(18,6) = 0
	--		SELECT TOP 1 @PayID = intPaymentId, @AmountDue = dblAmountDue, @InvoicePayment = @InvoicePayment + dblPayment FROM @InvoicePaymentDetail ORDER BY intPaymentId
				
	--		IF @AmountDue < @InvoicePayment
	--		BEGIN
	--				INSERT INTO @returntable
	--				([intTransactionId]
	--				,[strTransactionId]
	--				,[strTransactionType]
	--				,[intTransactionDetailId]
	--				,[strBatchId]
	--				,[strError])
	--				SELECT   
	--				[intTransactionId]         = P.intPaymentId
	--				,[strTransactionId]         = A.strRecordNumber
	--				,[strTransactionType]       = @TransType
	--				,[intTransactionDetailId]   = P.intPaymentDetailId
	--				,[strBatchId]               = P.[strBatchId]                         
	--				,[strError]                 = 'Payment on ' + P.strInvoiceNumber COLLATE Latin1_General_CI_AS + ' is over the transaction''s amount due' 
	--				FROM
	--					tblARPayment A
	--				INNER JOIN
	--					@InvoicePaymentDetail P
	--						ON A.intPaymentId = P.intPaymentId
	--				WHERE A.intPaymentId = @PayID
	--			END									
	--			DELETE FROM @InvoicePaymentDetail WHERE intPaymentId = @PayID	
	--		END
	--		DELETE FROM @InvoiceIdsForChecking WHERE intInvoiceId = @InvID							
	--END

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Bank Account
	SELECT
         [intTransactionId]         = ARPD.[intTransactionId]
        ,[strTransactionId]         = ARPD.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = ARPD.[intTransactionDetailId]
        ,[strBatchId]               = ARPD.[strBatchId]
        ,[strError]                 = 'Payment on ' + ARI.strInvoiceNumber +  '(' + ARPD.[strTransactionId] + ') will be over the transaction''s amount due' 
	FROM
		#ARPostPaymentDetail ARPD
	INNER JOIN
		tblARInvoice ARI
			ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(
		SELECT 
			 [intInvoiceId] = PD.[intInvoiceId]
			,[dblPayment]   = SUM(PD.[dblPayment])
		FROM
			#ARPostPaymentDetail PD 
		WHERE
			PD.[ysnPost] = 1
			AND PD.[dblPayment] <> 0
		GROUP BY
			PD.[intInvoiceId]
		HAVING
			COUNT(PD.[intInvoiceId]) > 1
		) ARI2
			ON ARI.[intInvoiceId] = ARI2.[intInvoiceId]
	WHERE
		ARPD.[ysnPost] = 1
		AND ARI.[dblAmountDue] < ARI2.[dblPayment]
	ORDER BY
		ARI.[intInvoiceId]


END

IF @Post = 0
BEGIN

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--ALREADY POSTED
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The transaction has not been posted yet.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 0
        AND P.[ysnPosted] = 0
		AND @Recap = 0
		AND @Post = 0

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Provisional
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Provisional Invoice(' + P.[strTransactionNumber] + ') was already processed!' 
	FROM
		#ARPostPaymentDetail P    
    WHERE
            P.[ysnPost] = 0
        AND P.[strType] = 'Provisional'
        AND P.[ysnTransactionProcessed] = 1

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--AllowOtherUserToPost
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot UnPost transaction(' + P.[strTransactionId] + ') you did not create.'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = 0
        AND P.[intEntityId] <> [intUserId]
        AND P.[ysnUserAllowedToPostOtherTrans] = 1

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Invoice with Discount
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Discount has been applied to Invoice: ' + P.[strTransactionNumber] + '. Payment: ' + P1.strRecordNumber + ' must unposted first!'
	FROM
		#ARPostPaymentDetail P
    INNER JOIN
        (
        SELECT
             I.[intInvoiceId]
            ,P.[intPaymentId]
            ,P.[strRecordNumber]
        FROM
            tblARPaymentDetail PD		
        INNER JOIN	
            tblARPayment P ON PD.intPaymentId = P.intPaymentId	
        INNER JOIN	
            tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
        WHERE
                PD.[dblDiscount] <> @ZeroDecimal
            AND I.[dblAmountDue] = @ZeroDecimal
        ) P1
            ON P.[intInvoiceId] = P1.[intInvoiceId] AND P.[intTransactionId] <> P1.[intPaymentId] 
    WHERE
            P.[ysnPost] = 0
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Invoice with Interest
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Interest has been applied to Invoice: ' + P.[strTransactionNumber] + '. Payment: ' + P1.strRecordNumber + ' must unposted first!'
	FROM
		#ARPostPaymentDetail P
    INNER JOIN
        (
        SELECT
             I.[intInvoiceId]
            ,P.[intPaymentId]
            ,P.[strRecordNumber]
        FROM
            tblARPaymentDetail PD		
        INNER JOIN	
            tblARPayment P ON PD.intPaymentId = P.intPaymentId	
        INNER JOIN	
            tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
        WHERE
                PD.[dblInterest] <> @ZeroDecimal
            AND I.[dblAmountDue] = @ZeroDecimal
        ) P1
            ON P.[intInvoiceId] = P1.[intInvoiceId] AND P.[intTransactionId] <> P1.[intPaymentId] 
    WHERE
            P.[ysnPost] = 0
        AND P.[intInvoiceId] IS NOT NULL

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Already cleared/reconciled
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The transaction is already cleared.'
	FROM
		#ARPostPaymentHeader P
    INNER JOIN (SELECT [ysnClr], [strTransactionId] FROM tblCMBankTransaction) CMBT
        ON P.[strTransactionId] = CMBT.[strTransactionId] 
    WHERE
            P.[ysnPost] = 0
        AND CMBT.[ysnClr] = 1

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Payment with created Bank Deposit
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot unpost payment with created Bank Deposit.'
	FROM
		#ARPostPaymentHeader P
    INNER JOIN (SELECT [intSourceTransactionId], [strSourceTransactionId], [strSourceSystem], [intUndepositedFundId] FROM tblCMUndepositedFund) CMUF
        ON  P.[strTransactionId] = CMUF.[strSourceTransactionId]
        AND P.[intTransactionId] = CMUF.[intSourceTransactionId]
    INNER JOIN (SELECT [intUndepositedFundId] FROM tblCMBankTransactionDetail) CMBTD
        ON CMUF.[intUndepositedFundId] = CMBTD.[intUndepositedFundId]
    WHERE
            P.[ysnPost] = 0
        AND CMUF.[strSourceSystem] = 'AR'
		AND @Recap = 0

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Payment with associated Overpayment
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There''s an overpayment(' + ARI.[strInvoiceNumber] + ') created from ' + P.[strTransactionId] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
	FROM
		#ARPostPaymentHeader P
    INNER JOIN (SELECT [intInvoiceId], [ysnPosted], [strComments], [intPaymentId], [strTransactionType], [strInvoiceNumber] FROM tblARInvoice) ARI
        ON  (P.[strTransactionId] = ARI.[strComments] OR P.[intTransactionId] = ARI.[intPaymentId])
        AND ARI.[strTransactionType] = 'Overpayment'
    INNER JOIN (SELECT [intPaymentId], [intInvoiceId] FROM tblARPaymentDetail) ARPD
        ON  ARI.[intInvoiceId] =  ARPD.[intInvoiceId] 
        AND P.[intTransactionId] <> ARPD.[intPaymentId]
    INNER JOIN (SELECT [intPaymentId], [strRecordNumber] FROM tblARPayment) ARP
        ON  ARPD.[intPaymentId] =  ARP.[intPaymentId] 
    WHERE
		P.[ysnPost] = 0

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Payment with associated Customer Prepayment	
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There''s a prepayment(' + ARI.[strInvoiceNumber] + ') created from ' + P.[strTransactionId] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
	FROM
		#ARPostPaymentHeader P
    INNER JOIN (SELECT [intInvoiceId], [ysnPosted], [strComments], [intPaymentId], [strTransactionType], [strInvoiceNumber] FROM tblARInvoice) ARI
        ON  (P.[strTransactionId] = ARI.[strComments] OR P.[intTransactionId] = ARI.[intPaymentId])
        AND ARI.[strTransactionType] = 'Customer Prepayment'
    INNER JOIN (SELECT [intPaymentId], [intInvoiceId] FROM tblARPaymentDetail) ARPD
        ON  ARI.[intInvoiceId] =  ARPD.[intInvoiceId] 
        AND P.[intTransactionId] <> ARPD.[intPaymentId]
    INNER JOIN (SELECT [intPaymentId], [strRecordNumber] FROM tblARPayment) ARP
        ON  ARPD.[intPaymentId] =  ARP.[intPaymentId] 
    WHERE
        P.[ysnPost] = 0

END

RETURN 1

