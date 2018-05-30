CREATE FUNCTION [dbo].[fnARGetInvalidPaymentsForPosting]
(
     @Payments	[dbo].[ReceivePaymentPostingTable] Readonly
	,@Post		BIT	= 0
	,@Recap		BIT = 0
)
RETURNS @returntable TABLE
(
     [intTransactionId]         INT             NOT NULL
    ,[strTransactionId]         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]       NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[intTransactionDetailId]   INT             NULL
    ,[strBatchId]               NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[strError]                 NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
)
AS
BEGIN

    DECLARE @ZeroDecimal    DECIMAL(18,6)
           ,@TransType      NVARCHAR(50) 
    SET @ZeroDecimal = 0.000000
    SET @TransType = 'Receivable'

    --POST
	INSERT INTO @returntable
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
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Undeposited Funds account in Company Location - ' + P.[strLocationName]  + ' was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND ISNULL(P.[intUndepositedFundsId], 0) = 0

    UNION

    --AR Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The AR Account in Company Configuration was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND ISNULL(P.[intARAccountId], 0) = 0

    UNION

    --Payment without payment on detail (get all detail that has 0 payment)
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There was no payment to receive.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[dblAmountPaid] = @ZeroDecimal
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[strBatchId]
    HAVING
            SUM(P.dblPayment) = @ZeroDecimal
		AND MAX(P.dblPayment) = @ZeroDecimal
		AND MIN(P.dblPayment) = @ZeroDecimal

    UNION

    --Payment without detail
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There was no payment to receive.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[dblAmountPaid] = @ZeroDecimal
        AND P.[intTransactionDetailId] IS NOT NULL
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[strBatchId]
    HAVING
            COUNT(P.[intTransactionDetailId]) = 0

    UNION

    --Unposted Invoice(s)
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Transaction - ' + P.[strTransactionNumber] + ' is not posted!'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[ysnTransactionPosted] = 0
        AND ISNULL(P.[dblPayment], 0) <> @ZeroDecimal

    UNION

    --Exclude Recieved Amount in Final Invoice enabled
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Invoice ' + P.[strTransactionNumber] + ' was posted with ''Exclude Recieved Amount in Final Invoice'' option enabled! Payment not allowed!'  
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND ISNULL(P.[dblPayment], 0) <> @ZeroDecimal
        AND P.[ysnExcludedFromPayment] = 1

    UNION

    --Invoice Prepayment
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = P.[strTransactionId] + '''s payment amount must be equal to ' + P.[strTransactionNumber] + '''s prepay amount!'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[ysnInvoicePrepayment] = 1
        AND (P.[dblInvoiceTotal] <> P.[dblPayment] OR P.[dblInvoiceTotal] <> P.[dblAmountPaid])

    UNION

    --Forgiven Invoice(s)
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Invoice ' + P.[strTransactionNumber] + ' has been forgiven!'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[strType] = 'Service Charge'
        AND P.[ysnForgiven] = 1
        AND P.[dblPayment] <> @ZeroDecimal

    UNION

    --Return Payment not allowed
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Return Payment is not allowed.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND P.[strPaymentMethod] = 'ACH'
        AND P.[ysnInvoicePrepayment] = 0
        AND P.[dblAmountPaid] < @ZeroDecimal

    UNION

    --Fiscal Year
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = P.[strTransactionId] + '- Unable to find an open fiscal year period to match the transaction date.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND ISNULL([dbo].isOpenAccountingDate(P.[dtmDatePaid]), 0) = 0

    UNION

    --Company Location
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Company location of ' + P.[strTransactionId] + ' was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND P.[intCompanyLocationId] IS NULL

    UNION

    --Sales Discount Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Discounts account in Company Configuration was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblDiscount] <> @ZeroDecimal
        AND ISNULL(P.[intDiscountAccount], 0) = 0

    UNION

    --Income Interest Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Income Interest account in Company Location or Company Configuration was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblInterest] <> @ZeroDecimal
        AND ISNULL(P.[intInterestAccount], 0) = 0

    UNION

    --Write Off Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Write Off account in Company Configuration was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND UPPER(P.[strPaymentMethod]) = UPPER('Write Off')
        AND ISNULL(P.[intWriteOffAccountId], 0) = 0

    UNION

    --CF Invoice Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The CF Invoice Account # in Company Configuration was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND UPPER(P.[strPaymentMethod]) = UPPER('CF Invoice')
        AND ISNULL(P.[intCFAccountId], 0) = 0

    UNION

    --NOT BALANCE
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The debit and credit amounts are not balanced.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
    GROUP BY
         P.[intTransactionId]
        ,P.[strTransactionId]
        ,P.[strBatchId]
    HAVING
            AVG(P.[dblAmountPaid]) < SUM(P.[dblPayment])
        --OR  AVG(P.[dblBaseAmountPaid]) < SUM(P.[dblBasePayment])

    UNION

    --Payment Date
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment Date(' + CONVERT(NVARCHAR(30),P.[dtmDatePaid], 101) + ') cannot be earlier than the Invoice(' + P.[strTransactionNumber] + ') Post Date(' + CONVERT(NVARCHAR(30),P.[dtmTransactionPostDate], 101) + ')!'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND CAST(P.[dtmTransactionPostDate] AS DATE) > CAST(P.[dtmDatePaid] AS DATE)
        AND P.[dblPayment] <> @ZeroDecimal

    UNION

    --Realized Gain or Loss account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Accounts Receivable Realized Gain or Loss account in Company Configuration was not set.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND ISNULL(((((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblTransactionInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseTransactionDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]))) - P.[dblBasePayment]), @ZeroDecimal) <> @ZeroDecimal
        AND ISNULL(P.[intGainLossAccount],0) = 0

    UNION

    --Validate Bank Account for ACH Payment Method
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Bank Account is required for payment with ACH payment method!'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND ISNULL(P.[intBankAccountId], 0) = 0
        AND P.[strPaymentMethod] = 'ACH'

    UNION

    --Prepaid Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Customer Prepaid account in Company Location - ' + MAX(ISNULL(P.[strLocationName],''))  + ' was not set.'
	FROM
		@Payments P
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

    UNION

    --ALREADY POSTED
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The transaction is already posted.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND P.[ysnPosted] = 1
		AND @Recap = 0
		AND @Post = 1

    UNION

    --RECEIVABLES(S) ALREADY PAID IN FULL
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = P.[strTransactionNumber] + ' already paid in full.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL
        AND P.[dblPayment] <> @ZeroDecimal
        AND P.[ysnTransactionPaid] = 1
		AND @Recap = 0
		AND @Post = 1

    UNION

    --over the transaction''s amount due'
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment on ' + P.[strTransactionNumber] + ' is over the transaction''s amount due'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
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
            (-((AVG(P.[dblTransactionAmountDue]) + AVG(P.[dblTransactionInterest])) - AVG(P.[dblTransactionDiscount]))) < ((SUM(P.[dblPayment]) - SUM(P.[dblInterest])) + SUM(P.[dblDiscount]))

    UNION

    --over the transaction''s amount due
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Payment on ' + P.[strTransactionNumber] + ' is over the transaction''s amount due'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NOT NULL
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
            ((AVG(P.[dblTransactionAmountDue]) + AVG(P.[dblTransactionInterest])) - AVG(P.[dblTransactionDiscount])) > ((SUM(P.[dblPayment]) - SUM(P.[dblInterest])) + SUM(P.[dblDiscount]))

    UNION

    --AllowOtherUserToPost
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot Post transactions you did not create.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND P.[intEntityId] <> [intUserId]
        AND P.[ysnUserAllowedToPostOtherTrans] = 1
    --UNPOST
    UNION

    --Provisional
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Provisional Invoice(' + P.[strTransactionNumber] + ') was already processed!' 
	FROM
		@Payments P    
    WHERE
            P.[ysnPost] = 0
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[strType] = 'Provisional'
        AND P.[ysnTransactionProcessed] = 1

    UNION

    --AllowOtherUserToPost
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot UnPost transactions you did not create.'
	FROM
		@Payments P
    WHERE
            P.[ysnPost] = 0
        AND P.[intTransactionDetailId] IS NULL
        AND P.[intEntityId] <> [intUserId]
        AND P.[ysnUserAllowedToPostOtherTrans] = 1


    --POST
    ---WITH OPTION(Recompile)
	INSERT INTO @returntable
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
		@Payments P
    INNER JOIN (SELECT [intAccountId], [ysnActive], [strAccountId] FROM tblGLAccount) GLA
        ON P.[intUndepositedFundsId] = GLA.[intAccountId] 
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND P.[intCompanyLocationId] IS NOT NULL
        AND P.[intUndepositedFundsId] IS NOT NULL
        AND GLA.[ysnActive] != 1

    UNION

    -- GL Account Does not Exist
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Undeposited Funds Account : ' + GLA.[strAccountId] + ' does not exist.'
	FROM
		@Payments P
    LEFT OUTER JOIN (SELECT [intAccountId], [ysnActive], [strAccountId] FROM tblGLAccount) GLA
        ON P.[intUndepositedFundsId] = GLA.[intAccountId] 
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND P.[intCompanyLocationId] IS NOT NULL
        AND P.[intUndepositedFundsId] IS NOT NULL
        AND GLA.[intAccountId] IS NULL

    UNION

    --In-active Bank Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Bank Account ' + CMBA.[strBankAccountNo] + ' is not active.'
	FROM
		@Payments P
    INNER JOIN (SELECT [intBankAccountId], [ysnActive], [strBankAccountNo] FROM tblCMBankAccount) CMBA
        ON P.[intBankAccountId] = CMBA.[intBankAccountId] 
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND CMBA.[ysnActive] != 1

    UNION

    --Bank Account
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The Cash Account is not linked to any of the active Bank Account in Cash Management'
	FROM
		@Payments P
    INNER JOIN (SELECT [intAccountId], [ysnActive], [strAccountCategory] FROM vyuGLAccountDetail) GLAD
        ON P.[intAccountId] = GLAD.[intAccountId]
    LEFT OUTER JOIN (SELECT [intBankAccountId], [ysnActive], [intGLAccountId] FROM tblCMBankAccount) CMBA
        ON P.[intAccountId] = CMBA.[intGLAccountId]
    WHERE
            P.[ysnPost] = 1
        AND P.[intTransactionDetailId] IS NULL
        AND GLAD.[strAccountCategory] = 'Cash Account'
        AND (CMBA.[ysnActive] != 1 OR  CMBA.[intGLAccountId] IS NULL)
    OPTION(recompile)

    --UNPOST
    ---WITH OPTION(Recompile)
    INSERT INTO @returntable
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
		@Payments P
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

    UNION

    --Invoice with Interest
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = NULL
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'Interest has been applied to Invoice: ' + P.[strTransactionNumber] + '. Payment: ' + P1.strRecordNumber + ' must unposted first!'
	FROM
		@Payments P
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
        AND P.[intTransactionDetailId] IS NOT NULL
        AND P.[intInvoiceId] IS NOT NULL

    UNION

    --Already cleared/reconciled
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'The transaction is already cleared.'
	FROM
		@Payments P
    INNER JOIN (SELECT [ysnClr], [strTransactionId] FROM tblCMBankTransaction) CMBT
        ON P.[strTransactionId] = CMBT.[strTransactionId] 
    WHERE
            P.[ysnPost] = 0
        AND P.[intTransactionDetailId] IS NULL
        AND CMBT.[ysnClr] = 1

    UNION

    --Payment with created Bank Deposit
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot unpost payment with created Bank Deposit.'
	FROM
		@Payments P
    INNER JOIN (SELECT [intSourceTransactionId], [strSourceTransactionId], [strSourceSystem], [intUndepositedFundId] FROM tblCMUndepositedFund) CMUF
        ON  P.[strTransactionId] = CMUF.[strSourceTransactionId]
        AND P.[intTransactionId] = CMUF.[intSourceTransactionId]
    INNER JOIN (SELECT [intUndepositedFundId] FROM tblCMBankTransactionDetail) CMBTD
        ON CMUF.[intUndepositedFundId] = CMBTD.[intUndepositedFundId]
    WHERE
            P.[ysnPost] = 0
        AND P.[intTransactionDetailId] IS NULL
        AND CMUF.[strSourceSystem] = 'AR'

    UNION

    --Payment with applied Prepayment
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'You cannot unpost payment with applied prepaids.'
	FROM
		@Payments P
    INNER JOIN (SELECT [intPrepaymentId], [ysnApplied], [dblAppliedInvoiceDetailAmount], [intInvoiceId] FROM tblARPrepaidAndCredit) ARPC
        ON  P.[intInvoiceId] = ARPC.[intPrepaymentId]
        AND ARPC.[ysnApplied] = 1
        AND ARPC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
    INNER JOIN (SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice) ARI
        ON  ARPC.[intInvoiceId] = ARI.[intInvoiceId]
        AND ARI.[ysnPosted] = 1
    WHERE
            P.[ysnPost] = 0
        AND P.[intTransactionDetailId] IS NULL

    UNION

    --Payment with associated Overpayment
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There''s an overpayment(' + ARI.[strInvoiceNumber] + ') created from ' + P.[strTransactionId] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
	FROM
		@Payments P
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
        AND P.[intTransactionDetailId] IS NULL

    UNION

    --Payment with associated Overpayment	
	SELECT
         [intTransactionId]         = P.[intTransactionId]
        ,[strTransactionId]         = P.[strTransactionId]
        ,[strTransactionType]       = @TransType
        ,[intTransactionDetailId]   = P.[intTransactionDetailId]
        ,[strBatchId]               = P.[strBatchId]
        ,[strError]                 = 'There''s a prepayment(' + ARI.[strInvoiceNumber] + ') created from ' + P.[strTransactionId] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
	FROM
		@Payments P
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
        AND P.[intTransactionDetailId] IS NULL
    OPTION(recompile)

	RETURN
END
