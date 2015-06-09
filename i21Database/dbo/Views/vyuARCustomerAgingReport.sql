CREATE VIEW [dbo].[vyuARCustomerAgingReport]
AS
SELECT A.strCustomerName
	 , dblCreditLimit = (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = A.intEntityCustomerId)
	 , dblTotalAR = SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit)
	 , dblFuture = 0
     , SUM(B.dbl10Days) AS dbl10Days
	 , SUM(B.dbl30Days) AS dbl30Days
	 , SUM(B.dbl60Days) AS dbl60Days
	 , SUM(B.dbl90Days) AS dbl90Days
	 , SUM(B.dbl91Days) AS dbl91Days
	 , SUM(B.dblTotalDue) AS dblTotalDue
	 , SUM(A.dblAmountPaid) AS dblAmountPaid	 
	 , dblCredits = SUM(B.dblAvailableCredit)
	 , dblPrepaids = 0	 
FROM

(SELECT I.dtmDate AS dtmDate
	 , I.strInvoiceNumber
	 , 0 AS dblAmountPaid   
     , dblInvoiceTotal = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal,0) * -1 ELSE ISNULL(I.dblInvoiceTotal,0) END
	 , dblAmountDue = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblAmountDue,0) * -1 ELSE ISNULL(I.dblAmountDue,0) END   
	 , dblDiscount = 0    
	 , I.strTransactionType    
	 , I.intEntityCustomerId
	 , I.dtmDueDate    
	 , I.intTermId
	 , T.intBalanceDue    
     , E.strName AS strCustomerName	 
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())<=30 THEN '0 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())>0 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())<=30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())>30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())<=60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())>60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())<=90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE())>90 THEN 'Over 90'     
					 ELSE '0 - 10 Days' END 
	, I.ysnPosted
	, dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId    
WHERE I.ysnPosted = 1      
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

UNION ALL
						
SELECT I.dtmPostDate
	 , I.strInvoiceNumber
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
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '0 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>0 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>90 THEN 'Over 90' END
	 , I.ysnPosted
	 , dblAvailableCredit = ISNULL(I.dblAmountDue,0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
WHERE I.ysnPosted = 1
 AND I.ysnPaid = 0
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
      
UNION ALL      
      
SELECT I.dtmPostDate      
     , I.strInvoiceNumber
	 , dblAmountPaid = CASE WHEN strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment,0) * -1 ELSE ISNULL(I.dblPayment,0) END
     , dblInvoiceTotal = 0    
	 , I.dblAmountDue     
	 , ISNULL(I.dblDiscount, 0) AS dblDiscount    
	 , ISNULL(I.strTransactionType, 'Invoice')    
	 , ISNULL(I.intEntityCustomerId, '')    
	 , ISNULL(I.dtmDueDate, GETDATE())    
	 , ISNULL(T.intTermID, '')
     , ISNULL(T.intBalanceDue, 0)    
     , ISNULL(E.strName, '') AS strCustomerName	 
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '0 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>0 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,GETDATE())>90 THEN 'Over 90'
				     ELSE '0 - 10 Days' END
     , ISNULL(I.ysnPosted, 1)
	 , dblAvailableCredit = 0 
FROM tblARInvoice I 
	 INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId 
	 INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId    
	 INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
WHERE ISNULL(I.ysnPosted, 1) = 1
 AND I.ysnPosted  = 1      
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
  , dblAvailableCredit
  , CASE WHEN DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,GETDATE())<=10
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,GETDATE())>11 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,GETDATE())<=30
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
      , dblInvoiceTotal = CASE WHEN strTransactionType <> 'Invoice' THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END
	  , dblAmountDue = 0    
	  , dblDiscount = 0    
	  , I.dtmDueDate    
	  , I.intEntityCustomerId
	  , dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
WHERE I.ysnPosted = 1      
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
	  , dblAvailableCredit = ISNULL(I.dblAmountDue,0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
WHERE I.ysnPosted = 1
 AND I.ysnPaid = 0
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
						      
UNION ALL      
      
SELECT DISTINCT 
	I.strInvoiceNumber
  , dblAmountPaid = CASE WHEN strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment,0) * -1 ELSE ISNULL(I.dblPayment,0) END
  , dblInvoiceTotal = 0
  , dblAmountDue = 0
  , ISNULL(I.dblDiscount, 0) AS dblDiscount
  , ISNULL(I.dtmDueDate, GETDATE())
  , ISNULL(I.intEntityCustomerId, '')
  , dblAvailableCredit = 0
FROM tblARInvoice I 
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId	
WHERE ISNULL(I.ysnPosted, 1) = 1
 AND I.ysnPosted  = 1
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
										INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
										WHERE AG.strAccountGroup = 'Receivables')) AS TBL) AS B    
    
ON
A.intEntityCustomerId = B.intEntityCustomerId
AND A.strInvoiceNumber = B.strInvoiceNumber
AND A.dblInvoiceTotal = B.dblInvoiceTotal
AND A.dblAmountPaid =B.dblAmountPaid

GROUP BY A.strCustomerName, A.intEntityCustomerId