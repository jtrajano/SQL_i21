CREATE FUNCTION [dbo].[fnARGetInvalidPaymentsForPosting]
(
     @Payments	[dbo].[ReceivePaymentPostingTable] Readonly
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
	--SELECT 
	--	'The Undeposited Funds account in Company Location - ' + CL.strLocationName  + ' was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail D
	--		ON A.intPaymentId = D.intPaymentId
	--INNER JOIN
	--	tblSMCompanyLocation CL
	--		ON A.intLocationId = CL.intCompanyLocationId 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--WHERE
	--	ISNULL(CL.intUndepositedFundsId,0)  = 0
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
	--SELECT 
	--	'The AR Account in Company Configuration was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail D
	--		ON A.intPaymentId = D.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--WHERE
	--	(@ARAccount IS NULL OR @ARAccount = 0)
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
	--SELECT
	--	'There was no payment to receive.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A 
	--INNER JOIN 
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId					
	--WHERE
	--	A.dblAmountPaid = 0
	--GROUP BY
	--	 A.strRecordNumber
	--	,A.intPaymentId			
	--HAVING
	--	SUM(B.dblPayment) = 0
	--	AND MAX(B.dblPayment) = 0
	--	AND MIN(B.dblPayment) = 0			
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
	--SELECT 
	--	'There was no payment to receive.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM 
	--	tblARPayment A 
	--LEFT JOIN 
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						
	--WHERE
	--	B.intPaymentId IS NULL
	--	AND A.dblAmountPaid = 0
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
	--SELECT  
	--	'Invoice ' + ARI.strInvoiceNumber + ' is not posted!'  
	--	,'Receivable'  
	--	,ARP.strRecordNumber  
	--	,@batchId  
	--	,ARP.intPaymentId  
	--FROM  
	--	tblARPaymentDetail ARPD   
	--INNER JOIN   
	--	tblARPayment ARP  
	--		ON ARPD.intPaymentId = ARP.intPaymentId  
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARPD.intInvoiceId = ARI.intInvoiceId
	--INNER JOIN  
	--	@ARReceivablePostData P  
	--		ON ARP.intPaymentId = ARP.intPaymentId
	--WHERE
	--	ISNULL(ARPD.dblPayment,0.00) <> 0.00
	--	AND ISNULL(ARI.ysnPosted,0) = 0
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
        AND P.[strTransactionType] <> 'Claim'

    UNION
    --Exclude Recieved Amount in Final Invoice enabled
	--SELECT  
	--	'Invoice ' + ARI.strInvoiceNumber + ' was posted with ''Exclude Recieved Amount in Final Invoice'' option enabled! Payment not allowed!'  
	--	,'Receivable'  
	--	,ARP.strRecordNumber  
	--	,@batchId  
	--	,ARP.intPaymentId  
	--FROM  
	--	tblARPaymentDetail ARPD   
	--INNER JOIN   
	--	tblARPayment ARP  
	--		ON ARPD.intPaymentId = ARP.intPaymentId  
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARPD.intInvoiceId = ARI.intInvoiceId
	--INNER JOIN  
	--	@ARReceivablePostData P  
	--		ON ARP.intPaymentId = ARP.intPaymentId
	--WHERE
	--	ISNULL(ARPD.dblPayment,0.00) <> 0.00
	--	AND ISNULL(ARI.ysnPosted,0) = 1
	--	AND ISNULL(ARI.ysnExcludeFromPayment,0) = 1
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
	--SELECT 
	--	A.strRecordNumber + '''s payment amount must be equal to ' + B.strTransactionNumber + '''s prepay amount!'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM 
	--	tblARPaymentDetail B
	--INNER JOIN 
	--	tblARPayment A 
	--		ON B.intPaymentId = A.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						
	--WHERE
	--	ISNULL(A.ysnInvoicePrepayment, 0) = 1
	--	AND (B.dblInvoiceTotal <> B.dblPayment OR B.dblInvoiceTotal <> A.dblAmountPaid)
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
	--SELECT  
	--	'Invoice ' + ARI.strInvoiceNumber + ' has been forgiven!'  
	--	,'Receivable'  
	--	,ARP.strRecordNumber  
	--	,@batchId  
	--	,ARP.intPaymentId  
	--FROM  
	--	tblARPaymentDetail ARPD   
	--INNER JOIN   
	--	tblARPayment ARP  
	--		ON ARPD.intPaymentId = ARP.intPaymentId  
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARPD.intInvoiceId = ARI.intInvoiceId
	--INNER JOIN  
	--	@ARReceivablePostData P  
	--		ON ARP.intPaymentId = ARP.intPaymentId
	--WHERE
	--	ISNULL(ARPD.dblPayment,0.00) <> 0.00
	--	AND ARI.strType = 'Service Charge'
	--	AND ARI.ysnForgiven = 1
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
	--SELECT
	--	'Return Payment is not allowed.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A 
	--INNER JOIN 
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId				
	--WHERE
	--	(A.dblAmountPaid) < 0
	--	AND A.ysnInvoicePrepayment = 0
	--	AND A.strPaymentMethod = 'ACH'
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
	--SELECT 
	--	'Unable to find an open fiscal year period to match the transaction date.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId					
	--WHERE
	--	ISNULL([dbo].isOpenAccountingDate(A.dtmDatePaid), 0) = 0
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
	--SELECT 
	--	'Company location of ' + A.strRecordNumber + ' was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--LEFT OUTER JOIN
	--	tblSMCompanyLocation L
	--		ON A.intLocationId = L.intCompanyLocationId
	--WHERE L.intCompanyLocationId IS NULL
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
	--SELECT 
	--	'The Discounts account in Company Configuration was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail D
	--		ON A.intPaymentId = D.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--WHERE
	--	ISNULL(D.dblDiscount,0) <> 0
	--	AND (@DiscountAccount IS NULL OR @DiscountAccount = 0)
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
	--SELECT 
	--	'The Income Interest account in Company Location or Company Configuration was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail D
	--		ON A.intPaymentId = D.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--WHERE
	--	ISNULL(D.dblInterest,0) <> 0
	--	AND (P.intInterestAccountId IS NULL AND (@IncomeInterestAccount IS NULL OR @IncomeInterestAccount = 0))
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
	--SELECT 
	--	'The Write Off account in Company Configuration was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	tblSMPaymentMethod PM
	--		ON A.intPaymentMethodId = PM.intPaymentMethodID
	--		AND ISNULL(A.intWriteOffAccountId, 0) = 0
	--WHERE
	--	(UPPER(RTRIM(LTRIM(PM.strPaymentMethod))) = UPPER('Write Off') OR UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('Write Off'))
	--	AND (@WriteOffAccount IS NULL OR @WriteOffAccount = 0)
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
	--SELECT 
	--	'The CF Invoice Account # in Company Configuration was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	tblSMPaymentMethod PM
	--		ON A.intPaymentMethodId = PM.intPaymentMethodID
	--		AND ISNULL(A.intWriteOffAccountId, 0) = 0
	--WHERE
	--	(UPPER(RTRIM(LTRIM(PM.strPaymentMethod))) = UPPER('CF Invoice') OR UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('CF Invoice'))
	--	AND (@intCFAccount IS NULL OR @intCFAccount = 0)
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
	--SELECT
	--	'The debit and credit amounts are not balanced.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId				
	--WHERE
	--	(A.dblAmountPaid) < (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)
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
	--SELECT 
	--	'Payment Date(' + CONVERT(NVARCHAR(30),A.dtmDatePaid, 101) + ') cannot be earlier than the Invoice(' + C.strInvoiceNumber + ') Post Date(' + CONVERT(NVARCHAR(30),C.dtmPostDate, 101) + ')!'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN tblARInvoice C
	--		ON B.intInvoiceId = C.intInvoiceId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--WHERE
	--	B.dblPayment <> 0
	--	AND CAST(C.dtmPostDate AS DATE) > CAST(A.dtmDatePaid AS DATE)
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
	--SELECT 
	--	'The Accounts Receivable Realized Gain or Loss account in Company Configuration was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPaymentDetail D
	--INNER JOIN
	--	tblARPayment A
	--		ON D.intPaymentId = A.intPaymentId
	--INNER JOIN
	--	tblARInvoice C
	--		ON D.intInvoiceId = C.intInvoiceId 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--WHERE
	--	ISNULL(((((ISNULL(C.dblBaseAmountDue, 0.00) + ISNULL(D.dblBaseInterest,0.00)) - ISNULL(D.dblBaseDiscount,0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - D.dblBasePayment),0) <> 0
	--	AND  (@GainLossAccount IS NULL OR @GainLossAccount = 0)
	--	AND ((C.dblAmountDue + C.dblInterest) - C.dblDiscount) = ((D.dblPayment - D.dblInterest) + D.dblDiscount)	
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
	--SELECT 
	--	'Bank Account is required for payment with ACH payment method!'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--WHERE A.strPaymentMethod = 'ACH' AND ISNULL(intBankAccountId, 0) = 0
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
	--SELECT 
	--	'The Customer Prepaid account in Company Location - ' + CL.strLocationName  + ' was not set.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblSMCompanyLocation CL
	--		ON A.intLocationId = CL.intCompanyLocationId 
	--INNER JOIN
	--	@ARPrepayment P
	--		ON A.intPaymentId = P.intPaymentId						 
	--WHERE
	--	ISNULL(CL.intSalesAdvAcct,0)  = 0
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
	--SELECT 
	--	'The transaction is already posted.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--WHERE
	--	A.ysnPosted = 1
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

    UNION
    --RECEIVABLES(S) ALREADY PAID IN FULL
	--SELECT 
	--	C.strInvoiceNumber + ' already paid in full.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN tblARInvoice C
	--		ON B.intInvoiceId = C.intInvoiceId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--WHERE
	--	C.ysnPaid = 1 
	--	AND B.dblPayment <> 0
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

    UNION
    --over the transaction''s amount due'
	--SELECT 
	--	'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--	tblARInvoice C
	--		ON B.intInvoiceId = C.intInvoiceId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--WHERE
	--	B.dblPayment <> 0 
	--	AND C.ysnPaid = 0 
	--	AND (((C.dblAmountDue + C.dblInterest) - C.dblDiscount) * -1) > ((B.dblPayment - B.dblInterest) + B.dblDiscount)
	--	AND C.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
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
    --over the transaction''s amount due'
	--SELECT 
	--	'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--	tblARInvoice C
	--		ON B.intInvoiceId = C.intInvoiceId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--WHERE
	--	B.dblPayment <> 0 
	--	AND C.ysnPaid = 0 
	--	AND ((C.dblAmountDue + C.dblInterest) - C.dblDiscount) < ((B.dblPayment - B.dblInterest) + B.dblDiscount)
	--	AND C.strTransactionType IN ('Invoice', 'Debit Memo')

	--
	--DECLARE @InvoiceIdsForChecking TABLE (
	--		intInvoiceId int PRIMARY KEY,
	--		UNIQUE (intInvoiceId)
	--	);

	--INSERT INTO @InvoiceIdsForChecking(intInvoiceId)
	--SELECT DISTINCT
	--	PD.intInvoiceId 
	--FROM
	--	tblARPaymentDetail PD 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON PD.intPaymentId = P.intPaymentId
	--WHERE
	--	PD.dblPayment <> 0
	--GROUP BY
	--	PD.intInvoiceId
	--HAVING
	--	COUNT(PD.intInvoiceId) > 1
					
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
	--		dblPayment NUMERIC(18,6)
	--	);
					
	--	INSERT INTO @InvoicePaymentDetail(intPaymentId, intInvoiceId, dblInvoiceTotal, dblAmountDue, dblPayment)
	--	SELECT
	--		 A.intPaymentId
	--		,C.intInvoiceId
	--		,C.dblInvoiceTotal
	--		,C.dblAmountDue
	--		,B.dblPayment 
	--	FROM
	--		tblARPayment A
	--	INNER JOIN
	--		tblARPaymentDetail B
	--			ON A.intPaymentId = B.intPaymentId
	--	INNER JOIN
	--		tblARInvoice C
	--			ON B.intInvoiceId = C.intInvoiceId
	--	INNER JOIN
	--		@ARReceivablePostData P
	--			ON A.intPaymentId = P.intPaymentId
	--	WHERE
	--		C.intInvoiceId = @InvID
							
	--	WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicePaymentDetail)
	--	BEGIN
	--		DECLARE @PayID INT
	--				,@AmountDue NUMERIC(18,6) = 0
	--		SELECT TOP 1 @PayID = intPaymentId, @AmountDue = dblAmountDue, @InvoicePayment = @InvoicePayment + dblPayment FROM @InvoicePaymentDetail ORDER BY intPaymentId
						
	--		IF @AmountDue < @InvoicePayment
	--		BEGIN
	--			INSERT INTO
	--					@ARReceivableInvalidData
	--				SELECT 
	--					'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due'
	--					,'Receivable'
	--					,A.strRecordNumber
	--					,@batchId
	--					,A.intPaymentId
	--				FROM
	--					tblARPayment A
	--				INNER JOIN
	--					tblARPaymentDetail B
	--						ON A.intPaymentId = B.intPaymentId
	--				INNER JOIN
	--					tblARInvoice C
	--						ON B.intInvoiceId = C.intInvoiceId
	--				INNER JOIN
	--					@ARReceivablePostData P
	--						ON A.intPaymentId = P.intPaymentId
	--				WHERE
	--					C.intInvoiceId = @InvID
	--					AND A.intPaymentId = @PayID
	--		END									
	--		DELETE FROM @InvoicePaymentDetail WHERE intPaymentId = @PayID	
	--	END
	--	DELETE FROM @InvoiceIdsForChecking WHERE intInvoiceId = @InvID							
	--END		
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
	--IF (@AllowOtherUserToPost IS NOT NULL AND @AllowOtherUserToPost = 1)
	--BEGIN
	--	INSERT INTO 
	--		@ARReceivableInvalidData
	--	SELECT 
	--		'You cannot Post/Unpost transactions you did not create.'
	--		,'Receivable'
	--		,A.strRecordNumber
	--		,@batchId
	--		,A.intPaymentId
	--	FROM
	--		tblARPayment A
	--	INNER JOIN
	--		tblARPaymentDetail D
	--			ON A.intPaymentId = D.intPaymentId
	--	INNER JOIN
	--		tblSMCompanyLocation CL
	--			ON A.intLocationId = CL.intCompanyLocationId 
	--	INNER JOIN
	--		@ARReceivablePostData P
	--			ON A.intPaymentId = P.intPaymentId						 
	--	WHERE
	--		P.intEntityId <> @UserEntityID
	--END
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
	--SELECT 
	--	'Provisional Invoice(' + I.[strInvoiceNumber] + ') was already processed!' 
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN tblARInvoice I
	--		ON B.intInvoiceId = I.intInvoiceId
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--WHERE
	--	I.strType = 'Provisional'
	--	AND I.ysnProcessed = 1
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
	--IF (@AllowOtherUserToPost IS NOT NULL AND @AllowOtherUserToPost = 1)
	--BEGIN
	--	INSERT INTO 
	--		@ARReceivableInvalidData
	--	SELECT 
	--		'You cannot Post/Unpost transactions you did not create.'
	--		,'Receivable'
	--		,A.strRecordNumber
	--		,@batchId
	--		,A.intPaymentId
	--	FROM
	--		tblARPayment A
	--	INNER JOIN
	--		tblARPaymentDetail D
	--			ON A.intPaymentId = D.intPaymentId
	--	INNER JOIN
	--		tblSMCompanyLocation CL
	--			ON A.intLocationId = CL.intCompanyLocationId 
	--	INNER JOIN
	--		@ARReceivablePostData P
	--			ON A.intPaymentId = P.intPaymentId						 
	--	WHERE
	--		P.intEntityId <> @UserEntityID
	--END
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
	--SELECT 
	--	'Undeposited Funds Account : ' + CL.strUndepositedFundsId+ ' does not exist.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--LEFT OUTER JOIN
	--	tblSMCompanyLocation L
	--		ON A.intLocationId = L.intCompanyLocationId
	--LEFT OUTER JOIN vyuSMCompanyLocation CL
	--	ON L.intCompanyLocationId = CL.intCompanyLocationId
	--LEFT JOIN tblGLAccount GL
	--	ON GL.strAccountId = CL.strUndepositedFundsId
	--WHERE  GL.strAccountId IS NULL AND strUndepositedFundsId != ''
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
	--SELECT 
	--	'Bank Account ' + B.strBankAccountNo + ' is not active.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId						 
	--LEFT OUTER JOIN
	--	tblCMBankAccount B
	--		ON A.intBankAccountId = B.intBankAccountId 
	--WHERE ISNULL(B.ysnActive,0) = 0
	--	AND ISNULL(B.intBankAccountId,0) <> 0
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
	--SELECT 
	--	'The Cash Account is not linked to any of the active Bank Account in Cash Management'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	vyuGLAccountDetail GL
	--		ON A.intAccountId = GL.intAccountId 
	----INNER JOIN 
	----	tblGLAccountGroup AG
	----		ON GL.intAccountGroupId = AG.intAccountGroupId
	----INNER JOIN 
	----	tblGLAccountCategory AC
	----		ON GL.intAccountCategoryId = AC.intAccountCategoryId											 
	--LEFT OUTER JOIN
	--	tblCMBankAccount BA
	--		ON A.intAccountId = BA.intGLAccountId 						
	--WHERE
	--	GL.strAccountCategory = 'Cash Account'
	--	AND (BA.intGLAccountId IS NULL
	--		 OR BA.ysnActive = 0)
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
	--SELECT 
	--	'Discount has been applied to Invoice: ' + I.strInvoiceNumber + '. Payment: ' + P1.strRecordNumber + ' must unposted first!'
	--	,'Receivable'
	--	,P.strRecordNumber
	--	,@batchId
	--	,P.intPaymentId
	--FROM
	--	tblARPaymentDetail PD		
	--INNER JOIN
	--	tblARPayment P
	--		ON PD.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P2
	--		ON P.intPaymentId = P2.intPaymentId	
	--INNER JOIN
	--	tblARInvoice I
	--		ON PD.intInvoiceId = I.intInvoiceId
	--INNER JOIN
	--	(
	--	SELECT
	--		I.intInvoiceId
	--		,P.intPaymentId
	--		,P.strRecordNumber
	--	FROM
	--		tblARPaymentDetail PD		
	--	INNER JOIN	
	--		tblARPayment P ON PD.intPaymentId = P.intPaymentId	
	--	INNER JOIN	
	--		tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
	--	WHERE
	--		PD.dblDiscount <> 0
	--		AND I.dblAmountDue = 0
	--	) AS P1
	--		ON I.intInvoiceId = P1.intInvoiceId AND P.intPaymentId <> P1.intPaymentId
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
	--SELECT 
	--	'Interest has been applied to Invoice: ' + I.strInvoiceNumber + '. Payment: ' + P1.strRecordNumber + ' must unposted first!'
	--	,'Receivable'
	--	,P.strRecordNumber
	--	,@batchId
	--	,P.intPaymentId
	--FROM
	--	tblARPaymentDetail PD		
	--INNER JOIN
	--	tblARPayment P
	--		ON PD.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	@ARReceivablePostData P2
	--		ON P.intPaymentId = P2.intPaymentId	
	--INNER JOIN
	--	tblARInvoice I
	--		ON PD.intInvoiceId = I.intInvoiceId
	--INNER JOIN
	--	(
	--	SELECT
	--		I.intInvoiceId
	--		,P.intPaymentId
	--		,P.strRecordNumber
	--	FROM
	--		tblARPaymentDetail PD		
	--	INNER JOIN	
	--		tblARPayment P ON PD.intPaymentId = P.intPaymentId	
	--	INNER JOIN	
	--		tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
	--	WHERE
	--		ISNULL(PD.dblInterest,0) <> 0
	--		AND I.dblAmountDue = 0
	--	) AS P1
	--		ON I.intInvoiceId = P1.intInvoiceId AND P.intPaymentId <> P1.intPaymentId
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
	--SELECT 
	--	'The transaction is already cleared.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	tblCMBankTransaction B 
	--		ON A.strRecordNumber = B.strTransactionId
	--WHERE B.ysnClr = 1
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
	--SELECT 
	--	'You cannot unpost payment with created Bank Deposit.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	tblCMUndepositedFund B 
	--		ON A.intPaymentId = B.intSourceTransactionId 
	--		AND A.strRecordNumber = B.strSourceTransactionId
	--INNER JOIN
	--	tblCMBankTransactionDetail TD
	--		ON B.intUndepositedFundId = TD.intUndepositedFundId
	--WHERE 
	--	B.strSourceSystem = 'AR'
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
	--SELECT 
	--	'You cannot unpost payment with applied prepaids.'
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	tblARPaymentDetail B
	--		ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--	tblARInvoice I
	--		ON B.intInvoiceId = I.intInvoiceId
	--INNER JOIN
	--	tblARPrepaidAndCredit  PC
	--		ON I.intInvoiceId = PC.intPrepaymentId 
	--		AND PC.ysnApplied = 1
	--		AND PC.dblAppliedInvoiceDetailAmount <> 0
	--INNER JOIN
	--	tblARInvoice I2
	--		ON PC.intInvoiceId = I2.intInvoiceId 
	--		AND I2.ysnPosted = 1
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
	--SELECT 
	--	'There''s an overpayment(' + I.[strInvoiceNumber] + ') created from ' + A.[strRecordNumber] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	tblARInvoice I
	--		ON (A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId)
	--		AND I.strTransactionType = 'Overpayment'
	--INNER JOIN
	--	tblARPaymentDetail ARPD
	--		ON I.[intInvoiceId] = ARPD.[intInvoiceId]
	--		AND A.[intPaymentId] <> ARPD.[intPaymentId]
	--INNER JOIN
	--	tblARPayment ARP
	--		ON ARPD.[intPaymentId] = ARP.[intPaymentId]
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
	--SELECT 
	--	'There''s a prepayment(' + I.[strInvoiceNumber] + ') created from ' + A.[strRecordNumber] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
	--	,'Receivable'
	--	,A.strRecordNumber
	--	,@batchId
	--	,A.intPaymentId
	--FROM
	--	tblARPayment A 
	--INNER JOIN
	--	@ARReceivablePostData P
	--		ON A.intPaymentId = P.intPaymentId
	--INNER JOIN
	--	tblARInvoice I
	--		ON (A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId)
	--		AND I.strTransactionType = 'Customer Prepayment'
	--INNER JOIN
	--	tblARPaymentDetail ARPD
	--		ON I.[intInvoiceId] = ARPD.[intInvoiceId]
	--		AND A.[intPaymentId] <> ARPD.[intPaymentId]
	--INNER JOIN
	--	tblARPayment ARP
	--		ON ARPD.[intPaymentId] = ARP.[intPaymentId]
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
