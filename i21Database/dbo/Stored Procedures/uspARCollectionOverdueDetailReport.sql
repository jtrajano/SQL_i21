CREATE PROCEDURE [dbo].[uspARCollectionOverdueDetailReport]
	@dtmDateFrom		DATETIME = NULL,
	@dtmDateTo			DATETIME = NULL,
	@strSalesperson		NVARCHAR(100) = NULL
	
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @dtmDateFromLocal			DATETIME,  
		@dtmDateToLocal				DATETIME,  
		@strSalespersonLocal		NVARCHAR(100)  
				
SET @dtmDateFromLocal			= @dtmDateFrom
SET	@dtmDateToLocal				= @dtmDateTo
SET @strSalespersonLocal		= @strSalesperson

IF @dtmDateFromLocal IS NULL
    SET @dtmDateFromLocal = CAST(-53690 AS DATETIME)

IF @dtmDateToLocal IS NULL
    SET @dtmDateToLocal = GETDATE()

IF RTRIM(LTRIM(@strSalespersonLocal)) = ''
    SET @strSalespersonLocal = NULL

SET NOCOUNT ON;
SELECT A.strInvoiceNumber
     , A.strRecordNumber
     , A.intInvoiceId
	 , A.strCustomerName
	 , A.strBOLNumber
	 , A.intEntityCustomerId
	 , A.strCustomerNumber
	 , dblCreditLimit		= (SELECT dblCreditLimit FROM tblARCustomer WITH (NOLOCK) WHERE intEntityCustomerId = A.intEntityCustomerId)
	 , dblTotalAR			= B.dblTotalDue - B.dblAvailableCredit
	 , dblFuture			= 0.000000
	 , dbl0Days				= B.dbl0Days
	 , dbl10Days			= B.dbl10Days
	 , dbl30Days			= B.dbl30Days
	 , dbl60Days			= B.dbl60Days
	 , dbl90Days			= B.dbl90Days
	 , dbl120Days			= B.dbl120Days
	 , dbl121Days			= B.dbl121Days
	 , dblTotalDue			= B.dblTotalDue - B.dblAvailableCredit
	 , dblAmountPaid		= A.dblAmountPaid
	 , dblInvoiceTotal		= A.dblInvoiceTotal
	 , dblCredits			= B.dblAvailableCredit * -1
	 , dblPrepaids			= 0.000000
	 , dtmDate				= ISNULL(B.dtmDatePaid, A.dtmDate)
	 , dtmDueDate	 
	 , dtmAsOfDate			= @dtmDateToLocal
	 , strSalespersonName	= 'strSalespersonName'
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
	 , I.intTermId
	 , T.intBalanceDue    
     , strCustomerName		= E.strName
	 , strCustomerNumber	= C.strCustomerNumber
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
	, I.ysnPosted
	, dblAvailableCredit = 0
FROM (SELECT 
			intInvoiceId, strInvoiceNumber, dtmPostDate, intEntityCustomerId, intEntitySalespersonId, dtmDueDate, strTransactionType, intCompanyLocationId, strBOLNumber, intTermId, dblInvoiceTotal, dblAmountDue, ysnPosted 
      FROM 
		tblARInvoice WITH (NOLOCK)
	  WHERE ysnPosted = 1 
			AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
			AND strTransactionType IN ('Invoice', 'Debit Memo')
			AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) I
	INNER JOIN (SELECT intEntityCustomerId, strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId 
	INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity WITH (NOLOCK)) E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN (SELECT intTermID, intBalanceDue FROM tblSMTerm WITH (NOLOCK)) T ON T.intTermID = I.intTermId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment, dblDiscount, dblInterest FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson WITH (NOLOCK)) SP 
	           INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity WITH (NOLOCK) WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')) ES ON SP.intEntitySalespersonId = ES.intEntityId
	           ) ON I.intEntitySalespersonId = SP.intEntitySalespersonId    
WHERE I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0
   
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
	 , I.intTermId
	 , T.intBalanceDue
	 , strCustomerName		= E.strName
	 , strCustomerNumber	= C.strCustomerNumber
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 120 THEN '91 - 120 Days'  
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 120 THEN 'Over 120' END
	 , I.ysnPosted
	 , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
FROM 
	(SELECT 
			intInvoiceId, strInvoiceNumber, dtmPostDate, intEntityCustomerId, intEntitySalespersonId, dtmDueDate, strTransactionType, intCompanyLocationId, strBOLNumber, intTermId, dblInvoiceTotal, dblAmountDue, ysnPosted
			, intPaymentId 
		  FROM 
			tblARInvoice WITH (NOLOCK)
		  WHERE ysnPosted = 1 
				AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
				AND strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
				AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) I	
	INNER JOIN (SELECT intEntityCustomerId, strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId 
	INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity WITH (NOLOCK)) E ON E.intEntityId = C.intEntityCustomerId	
	INNER JOIN (SELECT intTermID, intBalanceDue FROM tblSMTerm WITH (NOLOCK)) T ON T.intTermID = I.intTermId
	LEFT JOIN (SELECT intPaymentId, strRecordNumber, dtmDatePaid FROM tblARPayment WITH (NOLOCK)
			  WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) P ON I.intPaymentId = P.intPaymentId 
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId	
	LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson WITH (NOLOCK)) SP 
	           INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity WITH (NOLOCK) WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')) ES ON SP.intEntitySalespersonId = ES.intEntityId
	           ) ON I.intEntitySalespersonId = SP.intEntitySalespersonId  
WHERE I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
  
      
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
     , I.intTermId
     , T.intBalanceDue
     , strCustomerName          = E.strName
     , strCustomerNumber		= C.strCustomerNumber
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
					  WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 120 THEN '91 - 120 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 120 THEN 'Over 120' END
     , I.ysnPosted
     , dblAvailableCredit        = ISNULL(PD.dblPayment, 0)
FROM (SELECT intPaymentId, strRecordNumber, dtmDatePaid 
	  FROM 
		tblARPayment WITH (NOLOCK)
	  WHERE ysnPosted = 1 
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) P
    INNER JOIN (SELECT intPaymentId, intInvoiceId, dblPayment FROM tblARPaymentDetail WITH (NOLOCK)) PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN (SELECT intInvoiceId, strInvoiceNumber, dtmPostDate, intCompanyLocationId, strTransactionType, strBOLNumber, intEntityCustomerId, intTermId, ysnPosted, dblInvoiceTotal, intEntitySalespersonId 
			   FROM tblARInvoice WITH (NOLOCK)
	           WHERE ysnPosted = 1 
				AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) > @dtmDateToLocal				
				AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) I ON PD.intInvoiceId = I.intInvoiceId				
    INNER JOIN (SELECT intEntityCustomerId, strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId
    INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity WITH (NOLOCK)) E ON E.intEntityId = C.intEntityCustomerId
    INNER JOIN (SELECT intTermID, intBalanceDue FROM tblSMTerm WITH (NOLOCK)) T ON T.intTermID = I.intTermId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment, dblDiscount, dblInterest FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK)
						WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
    LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson WITH (NOLOCK)) SP 
				INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity WITH (NOLOCK) WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')  ) ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE  
  I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))

UNION ALL      
      
SELECT DISTINCT
       dtmDate				= I.dtmPostDate      
     , I.strInvoiceNumber
	 , P.strRecordNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , P.intPaymentId
	 , I.strBOLNumber	 
	 , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) END
     , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) THEN I.dblInvoiceTotal * -1 ELSE 0 END   
	 , I.dblAmountDue     
	 , dblDiscount			= ISNULL(I.dblDiscount, 0)
	 , dblInterest			= ISNULL(I.dblInterest, 0)
	 , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
	 , I.intEntityCustomerId
	 , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
	 , T.intTermID
     , intBalanceDue		= ISNULL(T.intBalanceDue, 0)    
     , strCustomerName		= ISNULL(E.strName, '')
	 , strCustomerNumber	= C.strCustomerNumber
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
     , ysnPosted			= ISNULL(I.ysnPosted, 1)
	 , dblAvailableCredit	= 0 
FROM (SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, intCompanyLocationId, dtmPostDate, strBOLNumber, strTransactionType, dtmDueDate, dblAmountDue, dblDiscount, dblInterest, dblInvoiceTotal 
			,intTermId, ysnPosted, intEntitySalespersonId
	 FROM tblARInvoice WITH (NOLOCK)
	 WHERE ysnPosted  = 1 
			AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal 
			AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) I 
	 INNER JOIN (SELECT intEntityCustomerId, strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId 
	 INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity WITH (NOLOCK)) E ON E.intEntityId = C.intEntityCustomerId    
	 INNER JOIN (SELECT intTermID, intBalanceDue FROM tblSMTerm WITH (NOLOCK)) T ON T.intTermID = I.intTermId
	 LEFT JOIN ((SELECT intPaymentId, intInvoiceId, dblPayment FROM tblARPaymentDetail WITH (NOLOCK)) PD 
				INNER JOIN (SELECT intPaymentId, strRecordNumber, dblAmountPaid FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN ((SELECT intPaymentId, intInvoiceId, dblPayment FROM tblAPPaymentDetail WITH (NOLOCK)) APPD 
				INNER JOIN (SELECT intPaymentId, dtmDatePaid, dblAmountPaid FROM tblAPPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) APP ON APPD.intPaymentId = APP.intPaymentId ) ON I.intInvoiceId = APPD.intInvoiceId
	 LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment, dblDiscount, dblInterest FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	 LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment, dblDiscount, dblInterest FROM tblAPPaymentDetail WITH (NOLOCK)) PD 
				 INNER JOIN (SELECT intPaymentId FROM tblAPPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId)
		) TOTALSETTLEMENT ON I.intInvoiceId = TOTALSETTLEMENT.intInvoiceId
	 LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson WITH (NOLOCK) ) SP 
	             INNER JOIN (SELECT intEntityId FROM tblEMEntity WITH (NOLOCK) WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')) ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE
 I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) - ISNULL(TOTALSETTLEMENT.dblPayment, 0) <> 0
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
FROM (SELECT intInvoiceId, strInvoiceNumber, dtmDueDate, strBOLNumber, intEntityCustomerId, dblInvoiceTotal, intEntitySalespersonId 
	  FROM tblARInvoice WITH (NOLOCK)
	  WHERE ysnPosted = 1
			 AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
			 AND strTransactionType IN ('Invoice', 'Debit Memo')
			 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			 AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) I
	INNER JOIN (SELECT intEntityCustomerId FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId    
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment, dblDiscount, dblInterest FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson WITH (NOLOCK)) SP 
	INNER JOIN (SELECT intEntityId FROM tblEMEntity WITH (NOLOCK) WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')) ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE 
 I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0
 

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
	  , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
FROM (SELECT intInvoiceId, strInvoiceNumber, strBOLNumber, intEntityCustomerId, dtmDueDate, intPaymentId, intEntitySalespersonId, dblInvoiceTotal FROM tblARInvoice WITH (NOLOCK)
	  WHERE ysnPosted = 1
		 AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
		 AND strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
		 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
		 AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) I
	INNER JOIN (SELECT intEntityCustomerId FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN (SELECT intPaymentId, dtmDatePaid FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson WITH (NOLOCK)) SP 
			   INNER JOIN (SELECT intEntityId FROM tblEMEntity WITH (NOLOCK) WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')) ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE 
 I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
  
						      
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
FROM (SELECT intPaymentId, dtmDatePaid FROM tblARPayment WITH (NOLOCK)
	  WHERE ysnPosted = 1
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal ) P
    INNER JOIN (SELECT intPaymentId, intInvoiceId, dblPayment FROM tblARPaymentDetail WITH (NOLOCK)) PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN (SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, dtmPostDate, strBOLNumber, dblInvoiceTotal, intEntitySalespersonId FROM tblARInvoice WITH (NOLOCK)
	WHERE ysnPosted = 1
				AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) > @dtmDateToLocal
				AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) I ON PD.intInvoiceId = I.intInvoiceId				
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))				
    INNER JOIN (SELECT intEntityCustomerId FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment, dblDiscount, dblInterest FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			      INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
    LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson WITH (NOLOCK)) SP 
				INNER JOIN (SELECT intEntityId FROM tblEMEntity WITH (NOLOCK) WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')) ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE   
  I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0
  

UNION ALL      
      
SELECT DISTINCT
    I.strInvoiceNumber
  , I.intInvoiceId
  , P.intPaymentId
  , I.strBOLNumber
  , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) END
  , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) THEN I.dblInvoiceTotal * -1 ELSE 0 END
  , dblAmountDue		= 0
  , dblDiscount			= ISNULL(PD.dblDiscount, 0) + ISNULL(APPD.dblDiscount, 0)
  , dblInterest			= ISNULL(PD.dblInterest, 0) + ISNULL(APPD.dblInterest, 0)
  , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
  , P.dtmDatePaid
  , I.intEntityCustomerId
  , dblAvailableCredit	= 0
FROM (SELECT intInvoiceId, strInvoiceNumber, intTermId, strTransactionType, strBOLNumber, intEntityCustomerId, dblInvoiceTotal, dtmDueDate, intEntitySalespersonId FROM tblARInvoice WITH (NOLOCK)
	  WHERE ysnPosted  = 1
			 AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
			 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal 
			 AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) I 
	INNER JOIN (SELECT intEntityCustomerId FROM tblARCustomer WITH (NOLOCK)) C ON C.intEntityCustomerId = I.intEntityCustomerId    
	INNER JOIN (SELECT intTermID FROM tblSMTerm WITH (NOLOCK)) T ON T.intTermID = I.intTermId	
	LEFT JOIN ((SELECT intPaymentId, intInvoiceId, dblDiscount, dblInterest, dblPayment FROM tblARPaymentDetail WITH (NOLOCK)) PD 
	            INNER JOIN (SELECT intPaymentId, dtmDatePaid, dblAmountPaid FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId ) ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN ((SELECT intPaymentId, intInvoiceId, dblDiscount, dblInterest,dblPayment FROM tblAPPaymentDetail WITH (NOLOCK)) APPD 
				INNER JOIN (SELECT intPaymentId, dblAmountPaid FROM tblAPPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) APP ON APPD.intPaymentId = APP.intPaymentId) ON I.intInvoiceId = APPD.intInvoiceId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM (SELECT intPaymentId, intInvoiceId, dblPayment, dblDiscount,dblInterest  FROM tblARPaymentDetail WITH (NOLOCK)) PD 
			INNER JOIN (SELECT intPaymentId FROM tblARPayment WITH (NOLOCK) WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblAPPaymentDetail PD 
			INNER JOIN (SELECT intPaymentId FROM tblAPPayment WHERE ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= @dtmDateToLocal) P ON PD.intPaymentId = P.intPaymentId 
			GROUP BY intInvoiceId)
		) TOTALSETTLEMENT ON I.intInvoiceId = TOTALSETTLEMENT.intInvoiceId
	LEFT JOIN ((SELECT intEntitySalespersonId FROM tblARSalesperson) SP 
				INNER JOIN (SELECT intEntityId FROM tblEMEntity WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+@strSalespersonLocal+'%')) ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId	
WHERE 
 I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) - ISNULL(TOTALSETTLEMENT.dblPayment, 0) <> 0) AS TBL) AS B    

ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
AND A.dblInvoiceTotal	 = B.dblInvoiceTotal
AND A.dblAmountPaid		 = B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
AND A.intPaymentId		 = B.intPaymentId

WHERE B.dblTotalDue - B.dblAvailableCredit <> 0

SET NOCOUNT OFF;