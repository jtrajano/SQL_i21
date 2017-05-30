CREATE PROCEDURE [dbo].[uspARCollectionOverdueDetailReport]
	@dtmDateFrom		DATETIME = NULL,
	@dtmDateTo			DATETIME = NULL	
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @dtmDateFromLocal			DATETIME = NULL,
		@dtmDateToLocal				DATETIME = NULL	

SET @dtmDateFromLocal			= @dtmDateFrom
SET	@dtmDateToLocal				= @dtmDateTo

IF @dtmDateFromLocal IS NULL
    SET @dtmDateFromLocal = CAST(-53690 AS DATETIME)

IF @dtmDateToLocal IS NULL
    SET @dtmDateToLocal = GETDATE();

WITH ARPOSTEDPAYMENT AS (
	SELECT intPaymentId
		 , dtmDatePaid
		 , dblAmountPaid
		 , ysnInvoicePrepayment
		 , strRecordNumber
	FROM dbo.tblARPayment WITH (NOLOCK)
	WHERE ysnPosted = 1
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
),
INVOICETOTALPAYMENT AS (
	SELECT dblPayment = SUM(dblPayment)
		  , PD.intInvoiceId
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
	GROUP BY PD.intInvoiceId
),
INVOICETOTALPREPAYMENTS AS (
	SELECT dblPayment = SUM(dblPayment)
		  , PD.intInvoiceId
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
	GROUP BY PD.intInvoiceId
),
GLACCOUNTS AS (
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
				WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')
	) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
)

SELECT strCustomerName		= E.strName
	 , strCustomerNumber	= E.strEntityNo
     , strInvoiceNumber		= AGING.strInvoiceNumber
	 , strRecordNumber		= AGING.strRecordNumber
	 , intInvoiceId			= AGING.intInvoiceId
	 , strBOLNumber			= AGING.strBOLNumber
	 , intEntityCustomerId  = AGING.intEntityCustomerId
	 , dblCreditLimit		= C.dblCreditLimit
	 , dblTotalAR			= AGING.dblTotalAR
	 , dblFuture			= AGING.dblFuture
	 , dbl0Days				= AGING.dbl0Days
	 , dbl10Days			= AGING.dbl10Days
	 , dbl30Days			= AGING.dbl30Days
	 , dbl60Days			= AGING.dbl60Days
	 , dbl90Days			= AGING.dbl90Days
	 , dbl120Days           = AGING.dbl120Days
     , dbl121Days           = AGING.dbl121Days
	 , dblTotalDue			= AGING.dblTotalDue
	 , dblAmountPaid		= AGING.dblAmountPaid
	 , dblInvoiceTotal		= AGING.dblInvoiceTotal
	 , dblCredits			= AGING.dblCredits
	 , dblPrepayments		= AGING.dblPrepayments
	 , dblPrepaids			= AGING.dblPrepayments
	 , dtmDate				= AGING.dtmDate
	 , dtmDueDate			= AGING.dtmDueDate
	 , dtmAsOfDate			= @dtmDateToLocal	 
	 , intCompanyLocationId	= AGING.intCompanyLocationId
FROM
(SELECT A.strInvoiceNumber
     , A.strRecordNumber
     , A.intInvoiceId	 
	 , A.strBOLNumber
	 , A.intEntityCustomerId
	 , dblTotalAR			= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
	 , dblFuture			= 0.000000
	 , dbl0Days				= B.dbl0Days
	 , dbl10Days			= B.dbl10Days
	 , dbl30Days			= B.dbl30Days
	 , dbl60Days			= B.dbl60Days
	 , dbl90Days			= B.dbl90Days
	 , dbl120Days			= B.dbl120Days
	 , dbl121Days			= B.dbl121Days
	 , dblTotalDue			= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
	 , dblAmountPaid		= A.dblAmountPaid
	 , dblInvoiceTotal		= A.dblInvoiceTotal
	 , dblCredits			= B.dblAvailableCredit * -1
	 , dblPrepayments		= B.dblPrepayments * -1	 
	 , dtmDate				= ISNULL(B.dtmDatePaid, A.dtmDate)
	 , dtmDueDate	 
	 , intCompanyLocationId	 
FROM
(SELECT dtmDate				= I.dtmPostDate
	 , I.strInvoiceNumber
	 , strRecordNumber		= NULL
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , intPaymentId			= 0
	 , I.strBOLNumber
	 , dblAmountPaid		= 0
     , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal,0)
	 , dblAmountDue			= ISNULL(I.dblAmountDue,0)
	 , dblDiscount			= 0
	 , dblInterest			= 0
	 , I.strTransactionType    
	 , I.intEntityCustomerId
	 , I.dtmDueDate    
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
                     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
	, dblAvailableCredit = 0
	, dblPrepayments     = 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
WHERE I.ysnPosted = 1
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
  AND I.strTransactionType IN ('Invoice', 'Debit Memo')
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal  
  AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)

UNION ALL
						
SELECT dtmDate				= ISNULL(P.dtmDatePaid, I.dtmPostDate)
	 , I.strInvoiceNumber
	 , P.strRecordNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , intPaymentId			= 0
	 , I.strBOLNumber
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
	 , dblAmountDue			= 0    
	 , dblDiscount			= 0
	 , dblInterest			= 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 120 THEN '91 - 120 Days'  
                     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 120 THEN 'Over 120' END
	 , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN INVOICETOTALPAYMENT PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT intPrepaymentId
		            , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			   WHERE ysnApplied = 1
			   GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId	
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.dblInvoiceTotal - (ISNULL(PD.dblPayment, 0) + ISNULL(PC.dblAppliedInvoiceAmount, 0)) <> 0  
 AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)

UNION ALL
						
SELECT dtmDate				= ISNULL(P.dtmDatePaid, I.dtmPostDate)
	 , I.strInvoiceNumber
	 , P.strRecordNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , intPaymentId			= 0
	 , I.strBOLNumber
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
	 , dblAmountDue			= 0    
	 , dblDiscount			= 0
	 , dblInterest			= 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 120 THEN '91 - 120 Days'  
                     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 120 THEN 'Over 120' END
	 , dblAvailableCredit	= 0
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT intPrepaymentId
		            , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			WHERE ysnApplied = 1
			GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId 
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType = 'Customer Prepayment'
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
 AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
      
UNION ALL

SELECT P.dtmDatePaid
     , I.strInvoiceNumber
     , P.strRecordNumber
     , I.intCompanyLocationId
     , I.intInvoiceId
     , intPaymentId				= 0
     , I.strBOLNumber
     , dblAmountPaid			= 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , dblInterest              = 0
     , I.strTransactionType           
     , I.intEntityCustomerId
     , dtmDueDate               = P.dtmDatePaid
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 120 THEN 'Over 120' END
     , dblAvailableCredit       = ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM dbo.tblARPayment P WITH (NOLOCK)
    INNER JOIN (SELECT intPaymentId 
					 , intInvoiceId
	                 , dblPayment
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	) PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN (SELECT intInvoiceId
					, intEntityCustomerId
					, intEntitySalespersonId
					, strInvoiceNumber
					, intCompanyLocationId
					, strTransactionType
					, strBOLNumber
					, dtmPostDate
			   FROM dbo.tblARInvoice WITH (NOLOCK)
			   WHERE ysnPosted = 1 
				AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) > @dtmDateToLocal
				AND intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	) I ON PD.intInvoiceId = I.intInvoiceId				
	   AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

UNION ALL      
      
SELECT DISTINCT
       dtmDate				= I.dtmPostDate      
     , I.strInvoiceNumber
	 , strRecordNumber      = ISNULL(ISNULL(P.strRecordNumber, PC.strInvoiceNumber), APP.strPaymentRecordNum)
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , intPaymentId			= ISNULL(ISNULL(P.intPaymentId, PC.intPrepaymentId), APP.intPaymentId)
	 , I.strBOLNumber	 
	 , dblAmountPaid		= (CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') 
								THEN 
									CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 
										THEN ISNULL(PD.dblPayment, 0) + ISNULL(APPD.dblPayment, 0) 
										ELSE 0 
									END 
								ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) 
							  END) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
     , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
								THEN I.dblInvoiceTotal * -1 
								ELSE 
									CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) < 0
										THEN ISNULL(PD.dblInvoiceTotal, 0)
										ELSE 0
									END
							  END
	 , I.dblAmountDue     
	 , dblDiscount			= ISNULL(I.dblDiscount, 0)
	 , dblInterest			= ISNULL(I.dblInterest, 0)
	 , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
	 , I.intEntityCustomerId
	 , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
                     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
	 , dblAvailableCredit	= 0 
	 , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	 LEFT JOIN ((SELECT intPaymentId
	                  , intInvoiceId
					  , dblPayment
					  , dblInvoiceTotal
				 FROM dbo.tblARPaymentDetail WITH (NOLOCK)
				 ) PD INNER JOIN ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN ((SELECT intPaymentId
					  , intInvoiceId
					  , dblPayment
				 FROM dbo.tblAPPaymentDetail WITH (NOLOCK)
				 ) APPD INNER JOIN (SELECT intPaymentId
				                         , strPaymentRecordNum
										 , dblAmountPaid
									FROM dbo.tblAPPayment WITH (NOLOCK)
									WHERE ysnPosted = 1 
									  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	 ) APP ON APPD.intPaymentId = APP.intPaymentId) ON I.intInvoiceId = APPD.intInvoiceId
	 LEFT JOIN (SELECT PC.intInvoiceId
		             , I.strInvoiceNumber
			         , PC.intPrepaymentId
		             , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
				FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) INNER JOIN (SELECT intInvoiceId
																				 , strInvoiceNumber
																			FROM dbo.tblARInvoice WITH (NOLOCK)
																			) I ON I.intInvoiceId = PC.intPrepaymentId
				WHERE ysnApplied = 1
				GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber
	 ) PC ON I.intInvoiceId = PC.intInvoiceId
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal 
 ) AS A    

LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
  , strInvoiceNumber
  , intInvoiceId
  , intPaymentId  
  , strBOLNumber
  , dblInvoiceTotal
  , dblAmountPaid
  , dtmDatePaid
  , (dblInvoiceTotal) - (dblAmountPaid) - (dblDiscount) + (dblInterest) AS dblTotalDue
  , dblDiscount
  , dblInterest
  , dblAvailableCredit
  , dblPrepayments  
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 0
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl0Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 10
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 30
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 60    
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 90     
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl90Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 120     
              THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl120Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 120      
              THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl121Days
FROM
(SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , intPaymentId		= 0
	  , I.strBOLNumber
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= ISNULL(dblInvoiceTotal,0)
	  , dblAmountDue		= 0    
	  , dblDiscount			= 0
	  , dblInterest			= 0   
	  , I.dtmDueDate
	  , dtmDatePaid			= NULL
	  , I.intEntityCustomerId
	  , dblAvailableCredit	= 0
	  , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Invoice', 'Debit Memo')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)

UNION ALL

SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , intPaymentId		= 0
	  , I.strBOLNumber
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= 0
	  , dblAmountDue		= 0    
	  , dblDiscount			= 0
	  , dblInterest			= 0    
	  , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	  , dtmDatePaid			= NULL
	  , I.intEntityCustomerId
	  , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	  , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN INVOICETOTALPAYMENT PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT intPrepaymentId
		            , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			   WHERE ysnApplied = 1
			   GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.dblInvoiceTotal - (ISNULL(PD.dblPayment, 0) + ISNULL(PC.dblAppliedInvoiceAmount, 0)) <> 0 
 AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)

UNION ALL

SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , intPaymentId		= 0
	  , I.strBOLNumber
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= 0
	  , dblAmountDue		= 0    
	  , dblDiscount			= 0
	  , dblInterest			= 0    
	  , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	  , dtmDatePaid			= NULL
	  , I.intEntityCustomerId
	  , dblAvailableCredit	= 0
	  , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT intPrepaymentId
		            , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			   WHERE ysnApplied = 1
			   GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId 
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType = 'Customer Prepayment'
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
 AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
						      
UNION ALL

SELECT I.strInvoiceNumber
     , I.intInvoiceId
     , intPaymentId             = 0
     , I.strBOLNumber
     , dblAmountPaid            = 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , dblInterest              = 0     
     , dtmDueDate               = P.dtmDatePaid
     , dtmDatePaid				= P.dtmDatePaid
     , I.intEntityCustomerId
     , dblAvailableCredit		= ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM dbo.tblARPayment P WITH (NOLOCK)
    LEFT JOIN (SELECT intPaymentId
					 , intInvoiceId
					 , dblPayment
			    FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	) PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN (SELECT intInvoiceId
					, intEntityCustomerId
					, intEntitySalespersonId
					, dtmPostDate
					, strInvoiceNumber
					, strBOLNumber
			   FROM dbo.tblARInvoice WITH (NOLOCK)
			   WHERE ysnPosted = 1
				AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) > @dtmDateToLocal
				AND intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	) I ON PD.intInvoiceId = I.intInvoiceId
	   AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
WHERE P.ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

UNION ALL      
      
SELECT DISTINCT
    I.strInvoiceNumber
  , I.intInvoiceId
  , intPaymentId		= ISNULL(ISNULL(P.intPaymentId, PC.intPrepaymentId), APP.intPaymentId)
  , I.strBOLNumber
  , dblAmountPaid		= (CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') 
							THEN 
								CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 
									THEN ISNULL(PD.dblPayment, 0) + ISNULL(APPD.dblPayment, 0) 
									ELSE 0 
								END 
							ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) 
						  END) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
  , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
							THEN I.dblInvoiceTotal * -1 
							ELSE 
								CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) < 0
									THEN ISNULL(PD.dblInvoiceTotal, 0)
									ELSE 0
								END
						  END
  , dblAmountDue		= 0
  , dblDiscount			= ISNULL(PD.dblDiscount, 0) + ISNULL(APPD.dblDiscount, 0)
  , dblInterest			= ISNULL(PD.dblInterest, 0) + ISNULL(APPD.dblInterest, 0)
  , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
  , dtmDatePaid			= ISNULL(ISNULL(P.dtmDatePaid, I.dtmPostDate), APP.dtmDatePaid)
  , I.intEntityCustomerId
  , dblAvailableCredit	= 0
  , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN ((SELECT intPaymentId
	                  , intInvoiceId
					  , dblPayment
					  , dblInvoiceTotal
					  , dblDiscount
					  , dblInterest
				 FROM dbo.tblARPaymentDetail WITH (NOLOCK)
				 ) PD INNER JOIN ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId ) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN ((SELECT intPaymentId
					  , intInvoiceId
					  , dblPayment
					  , dblDiscount
					  , dblInterest
				 FROM dbo.tblAPPaymentDetail WITH (NOLOCK)
				 ) APPD INNER JOIN (SELECT intPaymentId
				                         , strPaymentRecordNum
										 , dblAmountPaid
										 , dtmDatePaid
									FROM dbo.tblAPPayment WITH (NOLOCK)
									WHERE ysnPosted = 1 
									  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	 ) APP ON APPD.intPaymentId = APP.intPaymentId) ON I.intInvoiceId = APPD.intInvoiceId
	LEFT JOIN (SELECT PC.intInvoiceId
		            , I.strInvoiceNumber
			        , PC.intPrepaymentId
		            , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) INNER JOIN (SELECT intInvoiceId 
																				, strInvoiceNumber
																		   FROM dbo.tblARInvoice WITH (NOLOCK)
																		   ) I ON I.intInvoiceId = PC.intPrepaymentId
			   WHERE ysnApplied = 1
			   GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber
	) PC ON I.intInvoiceId = PC.intInvoiceId
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 ) AS TBL) AS B    

ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
AND A.dblInvoiceTotal	 = B.dblInvoiceTotal
AND A.dblAmountPaid		 = B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
AND A.dblPrepayments	 = B.dblPrepayments 
AND A.intPaymentId		 = B.intPaymentId

WHERE B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments <> 0) AS AGING

LEFT JOIN (SELECT intEntityId
				 , dblCreditLimit 
			FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON AGING.intEntityCustomerId = C.intEntityId
LEFT JOIN (SELECT intEntityId
			     , strName
				 , strEntityNo 
			FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON C.intEntityId = E.intEntityId
