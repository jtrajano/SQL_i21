CREATE FUNCTION [dbo].[fnARCustomerAgingReport]
( 
	 @dtmDateFrom					DATETIME		= NULL
	,@dtmDateTo						DATETIME		= NULL
	,@intEntityCustomerId			INT				= NULL
)
RETURNS @returntable TABLE (
	  strCustomerName		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strCustomerNumber		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strCustomerInfo		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, intEntityCustomerId	INT NULL
	, dblCreditLimit		NUMERIC(18, 6) NULL
	, dblTotalAR			NUMERIC(18, 6) NULL
	, dblTotalCustomerAR	NUMERIC(18, 6) NULL
	, dblFuture				NUMERIC(18, 6) NULL
	, dbl0Days				NUMERIC(18, 6) NULL
	, dbl10Days				NUMERIC(18, 6) NULL
	, dbl30Days				NUMERIC(18, 6) NULL
	, dbl60Days				NUMERIC(18, 6) NULL
	, dbl90Days				NUMERIC(18, 6) NULL
	, dbl91Days				NUMERIC(18, 6) NULL
	, dblTotalDue			NUMERIC(18, 6) NULL
	, dblAmountPaid			NUMERIC(18, 6) NULL
	, dblCredits			NUMERIC(18, 6) NULL
	, dblPrepayments		NUMERIC(18, 6) NULL
	, dblPrepaids			NUMERIC(18, 6) NULL
)
AS
BEGIN
	DECLARE @ysnIncludeCredits	BIT = 1
	SET @dtmDateFrom	= CAST(ISNULL(@dtmDateFrom, '01/01/1900') AS DATE)
	SET @dtmDateTo		= CAST(ISNULL(@dtmDateTo, GETDATE()) AS DATE)

	DECLARE @CUSTOMERS AS TABLE (
		  intEntityCustomerId	INT	  
		, strCustomerNumber		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, strCustomerName		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, dblCreditLimit		NUMERIC(18, 6) NULL
	)

	DECLARE @ARPOSTEDPAYMENT AS TABLE (
		  intPaymentId			INT
		, intPaymentMethodId	INT				NULL
		, dtmDatePaid			DATETIME		NULL
		, dblAmountPaid			NUMERIC(18, 6)	NULL
		, ysnInvoicePrepayment	BIT				NULL
	)

	DECLARE @INVOICETOTALPREPAYMENTS AS TABLE (
		  intInvoiceId			INT
		, dblPayment			NUMERIC(18, 6)	NULL
	)

	DECLARE @APPAYMENTDETAILS AS TABLE (
		  intPaymentId			INT
		, intInvoiceId			INT
		, dblDiscount			NUMERIC(18, 6)	NULL
		, dblPayment			NUMERIC(18, 6)	NULL
		, dblInterest			NUMERIC(18, 6)	NULL
		, dblAmountPaid			NUMERIC(18, 6)	NULL
	)

	DECLARE @POSTEDINVOICES AS TABLE (
		  intInvoiceId				INT
		, intPaymentId				INT				NULL
		, intEntityCustomerId		INT				NULL
		, intEntitySalespersonId	INT				NULL
		, intCompanyLocationId		INT				NULL
		, dtmPostDate				DATETIME		NULL
		, dtmDueDate				DATETIME		NULL
		, dtmForgiveDate			DATETIME		NULL
		, strTransactionType		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, strType					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, strInvoiceNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, dblInvoiceTotal			NUMERIC(18, 6)	NULL
		, dblAmountDue				NUMERIC(18, 6)	NULL
		, dblDiscount				NUMERIC(18, 6)	NULL
		, dblInterest				NUMERIC(18, 6)	NULL
		, ysnForgiven				BIT				NULL
	)

	DECLARE @CASHREFUNDS AS TABLE (
		  strDocumentNumber		NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblRefundTotal		NUMERIC(18, 6)	NULL
	)

	DECLARE @CASHRETURNS AS TABLE (
		  intInvoiceId			INT
		, intOriginalInvoiceId	INT				NULL
		, dblInvoiceTotal		NUMERIC(18, 6)	NULL
		, strInvoiceOriginId	NVARCHAR(200) COLLATE Latin1_General_CI_AS
	)

	--@CUSTOMERS
	INSERT INTO @CUSTOMERS
	SELECT intEntityCustomerId	= C.intEntityId 
		 , strCustomerNumber	= C.strCustomerNumber
		 , strCustomerName		= EC.strName
		 , dblCreditLimit		= C.dblCreditLimit
	FROM tblARCustomer C WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) EC ON C.intEntityId = EC.intEntityId
	WHERE ISNULL(@intEntityCustomerId, 0) = 0 OR C.intEntityId = @intEntityCustomerId

	--@ARPOSTEDPAYMENT
	INSERT INTO @ARPOSTEDPAYMENT
	SELECT intPaymentId
		 , intPaymentMethodId
		 , dtmDatePaid
		 , dblAmountPaid
		 , ysnInvoicePrepayment
	FROM dbo.tblARPayment P WITH (NOLOCK)
	INNER JOIN @CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
	WHERE ysnPosted = 1
		AND ysnProcessedToNSF = 0
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
		
	--@INVOICETOTALPREPAYMENTS
	INSERT INTO @INVOICETOTALPREPAYMENTS
	SELECT intInvoiceId	= PD.intInvoiceId
		 --, dblPayment	= SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
		 , dblPayment	= SUM(dblPayment)
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
	INNER JOIN @ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
	GROUP BY PD.intInvoiceId

	--@APPAYMENTDETAILS
	INSERT INTO @APPAYMENTDETAILS
	SELECT intPaymentId		= APPD.intPaymentId
		 , intInvoiceId		= APPD.intInvoiceId
		 , dblDiscount		= APPD.dblDiscount
		 , dblPayment		= APPD.dblPayment
		 , dblInterest		= APPD.dblInterest
		 , dblAmountPaid	= APP.dblAmountPaid
	FROM dbo.tblAPPaymentDetail APPD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , dblAmountPaid
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
	) APP ON APPD.intPaymentId = APP.intPaymentId
	WHERE intInvoiceId IS NOT NULL

	--@POSTEDINVOICES
	INSERT INTO @POSTEDINVOICES
	SELECT intInvoiceId				= I.intInvoiceId
		 , intPaymentId				= I.intPaymentId
		 , intEntityCustomerId		= I.intEntityCustomerId
		 , intEntitySalespersonId	= I.intEntitySalespersonId
		 , intCompanyLocationId		= I.intCompanyLocationId
		 , dtmPostDate				= I.dtmPostDate
		 , dtmDueDate				= I.dtmDueDate
		 , dtmForgiveDate			= I.dtmForgiveDate
		 , strTransactionType		= I.strTransactionType
		 , strType					= I.strType
		 , strInvoiceNumber			= I.strInvoiceNumber
		 , dblInvoiceTotal			= I.dblInvoiceTotal
		 , dblAmountDue				= I.dblAmountDue
		 , dblDiscount				= I.dblDiscount
		 , dblInterest				= I.dblInterest
		 , ysnForgiven				= I.ysnForgiven
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN @CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	WHERE ysnPosted = 1
		AND ysnCancelled = 0	
		AND strTransactionType <> 'Cash Refund'
		AND ((I.strType = 'Service Charge' AND (0 = 0 AND @dtmDateTo < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmForgiveDate))))) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
		AND I.intAccountId IN (
			SELECT A.intAccountId
			FROM dbo.tblGLAccount A WITH (NOLOCK)
			INNER JOIN (SELECT intAccountSegmentId
							 , intAccountId
						FROM dbo.tblGLAccountSegmentMapping WITH (NOLOCK)
			) ASM ON A.intAccountId = ASM.intAccountId
			INNER JOIN (SELECT intAccountSegmentId
							 , intAccountCategoryId
							 , intAccountStructureId
						FROM dbo.tblGLAccountSegment WITH (NOLOCK)
			) GLAS ON ASM.intAccountSegmentId = GLAS.intAccountSegmentId
			INNER JOIN (SELECT intAccountStructureId                 
						FROM dbo.tblGLAccountStructure WITH (NOLOCK)
						WHERE strType = 'Primary'
			) AST ON GLAS.intAccountStructureId = AST.intAccountStructureId
			INNER JOIN (SELECT intAccountCategoryId
							 , strAccountCategory 
						FROM dbo.tblGLAccountCategory WITH (NOLOCK)
						WHERE (strAccountCategory IN ('AR Account', 'Customer Prepayments') OR (I.strTransactionType = 'Cash Refund' AND strAccountCategory = 'AP Account'))
			) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
		)
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo		

	--@CASHREFUNDS
	INSERT INTO @CASHREFUNDS
	SELECT strDocumentNumber	= ID.strDocumentNumber
		 , dblRefundTotal		= SUM(I.dblInvoiceTotal) 
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN @CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
	WHERE I.strTransactionType = 'Cash Refund'
		AND I.ysnPosted = 1
		AND ISNULL(ID.strDocumentNumber, '') <> ''
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
	GROUP BY ID.strDocumentNumber

	--@CASHRETURNS
	INSERT INTO @CASHRETURNS
	SELECT intInvoiceId			= I.intInvoiceId
		 , intOriginalInvoiceId	= I.intOriginalInvoiceId
		 , dblInvoiceTotal		= I.dblInvoiceTotal
		 , strInvoiceOriginId	= I.strInvoiceOriginId
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	WHERE ysnPosted = 1
		AND ysnRefundProcessed = 1
		AND strTransactionType = 'Credit Memo'
		AND intOriginalInvoiceId IS NOT NULL
		AND ISNULL(strInvoiceOriginId, '') <> ''
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
		
	INSERT INTO @returntable (
		   strCustomerName
	     , strCustomerNumber
	     , strCustomerInfo
	     , intEntityCustomerId
	     , dblCreditLimit
	     , dblTotalAR
	     , dblTotalCustomerAR
	     , dblFuture
	     , dbl0Days
	     , dbl10Days
	     , dbl30Days
	     , dbl60Days
	     , dbl90Days
	     , dbl91Days
	     , dblTotalDue
	     , dblAmountPaid
	     , dblCredits
	     , dblPrepayments
	     , dblPrepaids
	)
	SELECT strCustomerName		= CUSTOMER.strCustomerName
		 , strCustomerNumber	= CUSTOMER.strCustomerNumber
		 , strCustomerInfo		= CUSTOMER.strCustomerName + ' ' + CUSTOMER.strCustomerNumber
		 , intEntityCustomerId	= AGING.intEntityCustomerId
		 , dblCreditLimit		= CUSTOMER.dblCreditLimit
		 , dblTotalAR			= AGING.dblTotalAR
		 , dblTotalCustomerAR	= AGING.dblTotalAR
		 , dblFuture			= AGING.dblFuture
		 , dbl0Days				= AGING.dbl0Days
		 , dbl10Days            = AGING.dbl10Days
		 , dbl30Days            = AGING.dbl30Days
		 , dbl60Days            = AGING.dbl60Days
		 , dbl90Days            = AGING.dbl90Days
		 , dbl91Days            = AGING.dbl91Days
		 , dblTotalDue          = AGING.dblTotalDue
		 , dblAmountPaid        = AGING.dblAmountPaid
		 , dblCredits           = AGING.dblCredits
		 , dblPrepayments		= AGING.dblPrepayments
		 , dblPrepaids          = AGING.dblPrepayments
	FROM
	(SELECT A.intEntityCustomerId
		 , dblTotalAR           = SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
		 , dblFuture            = SUM(B.dblFuture)
		 , dbl0Days				= SUM(B.dbl0Days)
		 , dbl10Days            = SUM(B.dbl10Days)
		 , dbl30Days            = SUM(B.dbl30Days)
		 , dbl60Days            = SUM(B.dbl60Days)
		 , dbl90Days            = SUM(B.dbl90Days)
		 , dbl91Days            = SUM(B.dbl91Days)
		 , dblTotalDue          = SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
		 , dblAmountPaid        = SUM(B.dblAmountPaid)
		 , dblCredits           = SUM(B.dblAvailableCredit) * -1
		 , dblPrepayments		= SUM(B.dblPrepayments) * -1     
	FROM

	(SELECT I.intInvoiceId
		  , I.intEntityCustomerId
		  , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
					 ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 0 THEN 'Current'
	    					   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 10 THEN '1 - 10 Days'
	    					   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 30 THEN '11 - 30 Days'
	    					   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 60 THEN '31 - 60 Days'
	    					   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 90 THEN '61 - 90 Days'
	    					   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 90 THEN 'Over 90' END
					 END
	FROM @POSTEDINVOICES I
	WHERE ((@ysnIncludeCredits = 0 AND strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')) OR (@ysnIncludeCredits = 1))

	) AS A  


	LEFT JOIN
          
	(SELECT DISTINCT 
		  intEntityCustomerId
		, intInvoiceId  
		, dblAmountPaid
		, dblTotalDue	= dblInvoiceTotal - dblAmountPaid
		, dblAvailableCredit
		, dblPrepayments
		, CASE WHEN strType = 'CF Tran' 
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dblFuture
		, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 0 AND strType <> 'CF Tran'
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl0Days
		, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 0  AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 10 AND strType <> 'CF Tran'
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl10Days
		, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 30 AND strType <> 'CF Tran'
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl30Days
		, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 60 AND strType <> 'CF Tran'
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl60Days
		, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 90 AND strType <> 'CF Tran'
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl90Days
		, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 90 AND strType <> 'CF Tran'
				THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl91Days
	FROM
	(SELECT I.intInvoiceId
		  , dblAmountPaid		= 0
		  , dblInvoiceTotal		= ISNULL(dblInvoiceTotal,0)
		  , dblAmountDue		= 0    
		  , I.dtmDueDate    
		  , I.intEntityCustomerId
		  , dblAvailableCredit	= 0
		  , dblPrepayments		= 0
		  , I.strType
	FROM @POSTEDINVOICES I
	WHERE I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')

	UNION ALL

	SELECT I.intInvoiceId
		 , dblAmountPaid		= 0
		 , dblInvoiceTotal		= CASE WHEN I.strType = 'CF Tran' THEN (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1 ELSE 0 END
		 , dblAmountDue			= 0    
		 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
		 , I.intEntityCustomerId
		 , dblAvailableCredit	= CASE WHEN I.strType = 'CF Tran' THEN 0 ELSE ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0) END
		 , dblPrepayments		= 0
		 , I.strType
	FROM @POSTEDINVOICES I
		LEFT JOIN @ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
		LEFT JOIN (
			--SELECT dblPayment = SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
			SELECT dblPayment = SUM(dblPayment)
				 , PD.intInvoiceId
			FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN @ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
			GROUP BY PD.intInvoiceId
		) PD ON I.intInvoiceId = PD.intInvoiceId
		LEFT JOIN @CASHREFUNDS CR ON I.strInvoiceNumber = CR.strDocumentNumber AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
	WHERE ((@ysnIncludeCredits = 1 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')) OR (@ysnIncludeCredits = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo    		

	UNION ALL

	SELECT I.intInvoiceId
		 , dblAmountPaid		= 0
		 , dblInvoiceTotal		= 0
		 , dblAmountDue			= 0    
		 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
		 , I.intEntityCustomerId
		 , dblAvailableCredit	= 0
		 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
		 , I.strType
	FROM @POSTEDINVOICES I
		INNER JOIN @ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
		LEFT JOIN @INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
		LEFT JOIN @CASHREFUNDS CR ON I.strInvoiceNumber = CR.strDocumentNumber AND I.strTransactionType = 'Customer Prepayment'
	WHERE ((@ysnIncludeCredits = 1 AND I.strTransactionType = 'Customer Prepayment') OR (@ysnIncludeCredits = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))    
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo    		
	                                          
	UNION ALL
            
	SELECT I.intInvoiceId
		, dblAmountPaid			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) END
		, dblInvoiceTotal		= 0
		, dblAmountDue			= 0
		, dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
		, I.intEntityCustomerId
		, dblAvailableCredit	= 0
		, dblPrepayments		= 0
		, I.strType
	FROM @POSTEDINVOICES I
	LEFT JOIN (
		SELECT PD.intInvoiceId
			 --, dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) + SUM(ISNULL(dblWriteOffAmount, 0)) - SUM(ISNULL(dblInterest, 0))
			 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN @ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId
		GROUP BY PD.intInvoiceId

		UNION ALL 

		SELECT PD.intInvoiceId
			 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))
		FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
			FROM dbo.tblAPPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
		) P ON PD.intPaymentId = P.intPaymentId
		GROUP BY PD.intInvoiceId

		UNION ALL

		SELECT intInvoiceId			= intOriginalInvoiceId
			 , dblTotalPayment		= dblInvoiceTotal
		FROM @CASHRETURNS
	) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
	WHERE ((@ysnIncludeCredits = 0 AND strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')) OR (@ysnIncludeCredits = 1))

	) AS TBL) AS B
          
	ON
	A.intEntityCustomerId	 = B.intEntityCustomerId
	AND A.intInvoiceId		 = B.intInvoiceId

	GROUP BY A.intEntityCustomerId) AS AGING
	INNER JOIN @CUSTOMERS CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId	
	ORDER BY strCustomerName
	
	RETURN
			
END