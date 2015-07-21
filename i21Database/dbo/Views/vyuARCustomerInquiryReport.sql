CREATE VIEW [dbo].[vyuARCustomerInquiryReport]
AS 
SELECT A.strCustomerName
     , SUM(B.dbl10Days) AS dbl10Days
	 , SUM(B.dbl30Days) AS dbl30Days
	 , SUM(B.dbl60Days) AS dbl60Days
	 , SUM(B.dbl90Days) AS dbl90Days
	 , SUM(B.dbl91Days) AS dbl91Days
	 , SUM(B.dblTotalDue) AS dblTotalDue
	 , SUM(A.dblAmountPaid) AS dblAmountPaid
	 , SUM(A.dblInvoiceTotal) AS dblInvoiceTotal
	 , SUM(B.dblYTDSales) AS dblYTDSales
	 , SUM(B.dblLastYearSales) AS dblLastYearSales
	 , dblLastPayment = (SELECT TOP 1 ISNULL(dblAmountPaid, 0) FROM tblARPayment WHERE intEntityCustomerId = A.intEntityCustomerId ORDER BY dtmDatePaid DESC)
	 , dtmLastPaymentDate = (SELECT TOP 1 dtmDatePaid FROM tblARPayment WHERE intEntityCustomerId = A.intEntityCustomerId ORDER BY dtmDatePaid DESC)
	 , dblLastStatement = (SELECT TOP 1 ISNULL(I.dblPayment, 0) FROM tblARInvoice I 
									INNER JOIN tblARPayment P ON I.intEntityCustomerId = P.intEntityCustomerId
								WHERE I.ysnPosted = 1 
								  AND I.ysnPaid = 1
								  AND I.intEntityCustomerId = A.intEntityCustomerId 
								ORDER BY P.dtmDatePaid, P.intPaymentId DESC)
	 , dtmLastStatementDate = (SELECT TOP 1 P.dtmDatePaid FROM tblARInvoice I 
									INNER JOIN tblARPayment P ON I.intEntityCustomerId = P.intEntityCustomerId
								WHERE I.ysnPosted = 1
								  AND I.ysnPaid = 1
								  AND I.intEntityCustomerId = A.intEntityCustomerId 
								ORDER BY P.dtmDatePaid, P.intPaymentId DESC)
	 , dblUnappliedCredits = SUM(B.dblAvailableCredit)
	 , dblPrepaids = 0
	 , dblFuture = 0
	 , dblPendingPayment = (SELECT ISNULL(SUM(CASE WHEN strTransactionType <> 'Invoice' THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END), 0) FROM tblARInvoice WHERE intEntityCustomerId = A.intEntityCustomerId AND ysnPosted = 0)
	 , dblCreditLimit = (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = A.intEntityCustomerId)
	 , strTerm
	 , strContact = (SELECT strFullAddress = ISNULL(RTRIM(C.strPhone) + CHAR(13) + char(10), '')
										   + ISNULL(RTRIM(E.strEmail) + CHAR(13) + char(10), '')
										   + ISNULL(RTRIM(C.strBillToLocationName) + CHAR(13) + char(10), '')
										   + ISNULL(RTRIM(C.strBillToAddress) + CHAR(13) + char(10), '')
										   + ISNULL(RTRIM(C.strBillToCity), '')
										   + ISNULL(', ' + RTRIM(C.strBillToState), '')
										   + ISNULL(', ' + RTRIM(C.strZipCode), '')
										   + ISNULL(', ' + RTRIM(C.strBillToCountry), '') FROM vyuARCustomer C INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId  WHERE intEntityCustomerId = A.intEntityCustomerId)	 
FROM
(SELECT I.dtmDate AS dtmDate
	  , I.strInvoiceNumber
	  , 0 AS dblAmountPaid
      , dblInvoiceTotal = ISNULL(I.dblInvoiceTotal,0)
	  , dblAmountDue = ISNULL(I.dblAmountDue,0)
	  , dblDiscount = 0    
	  , I.strTransactionType    
	  , I.intEntityCustomerId
	  , I.dtmDueDate    
	  , I.intTermId
	  , T.strTerm
	  , T.intBalanceDue    
      , E.strName AS strCustomerName
	  , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=10 THEN '0 - 10 Days'
	 			      WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '11 - 30 Days'
	 				  WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days'     
	 				  WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'    
	 				  WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>90 THEN 'Over 90' END 
	  , I.ysnPosted
	  , dblYTDSales = 0
	  , dblLastYearSales = 0
	  , dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId    
WHERE I.ysnPosted = 1
  AND I.strTransactionType = 'Invoice'
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

UNION ALL

SELECT I.dtmDate AS dtmDate
	 , I.strInvoiceNumber
     , 0 AS dblAmountPaid
     , dblInvoiceTotal = 0
	 , dblAmountDue = 0    
	 , dblDiscount = 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , I.intTermId
	 , T.strTerm
	 , T.intBalanceDue
	 , E.strName AS strCustomerName
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=10 THEN '0 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>90 THEN 'Over 90' END 
	 , I.ysnPosted
	 , dblYTDSales = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
	 , dblLastYearSales = 0
	 , dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
WHERE I.ysnPosted = 1
 AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE())
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

UNION ALL

SELECT I.dtmDate AS dtmDate
	 , I.strInvoiceNumber
     , 0 AS dblAmountPaid
     , dblInvoiceTotal = 0
	 , dblAmountDue = 0    
	 , dblDiscount = 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , I.intTermId
	 , T.strTerm
	 , T.intBalanceDue
	 , E.strName AS strCustomerName
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=10 THEN '0 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>90 THEN 'Over 90' END 
	 , I.ysnPosted
	 , dblYTDSales = 0
	 , dblLastYearSales = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
	 , dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
WHERE I.ysnPosted = 1
 AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE()) - 1
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables') 
      
UNION ALL

SELECT I.dtmDate AS dtmDate
	 , I.strInvoiceNumber
     , 0 AS dblAmountPaid
     , dblInvoiceTotal = 0
	 , dblAmountDue = 0    
	 , dblDiscount = 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , I.intTermId
	 , T.strTerm
	 , T.intBalanceDue
	 , E.strName AS strCustomerName
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=10 THEN '0 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>90 THEN 'Over 90' END
	 , I.ysnPosted
	 , dblYTDSales = 0
	 , dblLastYearSales = 0
	 , dblAvailableCredit = ISNULL(I.dblAmountDue,0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
WHERE I.ysnPosted = 1
 AND I.ysnPaid = 0
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables') 

UNION ALL

SELECT I.dtmPostDate
     , I.strInvoiceNumber
	 , dblAmountPaid = ISNULL(I.dblPayment,0) 
     , dblInvoiceTotal = 0    
	 , I.dblAmountDue     
	 , ISNULL(I.dblDiscount, 0) AS dblDiscount    
	 , ISNULL(I.strTransactionType, 'Invoice')    
	 , ISNULL(I.intEntityCustomerId, '')    
	 , ISNULL(I.dtmDueDate, GETDATE())    
	 , ISNULL(T.intTermID, '')
	 , T.strTerm
     , ISNULL(T.intBalanceDue, 0)    
     , ISNULL(E.strName, '') AS strCustomerName
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=10 THEN '0 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>90 THEN 'Over 90' END
     , ISNULL(I.ysnPosted, 1)
	 , dblYTDSales = 0
	 , dblLastYearSales = 0
	 , dblAvailableCredit = 0
FROM tblARInvoice I 
	 INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId 
	 INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId    
	 INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
WHERE ISNULL(I.ysnPosted, 1) = 1
 AND I.ysnPosted  = 1
 AND I.strTransactionType = 'Invoice'
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')) AS A 
LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
  , strInvoiceNumber  
  , dblInvoiceTotal    
  , dblAmountPaid
  , (dblInvoiceTotal) -(dblAmountPaid) - (dblDiscount) AS dblTotalDue
  , dblYTDSales
  , dblLastYearSales
  , dblAvailableCredit
  , CASE WHEN DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,GETDATE())<=10
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,GETDATE())>10 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,GETDATE())<=30
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,GETDATE())<=60    
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,GETDATE())<=90     
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl90Days    
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,GETDATE())>90      
	     THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl91Days    
FROM
(SELECT I.strInvoiceNumber
      , 0 AS dblAmountPaid
      , dblInvoiceTotal = ISNULL(I.dblInvoiceTotal,0)
	  , dblAmountDue = 0    
	  , dblDiscount = 0    
	  , I.dtmDueDate    
	  , I.intEntityCustomerId
	  , dblYTDSales = 0
	  , dblLastYearSales = 0
	  , dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
WHERE I.ysnPosted = 1
 AND I.strTransactionType = 'Invoice'
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

UNION ALL

SELECT I.strInvoiceNumber
      , 0 AS dblAmountPaid
      , dblInvoiceTotal = 0
	  , dblAmountDue = 0    
	  , dblDiscount = 0    
	  , I.dtmDueDate    
	  , I.intEntityCustomerId
	  , dblYTDSales = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END
	  , dblLastYearSales = 0
	  , dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
WHERE I.ysnPosted = 1
 AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE())
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

UNION ALL

SELECT I.strInvoiceNumber
      , 0 AS dblAmountPaid
      , dblInvoiceTotal = 0
	  , dblAmountDue = 0    
	  , dblDiscount = 0    
	  , I.dtmDueDate    
	  , I.intEntityCustomerId
	  , dblYTDSales = 0
	  , dblLastYearSales = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(I.dblInvoiceSubtotal, 0) END	  
	  , dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
WHERE I.ysnPosted = 1
 AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE()) - 1
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables') 

UNION ALL

SELECT I.strInvoiceNumber
      , 0 AS dblAmountPaid
      , dblInvoiceTotal = 0
	  , dblAmountDue = 0    
	  , dblDiscount = 0    
	  , I.dtmDueDate    
	  , I.intEntityCustomerId
	  , dblYTDSales = 0
	  , dblLastYearSales = 0
	  , dblAvailableCredit = ISNULL(I.dblAmountDue,0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
WHERE I.ysnPosted = 1
 AND I.ysnPaid = 0
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables') 
						     
UNION ALL      
      
SELECT DISTINCT 
	I.strInvoiceNumber
  , dblAmountPaid = ISNULL(I.dblPayment,0)
  , dblInvoiceTotal = 0
  , dblAmountDue = 0
  , ISNULL(I.dblDiscount, 0) AS dblDiscount
  , ISNULL(I.dtmDueDate, GETDATE())
  , ISNULL(I.intEntityCustomerId, '')
  , dblYTDSales = 0
  , dblLastYearSales = 0
  , dblAvailableCredit = 0
FROM tblARInvoice I 
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId	
WHERE ISNULL(I.ysnPosted, 1) = 1
 AND I.ysnPosted  = 1
 AND I.strTransactionType = 'Invoice'
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
										INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
										WHERE AG.strAccountGroup = 'Receivables')) AS TBL) AS B    
    
ON
A.intEntityCustomerId = B.intEntityCustomerId
AND A.strInvoiceNumber = B.strInvoiceNumber
AND A.dblInvoiceTotal = B.dblInvoiceTotal
AND A.dblAmountPaid = B.dblAmountPaid
AND A.dblYTDSales = B.dblYTDSales
AND A.dblLastYearSales = A.dblLastYearSales

GROUP BY A.strCustomerName
	   , A.intEntityCustomerId
	   , A.strTerm