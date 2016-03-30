﻿CREATE PROCEDURE [dbo].[uspARCustomerStatementPaymentActivityReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

-- Declare the variables.
DECLARE  @dtmDateTo					AS DATETIME
		,@dtmDateFrom				AS DATETIME
		,@strDateTo					AS NVARCHAR(50)
		,@strDateFrom				AS NVARCHAR(50)
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

DECLARE @temp_aging_table TABLE(	
	 [strCustomerName]			NVARCHAR(100)
	,[strEntityNo]				NVARCHAR(100)
	,[intEntityCustomerId]		INT
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl91Days]				NUMERIC(18,6)
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)
)

DECLARE @temp_statement_table TABLE(
	 [intEntityCustomerId]	 INT
	,[strCustomerNumber]	 NVARCHAR(100)
	,[strCustomerName]		 NVARCHAR(100)
	,[dblCreditLimit]		 NUMERIC(18,6)
	,[intInvoiceId]			 INT
	,[strInvoiceNumber]		 NVARCHAR(100)
	,[strBOLNumber]			 NVARCHAR(100)
	,[dtmDate]				 DATETIME
	,[dtmDueDate]			 DATETIME
	,[dtmShipDate]			 DATETIME
	,[dblInvoiceTotal]		 NUMERIC(18,6)
	,[intPaymentId]			 INT
	,[strRecordNumber]		 NVARCHAR(100)
	,[strPaymentInfo]		 NVARCHAR(100)
	,[dtmDatePaid]			 DATETIME
	,[dblPayment]			 NUMERIC(18,6)
	,[dblBalance]			 NUMERIC(18,6)
	,[strSalespersonName]	 NVARCHAR(100)	
	,[strFullAddress]		 NVARCHAR(MAX)
	,[strCompanyName]		 NVARCHAR(MAX)
	,[strCompanyAddress]	 NVARCHAR(MAX)
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
SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@condition	 = [condition]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
SET @strDateTo = ''''+ CONVERT(NVARCHAR(50),@dtmDateTo, 110) + ''''
SET @strDateFrom = ''''+ CONVERT(NVARCHAR(50),@dtmDateFrom, 110) + ''''

IF UPPER(@condition) = UPPER('As Of')
	BEGIN		
		SET @innerQuery = 'AND I.dtmPostDate <= '+ @strDateTo +''
	END
ELSE
	BEGIN
		SET @innerQuery = 'AND I.dtmPostDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo+''
	END

INSERT INTO @temp_aging_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateFrom, @dtmDateTo

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmAsOfDate'

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

SET @query = 'SELECT * FROM
(SELECT I.intEntityCustomerId
	 , C.strCustomerNumber
	 , strCustomerName		= C.strName
	 , C.dblCreditLimit
	 , I.intInvoiceId
	 , I.strInvoiceNumber
	 , strBOLNumber			= ''BOL# '' + I.strBOLNumber
     , I.dtmDate
     , I.dtmDueDate
	 , I.dtmShipDate
	 , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END
	 , P.intPaymentId
	 , P.strRecordNumber
	 , strPaymentInfo	    = ''PAYMENT REF: '' + P.strPaymentInfo
	 , P.dtmDatePaid
	 , dblPayment			= ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblDiscount, 0) - ISNULL(PD.dblInterest, 0)
	 , dblBalance			= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	 , strSalespersonName   = ESP.strName
	 , strFullAddress		= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL)
	 , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	 , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress]('''', '''', '''', strAddress, strCity, strState, strZip, strCountry, '''') FROM tblSMCompanySetup)
FROM tblARInvoice I 
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId	
	LEFT JOIN tblEntity ESP ON C.intSalespersonId = ESP.intEntityId	
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +') ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment, intInvoiceId FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +' GROUP BY intInvoiceId) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted  = 1
 AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +' 
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
										INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
										WHERE AG.strAccountGroup = ''Receivables'')
  '+ @innerQuery +'
) MainQuery'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

INSERT INTO @temp_statement_table
EXEC sp_executesql @query

SELECT STATEMENTREPORT.*
	  ,dblCreditAvailable	= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	  ,dbl0Days				= ISNULL(AGINGREPORT.dbl0Days, 0)
	  ,dbl10Days			= ISNULL(AGINGREPORT.dbl10Days, 0)
	  ,dbl30Days			= ISNULL(AGINGREPORT.dbl30Days, 0)
	  ,dbl60Days			= ISNULL(AGINGREPORT.dbl60Days, 0)
	  ,dbl90Days			= ISNULL(AGINGREPORT.dbl90Days, 0)
	  ,dbl91Days			= ISNULL(AGINGREPORT.dbl91Days, 0)
	  ,dblCredits			= ISNULL(AGINGREPORT.dblCredits, 0)
	  ,dtmAsOfDate			= @dtmDateTo
	  ,blbLogo				= dbo.fnSMGetCompanyLogo('Header')
FROM @temp_statement_table AS STATEMENTREPORT
LEFT JOIN @temp_aging_table AS AGINGREPORT 
ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId