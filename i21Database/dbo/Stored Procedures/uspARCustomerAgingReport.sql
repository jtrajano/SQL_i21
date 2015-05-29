CREATE PROCEDURE [dbo].[uspARCustomerAgingReport]
	@Date DATETIME = NULL
AS
BEGIN TRY
SET NOCOUNT ON
	DECLARE @ErrMsg NVARCHAR(MAX)
	SET @Date = CASE WHEN @Date IS NOT NULL THEN CONVERT(DATETIME, @Date) ELSE GETDATE() END	

SELECT SUM(B.dblTotalCurrent) AS dblTotalCurrent
     , SUM(B.dbl10Days) AS dbl10Days
	 , SUM(B.dbl30Days) AS dbl30Days
	 , SUM(B.dbl60Days) AS dbl60Days
	 , SUM(B.dbl90Days) AS dbl90Days
	 , SUM(B.dbl91Days) AS dbl91Days
	 , SUM(B.dblTotalDue) AS dblTotalDue
	 , SUM(A.dblInvoiceTotal) AS dblInvoiceTotal
	 , SUM(A.dblAmountPaid) AS dblAmountPaid
	 , A.strCustomerName
FROM

(SELECT I.dtmDate AS dtmDate
	 , I.strInvoiceNumber
	 , 0 AS dblAmountPaid   
     , dblInvoiceTotal = ISNULL(I.dblInvoiceTotal,0)
	 , I.dblAmountDue   
	 , dblDiscount = 0    
	 , I.strTransactionType    
	 , I.intEntityCustomerId
	 , I.dtmDueDate    
	 , I.intTermId
	 , T.intBalanceDue    
     , E.strName AS strCustomerName
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)<=0 THEN 'Current'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)>0 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)<=30 THEN '0 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)>0 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)<=30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)>30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)<=60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)>60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)<=90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @Date)>90 THEN 'Over 90'     
					 ELSE 'Current' END 
	, I.ysnPosted
FROM tblARInvoice I
	LEFT JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	LEFT JOIN tblSMTerm T ON T.intTermID = I.intTermId    
WHERE I.ysnPosted = 1      
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
      
UNION ALL      
      
SELECT P.dtmDatePaid AS dtmDate      
     , I.strInvoiceNumber
	 , ISNULL(PD.dblPayment, 0) AS dblAmountPaid      
     , dblInvoiceTotal = 0    
	 , I.dblAmountDue     
	 , ISNULL(I.dblDiscount, 0) AS dblDiscount    
	 , ISNULL(I.strTransactionType, 'Invoice')    
	 , ISNULL(I.intEntityCustomerId, '')    
	 , ISNULL(I.dtmDueDate, @Date)    
	 , ISNULL(T.intTermID, '')
     , ISNULL(T.intBalanceDue, 0)    
     , ISNULL(E.strName, '') AS strCustomerName    
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)<=0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)>0 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)<=30 THEN '0 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)>0 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)<=30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)<=60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)<=90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate,@Date)>90 THEN 'Over 90'
				     ELSE 'Current' END
     , ISNULL(I.ysnPosted, 1) 
FROM tblARPaymentDetail PD
	 LEFT JOIN (tblARInvoice I LEFT JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId    
	 LEFT JOIN tblSMTerm T ON T.intTermID = I.intTermId) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId
WHERE ISNULL(I.ysnPosted, 1) = 1
 AND P.ysnPosted  = 1      
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
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@Date)<=0     
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dblTotalCurrent
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@Date)>0 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@Date)<=10
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@Date)>11 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@Date)<=30
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@Date)>30 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@Date)<=60    
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@Date)>60 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,@Date)<=90     
		 THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl90Days    
  , CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,@Date)>90      
	     THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl91Days    
FROM
(SELECT I.strInvoiceNumber
      , 0 AS dblAmountPaid
      , dblInvoiceTotal = ISNULL(I.dblInvoiceTotal,0)    
	  , dblAmountDue = 0    
	  , dblDiscount = 0    
	  , I.dtmDueDate    
	  , I.intEntityCustomerId    
FROM tblARInvoice I
	LEFT JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
WHERE I.ysnPosted = 1      
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
      
UNION ALL      
      
SELECT DISTINCT 
	I.strInvoiceNumber
  , ISNULL(PD.dblPayment, 0) AS dblAmountPaid
  , dblInvoiceTotal = 0
  , dblAmountDue = 0
  , ISNULL(PD.dblDiscount, 0) AS dblDiscount
  , ISNULL(I.dtmDueDate, @Date)
  , ISNULL(I.intEntityCustomerId, '')
FROM tblARPaymentDetail PD
	LEFT JOIN (tblARInvoice I LEFT JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	LEFT JOIN tblSMTerm T ON T.intTermID = I.intTermId) ON I.intInvoiceId = PD.intInvoiceId    
	LEFT JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId      
WHERE ISNULL(I.ysnPosted, 1) = 1      
 AND P.ysnPosted  = 1      
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
										INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
										WHERE AG.strAccountGroup = 'Receivables')) AS TBL) AS B    
    
ON
A.intEntityCustomerId = B.intEntityCustomerId
AND A.strInvoiceNumber = B.strInvoiceNumber
AND A.dblInvoiceTotal = B.dblInvoiceTotal
AND A.dblAmountPaid =B.dblAmountPaid

GROUP BY A.strCustomerName

END TRY
BEGIN CATCH
 SET @ErrMsg = ERROR_MESSAGE()
 SET @ErrMsg = 'uspARCustomerAgingReport: ' + @ErrMsg
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH