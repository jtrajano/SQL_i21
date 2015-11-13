﻿CREATE PROCEDURE [dbo].[uspARCustomerAgingAsOfDateReport]
	@dtmDateFrom	DATETIME = NULL,
	@dtmDateTo		DATETIME = NULL,
	@strSalesperson NVARCHAR(100) = NULL
AS

IF @dtmDateTo IS NULL
	SET @dtmDateTo = GETDATE()

SELECT A.strCustomerName
     , A.strEntityNo
	 , A.intEntityCustomerId
	 , dblCreditLimit		= (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = A.intEntityCustomerId)
	 , dblTotalAR			= SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit)
	 , dblFuture			= 0
	 , dbl10Days			= SUM(B.dbl10Days)
	 , dbl30Days			= SUM(B.dbl30Days)
	 , dbl60Days			= SUM(B.dbl60Days)
	 , dbl90Days			= SUM(B.dbl90Days)
	 , dbl91Days			= SUM(B.dbl91Days)
	 , dblTotalDue			= SUM(B.dblTotalDue)
	 , dblAmountPaid		= SUM(A.dblAmountPaid)
	 , dblCredits			= SUM(B.dblAvailableCredit)
	 , dblPrepaids			= 0
	 , dtmAsOfDate			= @dtmDateTo
	 , strSalespersonName	='strSalespersonName' 
FROM

(SELECT I.dtmDate AS dtmDate
		, I.intInvoiceId
		, 0 AS dblAmountPaid   
		, dblInvoiceTotal = ISNULL(I.dblInvoiceTotal,0)
		, dblAmountDue = ISNULL(I.dblAmountDue,0)
		, dblDiscount = 0    
		, I.strTransactionType    
		, I.intEntityCustomerId
		, I.dtmDueDate    
		, I.intTermId
		, T.intBalanceDue    
		, E.strName AS strCustomerName
		, E.strEntityNo	 
		, strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)<=10 THEN '0 - 10 Days'
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)>10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)<=30 THEN '11 - 30 Days'
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)>30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)<=60 THEN '31 - 60 Days'
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)>60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)<=90 THEN '61 - 90 Days'
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo)>90 THEN 'Over 90' END
	, I.ysnPosted
	, dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId 
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted = 1
	AND I.strTransactionType = 'Invoice'
	AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

UNION ALL
						
SELECT I.dtmPostDate
		, I.intInvoiceId
		, dblAmountPaid = 0
		, dblInvoiceTotal = 0
		, dblAmountDue = 0    
		, dblDiscount = 0
		, I.strTransactionType	  
		, I.intEntityCustomerId
		, I.dtmDueDate
		, I.intTermId
		, T.intBalanceDue
		, E.strName AS strCustomerName
		, E.strEntityNo
		, strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=10 THEN '0 - 10 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=30 THEN '11 - 30 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=60 THEN '31 - 60 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=90 THEN '61 - 90 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>90 THEN 'Over 90' END
		, I.ysnPosted
		, dblAvailableCredit = ISNULL(I.dblAmountDue,0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted = 1
	AND I.ysnPaid = 0
	AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment')
	AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
      
UNION ALL      
      
SELECT I.dtmPostDate      
		, I.intInvoiceId
		, dblAmountPaid = ISNULL(PD.dblPayment,0)
		, dblInvoiceTotal = 0    
		, I.dblAmountDue     
		, ISNULL(I.dblDiscount, 0) AS dblDiscount    
		, ISNULL(I.strTransactionType, 'Invoice')    
		, ISNULL(I.intEntityCustomerId, '')    
		, ISNULL(I.dtmDueDate, GETDATE())    
		, ISNULL(T.intTermID, '')
		, ISNULL(T.intBalanceDue, 0)    
		, ISNULL(E.strName, '') AS strCustomerName
		, ISNULL(E.strEntityNo, '') AS strEntityNo	 
		, strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=10 THEN '0 - 10 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=30 THEN '11 - 30 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=60 THEN '31 - 60 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)<=90 THEN '61 - 90 Days'
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, @dtmDateTo)>90 THEN 'Over 90'
						ELSE '0 - 10 Days' END
		, ISNULL(I.ysnPosted, 1)
		, dblAvailableCredit = 0 
FROM tblARInvoice I 
		INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId 
		INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId    
		INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
		LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId) ON I.intInvoiceId = PD.intInvoiceId
		LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE ISNULL(I.ysnPosted, 1) = 1
	AND I.ysnPosted  = 1
	AND I.strTransactionType = 'Invoice'
	AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND P.dtmDatePaid BETWEEN @dtmDateFrom AND @dtmDateTo
	AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')) AS A  

LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
	, intInvoiceId  
	, dblInvoiceTotal
	, dblAmountPaid
	, (dblInvoiceTotal) -(dblAmountPaid) - (dblDiscount) AS dblTotalDue
	, dblAvailableCredit
	, CASE WHEN DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@dtmDateTo)<=10
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl10Days
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@dtmDateTo)>10 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@dtmDateTo)<=30
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl30Days
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@dtmDateTo)>30 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@dtmDateTo)<=60    
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl60Days
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@dtmDateTo)>60 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@dtmDateTo)<=90     
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl90Days    
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@dtmDateTo)>90      
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl91Days    
FROM
(SELECT I.intInvoiceId
		, 0 AS dblAmountPaid
		, dblInvoiceTotal = ISNULL(dblInvoiceTotal,0)
		, dblAmountDue = 0    
		, dblDiscount = 0    
		, I.dtmDueDate    
		, I.intEntityCustomerId
		, dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted = 1
	AND I.strTransactionType = 'Invoice'
	AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

UNION ALL

SELECT I.intInvoiceId
		, 0 AS dblAmountPaid
		, dblInvoiceTotal = 0
		, dblAmountDue = 0    
		, dblDiscount = 0    
		, I.dtmDueDate    
		, I.intEntityCustomerId
		, dblAvailableCredit = ISNULL(I.dblAmountDue,0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted = 1
	AND I.ysnPaid = 0
	AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment')
	AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
						      
UNION ALL      
      
SELECT DISTINCT 
	I.intInvoiceId
	, dblAmountPaid = ISNULL(PD.dblPayment,0)
	, dblInvoiceTotal = 0
	, dblAmountDue = 0
	, ISNULL(I.dblDiscount, 0) AS dblDiscount
	, ISNULL(I.dtmDueDate, GETDATE())
	, ISNULL(I.intEntityCustomerId, '')
	, dblAvailableCredit = 0
FROM tblARInvoice I 
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId) ON I.intInvoiceId = PD.intInvoiceId	
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted  = 1
	AND I.strTransactionType = 'Invoice'
	AND I.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND P.dtmDatePaid BETWEEN @dtmDateFrom AND @dtmDateTo
	AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
										INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
										WHERE AG.strAccountGroup = 'Receivables')) AS TBL) AS B    
    
ON
A.intEntityCustomerId = B.intEntityCustomerId
AND A.intInvoiceId = B.intInvoiceId
AND A.dblInvoiceTotal = B.dblInvoiceTotal
AND A.dblAmountPaid =B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
GROUP BY A.strCustomerName, A.intEntityCustomerId, A.strEntityNo