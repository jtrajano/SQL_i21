﻿CREATE PROCEDURE [dbo].[uspARCustomerAgingReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL 
		SELECT  strCustomerName = ''
			  , intEntityCustomerId = 0
			  , dblCreditLimit = 0.000000
			  , dblTotalAR = 0.000000
			  , dblFuture = 0.000000
			  , dbl10Days = 0.000000
			  , dbl30Days = 0.000000
			  , dbl60Days = 0.000000
			  , dbl90Days = 0.000000
			  , dbl91Days = 0.000000
			  , dblTotalDue = 0.000000
			  , dblAmountPaid = 0.000000
			  , dblAvailableCredit = 0.000000
			  , dblPrepaids = 0.000000
			  , dtmAsOfDate = GETDATE()
			  , intSalespersonId = 0
	END

-- Declare the variables.
DECLARE  @dtmAsOfDate				AS DATETIME
		,@strAsOfDate				AS NVARCHAR(50)
		,@xmlDocumentId				AS INT
		,@query						AS NVARCHAR(MAX)
		,@innerQuery				AS NVARCHAR(MAX) = ''
		,@joinQuery                 AS NVARCHAR(MAX) = ''
		,@filter					AS NVARCHAR(MAX) = ''
		,@fieldname					AS NVARCHAR(50)
		,@condition					AS NVARCHAR(20)
		,@id						AS INT 
		,@from						AS NVARCHAR(50)
		,@to						AS NVARCHAR(50)
		,@join						AS NVARCHAR(10)
		,@begingroup				AS NVARCHAR(50)
		,@endgroup					AS NVARCHAR(50)
		,@datatype					AS NVARCHAR(50)
		
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50)
	,[condition]	NVARCHAR(20)
	,[from]			NVARCHAR(50)
	,[to]			NVARCHAR(50)
	,[join]			NVARCHAR(10)
	,[begingroup]	NVARCHAR(50)
	,[endgroup]		NVARCHAR(50)
	,[datatype]		NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(50)
	, [to]		   NVARCHAR(50)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

-- Gather the variables values from the xml table.
SELECT  @condition = [condition]
	  , @from = [from]
	  , @to = [to]
	  , @join = [join]
	  , @datatype = [datatype]
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSalespersonName'

IF ISNULL(@from, '') <> ''
	BEGIN
		SET @innerQuery = 'AND ES.' + dbo.fnAPCreateFilter('strName', @condition, @from, @to, @join, null, null, @datatype)
		SET @joinQuery = 'LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId'
	END

SELECT	@dtmAsOfDate = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'
		
-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmAsOfDate IS NOT NULL
	SET @dtmAsOfDate = CAST(FLOOR(CAST(@dtmAsOfDate AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmAsOfDate = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

SET @strAsOfDate = ''''+ CONVERT(NVARCHAR(50),@dtmAsOfDate, 110) + ''''

DELETE FROM @temp_xml_table WHERE [fieldname] IN ('dtmAsOfDate', 'strSalespersonName')

SELECT @condition = '', @from = '', @to = '', @join = '', @datatype = ''

WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table
	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
	
	DELETE FROM @temp_xml_table WHERE id = @id

	IF EXISTS(SELECT 1 FROM @temp_xml_table)
	BEGIN
		SET @filter = @filter + ' AND '
	END
END

SET @query = 'SELECT * FROM (
SELECT A.strCustomerName
     , A.strEntityNo
	 , A.intEntityCustomerId
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
	 , '+ @strAsOfDate +' AS dtmAsOfDate
	 , ''strSalespersonName'' AS strSalespersonName
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
		, T.intBalanceDue    
		, E.strName AS strCustomerName
		, E.strEntityNo	 
		, strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')<=10 THEN ''0 - 10 Days''
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')>10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')<=30 THEN ''11 - 30 Days''
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')>30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')<=60 THEN ''31 - 60 Days''
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')>60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')<=90 THEN ''61 - 90 Days''
						WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, '+ @strAsOfDate +')>90 THEN ''Over 90'' END
	, I.ysnPosted
	, dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId 
	'+ @joinQuery +'
WHERE I.ysnPosted = 1
	AND I.strTransactionType = ''Invoice''
	AND I.dtmDueDate <= '+ @strAsOfDate +'
	'+ @innerQuery +'
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = ''Receivables'')

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
		, E.strEntityNo
		, strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=10 THEN ''0 - 10 Days''
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=30 THEN ''11 - 30 Days''
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=60 THEN ''31 - 60 Days''   
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=90 THEN ''61 - 90 Days''    
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>90 THEN ''Over 90'' END
		, I.ysnPosted
		, dblAvailableCredit = ISNULL(I.dblAmountDue,0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	'+ @joinQuery +'
WHERE I.ysnPosted = 1
	AND I.ysnPaid = 0
	AND I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Credit'', ''Prepayment'')
	AND I.dtmDueDate <= '+ @strAsOfDate +'
	'+ @innerQuery +'
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = ''Receivables'')
      
UNION ALL      
      
SELECT I.dtmPostDate      
		, I.strInvoiceNumber
		, dblAmountPaid = ISNULL(I.dblPayment,0)
		, dblInvoiceTotal = 0    
		, I.dblAmountDue     
		, ISNULL(I.dblDiscount, 0) AS dblDiscount    
		, ISNULL(I.strTransactionType, ''Invoice'')    
		, ISNULL(I.intEntityCustomerId, '''')    
		, ISNULL(I.dtmDueDate, GETDATE())    
		, ISNULL(T.intTermID, '''')
		, ISNULL(T.intBalanceDue, 0)    
		, ISNULL(E.strName, '''') AS strCustomerName
		, ISNULL(E.strEntityNo, '''') AS strEntityNo	 
		, strAge = CASE WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=10 THEN ''0 - 10 Days''
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>10 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=30 THEN ''11 - 30 Days''
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>30 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=60 THEN ''31 - 60 Days''
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>60 AND DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')<=90 THEN ''61 - 90 Days''
						WHEN DATEDIFF(DAYOFYEAR,I.dtmDueDate, '+ @strAsOfDate +')>90 THEN ''Over 90''
						ELSE ''0 - 10 Days'' END
		, ISNULL(I.ysnPosted, 1)
		, dblAvailableCredit = 0 
FROM tblARInvoice I 
		INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId 
		INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId    
		INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
		'+ @joinQuery +'
WHERE ISNULL(I.ysnPosted, 1) = 1
	AND I.ysnPosted  = 1
	AND I.strTransactionType = ''Invoice''
	AND I.dtmDueDate <= '+ @strAsOfDate +'
	'+ @innerQuery +'
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = ''Receivables'')) AS A  

LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
	, strInvoiceNumber  
	, dblInvoiceTotal
	, dblAmountPaid
	, (dblInvoiceTotal) -(dblAmountPaid) - (dblDiscount) AS dblTotalDue
	, dblAvailableCredit
	, CASE WHEN DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,'+ @strAsOfDate +')<=10
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl10Days
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,'+ @strAsOfDate +')>10 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,'+ @strAsOfDate +')<=30
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl30Days
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,'+ @strAsOfDate +')>30 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,'+ @strAsOfDate +')<=60    
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl60Days
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,'+ @strAsOfDate +')>60 AND DATEDIFF(DAYOFYEAR,TBL.dtmDueDate,'+ @strAsOfDate +')<=90     
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl90Days    
	, CASE WHEN DATEDIFF(DAYOFYEAR,dtmDueDate,'+ @strAsOfDate +')>90      
			THEN ISNULL((TBL.dblInvoiceTotal),0)-ISNULL((TBL.dblAmountPaid),0) ELSE 0 END dbl91Days    
FROM
(SELECT I.strInvoiceNumber
		, 0 AS dblAmountPaid
		, dblInvoiceTotal = ISNULL(dblInvoiceTotal,0)
		, dblAmountDue = 0    
		, dblDiscount = 0    
		, I.dtmDueDate    
		, I.intEntityCustomerId
		, dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	'+ @joinQuery +'
WHERE I.ysnPosted = 1
	AND I.strTransactionType = ''Invoice''
	AND I.dtmDueDate <= '+ @strAsOfDate +'
	'+ @innerQuery +'
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = ''Receivables'')

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
	'+ @joinQuery +'
WHERE I.ysnPosted = 1
	AND I.ysnPaid = 0
	AND I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Credit'', ''Prepayment'')
	AND I.dtmDueDate <= '+ @strAsOfDate +'
	'+ @innerQuery +'
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = ''Receivables'')
						      
UNION ALL      
      
SELECT DISTINCT 
	I.strInvoiceNumber
	, dblAmountPaid = ISNULL(I.dblPayment,0)
	, dblInvoiceTotal = 0
	, dblAmountDue = 0
	, ISNULL(I.dblDiscount, 0) AS dblDiscount
	, ISNULL(I.dtmDueDate, GETDATE())
	, ISNULL(I.intEntityCustomerId, '''')
	, dblAvailableCredit = 0
FROM tblARInvoice I 
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	'+ @joinQuery +'	
WHERE I.ysnPosted  = 1
	AND I.strTransactionType = ''Invoice''
	AND I.dtmDueDate <= '+ @strAsOfDate +'
	'+ @innerQuery +'
	AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
										INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
										WHERE AG.strAccountGroup = ''Receivables'')) AS TBL) AS B    
    
ON
A.intEntityCustomerId = B.intEntityCustomerId
AND A.strInvoiceNumber = B.strInvoiceNumber
AND A.dblInvoiceTotal = B.dblInvoiceTotal
AND A.dblAmountPaid =B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
GROUP BY A.strCustomerName, A.intEntityCustomerId, A.strEntityNo
) MainQuery'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

EXEC sp_executesql @query