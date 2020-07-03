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

DECLARE @ZeroBit BIT
SET @ZeroBit = CAST(0 AS BIT)
DECLARE @OneBit BIT
SET @OneBit = CAST(1 AS BIT)


IF @Post = @OneBit
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
        P.[ysnPost] = @OneBit
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
        P.[ysnPost] = @OneBit
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
            P.[ysnPost] = @OneBit
        AND P.[dblAmountPaid] = @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
		,P.[strTransactionId]
        --,P.[intTransactionDetailId]
        ,P.[strBatchId]
    HAVING
            SUM(P.dblPayment + P.dblWriteOffAmount) = @ZeroDecimal
		AND MAX(P.dblPayment + P.dblWriteOffAmount) = @ZeroDecimal
		AND MIN(P.dblPayment + P.dblWriteOffAmount) = @ZeroDecimal

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
            P.[ysnPost] = @OneBit
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
            P.[ysnPost] = @OneBit
        AND P.[ysnTransactionPosted] = @ZeroBit
        AND ISNULL(P.[dblPayment], 0) <> @ZeroDecimal
        AND P.[strTransactionType] <> 'Claim'

 --   INSERT INTO #ARInvalidPaymentData
 --       ([intTransactionId]
 --       ,[strTransactionId]
 --       ,[strTransactionType]
 --       ,[intTransactionDetailId]
 --       ,[strBatchId]
 --       ,[strError])
	----Invoice Prepayment
	--SELECT
 --        [intTransactionId]         = P.[intTransactionId]
 --       ,[strTransactionId]         = P.[strTransactionId]
 --       ,[strTransactionType]       = @TransType
 --       ,[intTransactionDetailId]   = P.[intTransactionDetailId]
 --       ,[strBatchId]               = P.[strBatchId]
 --       ,[strError]                 = P.[strTransactionId] + '''s payment amount must be equal to ' + P.[strTransactionNumber] + '''s prepay amount!'
	--FROM
	--	#ARPostPaymentDetail P
 --   WHERE
 --           P.[ysnPost] = 1
 --       AND P.[intTransactionDetailId] IS NOT NULL
 --       AND P.[intInvoiceId] IS NOT NULL
 --       AND P.[ysnInvoicePrepayment] = 1
 --       AND (P.[dblInvoiceTotal] <> P.[dblPayment] OR P.[dblInvoiceTotal] <> P.[dblAmountPaid])

    -- INSERT INTO #ARInvalidPaymentData
    --     ([intTransactionId]
    --     ,[strTransactionId]
    --     ,[strTransactionType]
    --     ,[intTransactionDetailId]
    --     ,[strBatchId]
    --     ,[strError])
	-- --Forgiven Invoice(s)
	-- SELECT
    --      [intTransactionId]         = P.[intTransactionId]
    --     ,[strTransactionId]         = P.[strTransactionId]
    --     ,[strTransactionType]       = @TransType
    --     ,[intTransactionDetailId]   = P.[intTransactionDetailId]
    --     ,[strBatchId]               = P.[strBatchId]
    --     ,[strError]                 = 'Invoice ' + P.[strTransactionNumber] + ' has been forgiven!'
	-- FROM
	-- 	#ARPostPaymentDetail P
    -- WHERE
    --         P.[ysnPost] = 1
    --     AND P.[intInvoiceId] IS NOT NULL
    --     AND P.[strType] = 'Service Charge'
    --     AND P.[ysnForgiven] = 1
    --     AND P.[dblPayment] <> @ZeroDecimal

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
            P.[ysnPost] = @OneBit
        AND P.[strPaymentMethod] NOT IN ('ACH', 'CF Invoice', 'Cash', 'Debit Card', 'Credit Card', 'Manual Credit Card')
        AND P.[ysnInvoicePrepayment] = @ZeroBit
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
            P.[ysnPost] = @OneBit
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
        ,[strError]                 = 'The Sales Discounts account in Company Configuration was not set.'
	FROM #ARPostPaymentDetail P
    WHERE P.[ysnPost] = @OneBit
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
	--Purchase Discount Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Purchase Discount account in Company Location was not set.'
	FROM #ARPostPaymentDetail P
    WHERE P.[ysnPost] = @OneBit
      AND P.[intBillId] IS NOT NULL
      AND P.[dblDiscount] <> @ZeroDecimal
      AND ISNULL(P.[intDiscountAccount], 0) = 0

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Write off Account on detail
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Write off Account for ' + P.[strTransactionNumber] + ' was not set.'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = @OneBit
        AND P.[intInvoiceId] IS NOT NULL
        AND ISNULL(P.[dblWriteOffAmount], 0) <> @ZeroDecimal
        AND ISNULL(P.[intWriteOffAccountDetailId], 0) = 0

	 INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Write off Amount Greater than amount due on detail
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Write off Amount of ' + P.[strTransactionNumber] + ' should be less than or equal to '+CAST(CONVERT(DECIMAL(10,2), ISNULL(I.[dblAmountDue], 0)) AS NVARCHAR(100))
	FROM
		#ARPostPaymentDetail P
		INNER JOIN tblARInvoice I
		ON P.intInvoiceId = I.intInvoiceId
    WHERE
            P.[ysnPost] = @OneBit
        AND P.[intInvoiceId] IS NOT NULL
        AND ISNULL(P.[dblWriteOffAmount], 0) <> @ZeroDecimal
		AND ISNULL(I.[dblAmountDue], 0)   <  (ISNULL(P.[dblWriteOffAmount], 0) * -1)

	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Write off Amount Should be negative value
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Write off amount of ' + P.[strTransactionNumber] + ' should be a negative value'
	FROM
		#ARPostPaymentDetail P
		INNER JOIN tblARInvoice I
		ON P.intInvoiceId = I.intInvoiceId
    WHERE
            P.[ysnPost] = @OneBit
        AND P.[intInvoiceId] IS NOT NULL
        AND ISNULL(P.[dblWriteOffAmount], 0) <> @ZeroDecimal
		AND 0 < ISNULL(P.[dblWriteOffAmount], 0)
        AND I.strInvoiceNumber LIKE '%COP%'

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
            P.[ysnPost] = @OneBit
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
            P.[ysnPost] = @OneBit
        AND UPPER(P.[strPaymentMethod]) = UPPER('Write Off')
        AND ISNULL(P.[intWriteOffAccountId], 0) = 0

    -- INSERT INTO #ARInvalidPaymentData
    --     ([intTransactionId]
    --     ,[strTransactionId]
    --     ,[strTransactionType]
    --     ,[intTransactionDetailId]
    --     ,[strBatchId]
    --     ,[strError])
	-- --Write Off Account Category
	-- SELECT
    --      [intTransactionId]         = P.[intTransactionId]
    --     ,[strTransactionId]         = P.[strTransactionId]
    --     ,[strTransactionType]       = @TransType
    --     ,[intTransactionDetailId]   = P.[intTransactionDetailId]
    --     ,[strBatchId]               = P.[strBatchId]
    --     ,[strError]                 = 'The Write Off account selected: ' + GLAD.strAccountId + ' is a non-write-off Account Category.'
	-- FROM #ARPostPaymentHeader P
    -- INNER JOIN vyuGLAccountDetail GLAD ON P.intWriteOffAccountId = GLAD.intAccountId
    -- WHERE P.[ysnPost] = @OneBit
    --   AND UPPER(P.[strPaymentMethod]) = UPPER('Write Off')
    --   AND ISNULL(GLAD.[strAccountCategory], '') <> 'Write Off'

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
            P.[ysnPost] = @OneBit
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
            P.[ysnPost] = @OneBit
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
            P.[ysnPost] = @OneBit
        AND P.[intInvoiceId] IS NOT NULL
        AND ISNULL(P.[intGainLossAccount],0) = 0
		AND P.[strTransactionType] <> 'Claim'
		AND ((ISNULL(((((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]))) - P.[dblBasePayment]),0)))  <> @ZeroDecimal
		AND ((P.[dblTransactionAmountDue] + P.[dblInterest]) - P.[dblDiscount] - P.[dblWriteOffAmount]) = ((P.[dblPayment] - P.[dblInterest]) + P.[dblDiscount] + P.[dblWriteOffAmount])

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
            P.[ysnPost] = @OneBit
        AND ISNULL(P.[intBankAccountId], 0) = 0
        AND P.[strPaymentMethod] = 'ACH'

 --   INSERT INTO #ARInvalidPaymentData
 --       ([intTransactionId]
 --       ,[strTransactionId]
 --       ,[strTransactionType]
 --       ,[intTransactionDetailId]
 --       ,[strBatchId]
 --       ,[strError])
	----Prepaid Account
	--SELECT
 --        [intTransactionId]         = P.[intTransactionId]
 --       ,[strTransactionId]         = P.[strTransactionId]
 --       ,[strTransactionType]       = @TransType
 --       ,[intTransactionDetailId]   = NULL
 --       ,[strBatchId]               = P.[strBatchId]
 --       ,[strError]                 = 'The Customer Prepaid account in Company Location - ' + MAX(ISNULL(P.[strLocationName],''))  + ' was not set.'
	--FROM
	--	#ARPostPaymentHeader P
 --   WHERE
 --           P.[ysnPost] = @OneBit
 --   GROUP BY
 --        P.[intTransactionId]
 --       ,P.[strTransactionId]
 --       ,P.[strBatchId]
 --   HAVING
 --           MAX(ISNULL(P.[intSalesAdvAcct],0)) = 0
 --       AND AVG(P.[dblAmountPaid]) <> @ZeroDecimal
 --       AND SUM(P.[dblBasePayment]) = @ZeroDecimal

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
            P.[ysnPost] = @OneBit
        AND P.[ysnPosted] = @OneBit
		AND @Recap = @ZeroBit
		AND @Post = @OneBit

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
            P.[ysnPost] = @OneBit
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblPayment] <> @ZeroDecimal
        AND P.[ysnTransactionPaid] = @OneBit
		AND @Recap = @ZeroBit
		AND @Post = @OneBit

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
            P.[ysnPost] = @OneBit
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblPayment] <> @ZeroDecimal
        AND P.[ysnTransactionPaid] = @ZeroBit
        AND [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]) < @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[intInvoiceId]
        ,P.[strTransactionNumber]
        ,P.[strBatchId]
    HAVING
         (-((AVG(P.[dblTransactionAmountDue]) + AVG(P.[dblTransactionInterest])) - AVG(P.[dblTransactionDiscount]))) > ((SUM(P.[dblPayment]) - SUM(P.[dblInterest])) + SUM(P.[dblDiscount]) + SUM(P.[dblWriteOffAmount])) 

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
            P.[ysnPost] = @OneBit
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblPayment] <> @ZeroDecimal
        AND P.[ysnTransactionPaid] = @ZeroBit
        AND [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]) > @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[intInvoiceId]
        ,P.[strTransactionNumber]
        ,P.[strBatchId]
    HAVING
        ((AVG(P.[dblTransactionAmountDue]) + AVG(P.[dblTransactionInterest])) - AVG(P.[dblTransactionDiscount])) < ((SUM(P.[dblPayment]) - SUM(P.[dblInterest])) + SUM(P.[dblDiscount]) + SUM(P.[dblWriteOffAmount]))

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
            P.[ysnPost] = @OneBit
        AND P.[intEntityId] <> [intUserId]
        AND P.[ysnUserAllowedToPostOtherTrans] = @OneBit

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
            P.[ysnPost] = @OneBit
        AND ISNULL(P.[intEntityCardInfoId], 0) <> 0 
        AND ISNULL(P.[ysnProcessCreditCard], 0) = @ZeroBit
        AND @Recap = @ZeroBit

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
            P.[ysnPost] = @OneBit
        AND P.[intTransactionDetailId] IS NULL
        AND ISNULL(P.[intEntityCardInfoId], 0) <> 0 
        AND ISNULL(P.[ysnProcessCreditCard], 0) = @OneBit
        AND ISNULL(SMPAY.intPaymentId, 0) = 0
        AND @Recap = @ZeroBit

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
            P.[ysnPost] = @OneBit
        AND P.[intCompanyLocationId] IS NOT NULL
        AND P.[intUndepositedFundsId] IS NOT NULL
        AND GLA.[ysnActive] != @OneBit

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
            P.[ysnPost] = @OneBit
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
            P.[ysnPost] = @OneBit
        AND CMBA.[ysnActive] != @OneBit

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
            P.[ysnPost] = @OneBit
        AND GLAD.[strAccountCategory] = 'Cash Account'
        AND (CMBA.[ysnActive] != @OneBit OR  CMBA.[intGLAccountId] IS NULL)


INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Invalid Base Amounts - Header
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment ' + P.[strTransactionId] + ' has invalid currency field(s).'
	FROM
		#ARPostPaymentHeader P
    WHERE
            P.[ysnPost] = @OneBit
        AND P.[dblExchangeRate] = 1.000000
        AND (P.[dblAmountPaid] <> P.[dblBaseAmountPaid] OR P.[dblUnappliedAmount] <> P.[dblBaseUnappliedAmount])


	INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Invalid Base Amounts - Header
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment ' + P.[strTransactionId] + ' has invalid currency field(s).'
	FROM
		#ARPostPaymentDetail P
    WHERE
            P.[ysnPost] = @OneBit
        AND P.[dblCurrencyExchangeRate] = 1.000000
        AND (P.[dblPayment] <> P.[dblBasePayment] OR P.[dblDiscount] <> P.[dblBaseDiscount] OR P.[dblInterest] <> P.[dblBaseInterest])

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Inactive Customer for Prepayments
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The customer provided is not active!'
	FROM #ARPostPaymentHeader P
    INNER JOIN tblARCustomer C ON P.intEntityCustomerId = C.intEntityId
    WHERE P.[ysnPost] = @OneBit
     AND ISNULL(C.ysnActive, 0) = 0
     AND (
         ((P.[dblAmountPaid]) > (SELECT SUM([dblPayment]) FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND [intTransactionId] = P.[intTransactionId]) -- Overpayment
		  AND EXISTS(SELECT NULL FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND [intTransactionId] = P.[intTransactionId] AND [dblPayment] <> @ZeroDecimal))
     OR ((P.[dblAmountPaid]) <> @ZeroDecimal --Prepayment
		AND ISNULL((SELECT SUM([dblPayment]) FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND ([intInvoiceId] IS NOT NULL OR [intBillId] IS NOT NULL) AND [intTransactionId] = P.[intTransactionId]), @ZeroDecimal) = @ZeroDecimal	
		AND NOT EXISTS(SELECT NULL FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit AND ([intInvoiceId] IS NOT NULL OR [intBillId] IS NOT NULL) AND [intTransactionId] = P.[intTransactionId] AND [dblPayment] <> @ZeroDecimal))
     )	

    IF(OBJECT_ID('tempdb..#DUPLICATEINVOICES') IS NOT NULL)
    BEGIN
        DROP TABLE #DUPLICATEINVOICES
    END

    SELECT [intTransactionId]       = ARPD.[intTransactionId]
        , [strTransactionId]       = ARPD.[strTransactionId]
        , [intTransactionDetailId] = ARPD.[intTransactionDetailId]
        , [intInvoiceId]			= ARPD.[intInvoiceId]
        , [dblAmountDue]			= ARI.[dblAmountDue]
        , [dblPayment]				= ARPD.[dblPayment]
        , [ysnProcessed]			= CAST(0 AS BIT)
        , [strBatchId]				= ARPD.strBatchId
        , [strInvoiceNumber]		= ARI.strInvoiceNumber
    INTO #DUPLICATEINVOICES
    FROM #ARPostPaymentDetail ARPD
    INNER JOIN tblARInvoice ARI ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
    INNER JOIN (
        SELECT [intInvoiceId] = PD.[intInvoiceId]
             , [dblPayment]   = ((SUM(PD.[dblPayment]) - SUM(PD.[dblInterest])) + SUM(PD.[dblDiscount]) + SUM(PD.[dblWriteOffAmount]))
        FROM #ARPostPaymentDetail PD 
        WHERE PD.[ysnPost] = 1
        AND PD.[dblPayment] <> 0
        GROUP BY PD.[intInvoiceId]
        HAVING COUNT(PD.[intInvoiceId]) > 1
    ) ARI2 ON ARI.[intInvoiceId] = ARI2.[intInvoiceId]
    WHERE ARPD.[ysnPost] = 1
    AND ARI.[dblAmountDue] < ARI2.[dblPayment]
    AND ARPD.intInvoiceId IS NOT NULL
    ORDER BY ARI.[intInvoiceId]

    WHILE EXISTS (SELECT TOP 1 NULL FROM #DUPLICATEINVOICES WHERE ysnProcessed = 0)
    BEGIN
        DECLARE @dblAmountDue			NUMERIC(18, 6) = 0
            , @dblPayment				NUMERIC(18, 6) = 0
            , @intTransactionId		INT = NULL
            , @intTransactionDetailId INT = NULL
            , @intInvoiceId			INT = NULL

        --GET INVOICE INFO.
        SELECT TOP 1 @intInvoiceId	= intInvoiceId 
                , @dblAmountDue	= dblAmountDue
        FROM #DUPLICATEINVOICES 
        GROUP BY intInvoiceId, dblAmountDue
        HAVING COUNT(intInvoiceId) > 1

        --GET PAYMENTS OF THAT INVOICE
        WHILE EXISTS (SELECT TOP 1 NULL FROM #DUPLICATEINVOICES WHERE intInvoiceId = @intInvoiceId AND ysnProcessed = 0)
            BEGIN
                SET @intTransactionId = NULL
                SET @intTransactionDetailId = NULL
                SET @dblPayment = 0

                SELECT TOP 1 @intTransactionId			= DI.intTransactionId
                        , @intTransactionDetailId	= DI.intTransactionDetailId
                        , @dblPayment				= PD.dblPayment
                FROM #DUPLICATEINVOICES DI
                INNER JOIN #ARPostPaymentDetail PD ON DI.intTransactionId = PD.intTransactionId 
                                                AND DI.intTransactionDetailId = PD.intTransactionDetailId
                WHERE DI.intInvoiceId = @intInvoiceId
                AND DI.ysnProcessed = 0
                ORDER BY DI.intTransactionId ASC
            
                --DELETE FROM INVALID LISTS IF PAYMENT IS VALID
                IF @dblAmountDue >= @dblPayment
                    BEGIN
                        SET @dblAmountDue = @dblAmountDue - @dblPayment

                        DELETE FROM #DUPLICATEINVOICES 
                        WHERE intTransactionId = @intTransactionId 
                        AND intTransactionDetailId = @intTransactionDetailId 
                        AND intInvoiceId = @intInvoiceId
                    END
                ELSE
                    BEGIN
                        UPDATE #DUPLICATEINVOICES 
                        SET ysnProcessed = 1
                        WHERE intTransactionId = @intTransactionId 
                        AND intTransactionDetailId = @intTransactionDetailId 
                        AND intInvoiceId = @intInvoiceId	
                    END
            END
    END

    INSERT INTO #ARInvalidPaymentData (
        [intTransactionId]
        , [strTransactionId]
        , [strTransactionType]
        , [intTransactionDetailId]
        , [strBatchId]
        , [strError]
    )
    SELECT [intTransactionId]		= DI.intTransactionId
        , [strTransactionId]		= DI.strTransactionId
        , [strTransactionType]		= @TransType
        , [intTransactionDetailId]	= DI.intTransactionDetailId
        , [strBatchId]				= DI.strBatchId
        , [strError]				= 'Payment on ' + DI.strInvoiceNumber +  '(' + DI.[strTransactionId] + ') will be over the transaction''s amount due' 
    FROM #DUPLICATEINVOICES DI

END

IF @Post = @ZeroBit
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
            P.[ysnPost] = @ZeroBit
        AND P.[ysnPosted] = @ZeroBit
		AND @Recap = @ZeroBit
		AND @Post = @ZeroBit

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
            P.[ysnPost] = @ZeroBit
        AND P.[strType] = 'Provisional'
        AND P.[ysnTransactionProcessed] = @OneBit

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
            P.[ysnPost] = @ZeroBit
        AND P.[intEntityId] <> [intUserId]
        AND P.[ysnUserAllowedToPostOtherTrans] = @OneBit

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
			AND P.[ysnPosted] = @OneBit
        ) P1
            ON P.[intInvoiceId] = P1.[intInvoiceId] AND P.[intTransactionId] <> P1.[intPaymentId] 
    WHERE
            P.[ysnPost] = @ZeroBit
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
            P.[ysnPost] = @ZeroBit
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
            P.[ysnPost] = @ZeroBit
        AND CMBT.[ysnClr] = @OneBit

    INSERT INTO #ARInvalidPaymentData
        ([intTransactionId]
        ,[strTransactionId]
        ,[strTransactionType]
        ,[intTransactionDetailId]
        ,[strBatchId]
        ,[strError])
	--Prepayment was refunded
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot unpost payment that was already refunded.'
	FROM #ARPostPaymentHeader P
    INNER JOIN tblARInvoice I ON P.intTransactionId = I.intPaymentId
    WHERE P.[ysnPost] = @ZeroBit
      AND P.[ysnInvoicePrepayment] = @OneBit
      AND I.[strTransactionType] = 'Customer Prepayment'
      AND I.[ysnRefundProcessed] = @OneBit

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
            P.[ysnPost] = @ZeroBit
        AND CMUF.[strSourceSystem] = 'AR'
		AND @Recap = @ZeroBit

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
		P.[ysnPost] = @ZeroBit

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
        P.[ysnPost] = @ZeroBit

END

RETURN 1

