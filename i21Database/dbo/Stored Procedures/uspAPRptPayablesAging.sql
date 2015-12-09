CREATE PROCEDURE [dbo].[uspAPRptPayablesAging]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sample XML string structure:
--DECLARE @xmlParam NVARCHAR(MAX)
--SET @xmlParam = '
--<xmlparam>
--	<filters>
--		<filter>
--			<fieldname>dtmDate</fieldname>
--			<condition>Between</condition>
--			<from>1/1/1900</from>
--			<to>1/1/2014</to>
--			<join>And</join>
--			<begingroup>0</begingroup>
--			<endgroup>0</endgroup>
--			<datatype>Int</datatype>
--		</filter>
--		<filter>
--			<fieldname>intEntityVendorId</fieldname>
--			<condition>Equal To</condition>
--			<from>6</from>
--			<to />
--			<join>And</join>
--			<begingroup>0</begingroup>
--			<endgroup>0</endgroup>
--			<datatype>DateTime</datatype>
--		</filter>
--	</filters>
--	<options />
--</xmlparam>'

DECLARE @query NVARCHAR(MAX), @innerQuery NVARCHAR(MAX), @filter NVARCHAR(MAX) = '';
DECLARE @dateFrom DATETIME = NULL;
DECLARE @dateTo DATETIME = NULL;
DECLARE @total NUMERIC(18,6), @amountDue NUMERIC(18,6), @amountPad NUMERIC(18,6);
DECLARE @count INT = 0;
DECLARE @fieldname NVARCHAR(50)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @strBillId NVARCHAR(50) 
DECLARE @strAccountId NVARCHAR(50) 
DECLARE @strVendorIdName NVARCHAR(150) 
DECLARE @strVendorId NVARCHAR(50)
DECLARE @strVendorOrderNumber NVARCHAR(50)
DECLARE @strTerm NVARCHAR(50)
DECLARE @dtmDate DATETIME 
DECLARE @from NVARCHAR(50)
DECLARE @to NVARCHAR(50)
DECLARE @join NVARCHAR(10)
DECLARE @begingroup NVARCHAR(50)
DECLARE @endgroup NVARCHAR(50)
DECLARE @datatype NVARCHAR(50)

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

DECLARE @xmlDocumentId AS INT;

-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)
-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	  [fieldname] nvarchar(50)
	, condition nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [begingroup] nvarchar(50)
	, [endgroup] nvarchar(50)
	, [datatype] nvarchar(50)
)

--select * from @temp_xml_table
--CREATE date filter
SELECT @dateFrom = [from], @dateTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDueDate';
SET @innerQuery = 'SELECT 
					intBillId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
					,dtmDate
				  FROM dbo.vyuAPPayables'

IF @dateFrom IS NOT NULL
BEGIN
	SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''

END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'

WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT @id = id, 
		   @fieldname = [fieldname], 
		   @condition = [condition], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table
	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
	
	DELETE FROM @temp_xml_table WHERE id = @id
	
	IF EXISTS(SELECT 1 FROM @temp_xml_table)
	BEGIN
		SET @filter = @filter + ' AND '
	END
END

-- Gather the variables values from the xml table.
	SELECT @strVendorId = [fieldname], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table WHERE [fieldname] = 'strVendorId';
	IF @strVendorId IS NOT NULL
	BEGIN
		SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strVendorId, @condition, @from, @to, @join, null, null, @datatype)				  
	END
    
	SELECT @strVendorIdName = [fieldname], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table WHERE [fieldname] = 'strVendorIdName';
	IF @strVendorIdName IS NOT NULL
	BEGIN
		SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strVendorIdName, @condition, @from, @to, @join, null, null, @datatype)				  
	END
  
   SELECT @strBillId = [fieldname], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table WHERE [fieldname] = 'strBillId';
	IF @strBillId IS NOT NULL
	BEGIN
		SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strBillId, @condition, @from, @to, @join, null, null, @datatype)				  
	END  

	 SELECT @strAccountId = [fieldname], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table WHERE [fieldname] = 'strAccountId';
	IF @strAccountId IS NOT NULL
	BEGIN
		SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strAccountId, @condition, @from, @to, @join, null, null, @datatype)				  
	END  

	SELECT @strVendorOrderNumber = [fieldname], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table WHERE [fieldname] = 'strVendorOrderNumber';
	IF @strVendorOrderNumber IS NOT NULL
	BEGIN
		SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strVendorOrderNumber, @condition, @from, @to, @join, null, null, @datatype)				  
	END  

	SELECT @strTerm = [fieldname], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table WHERE [fieldname] = 'strTerm';
	IF @strTerm IS NOT NULL
	BEGIN
		SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strTerm, @condition, @from, @to, @join, null, null, @datatype)				  
	END  

SET @query = '
	SELECT * FROM (
	SELECT
	A.dtmDate
	,A.dtmDueDate
	,B.strVendorId
	,B.[intEntityVendorId]
	,A.intBillId
	,A.strBillId
	,A.strVendorOrderNumber
	,T.strTerm
	,(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup) as strCompanyName
	,A.intAccountId
	,D.strAccountId
	,tmpAgingSummaryTotal.dblTotal
	,tmpAgingSummaryTotal.dblAmountPaid
	,tmpAgingSummaryTotal.dblDiscount
	,tmpAgingSummaryTotal.dblInterest
	,tmpAgingSummaryTotal.dblAmountDue
	,ISNULL(B.strVendorId,'''') + '' - '' + isnull(C.strName,'''') as strVendorIdName 
	,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 THEN 0 
			ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 0
			ELSE DATEDIFF(dayofyear,A.dtmDueDate,GETDATE()) END AS intAging
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblCurrent,
		CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl1, 
		CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl30, 
		CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl60,
		CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl90
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN ''Current''
			WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 THEN ''01 - 30 Days''
			WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60 THEN ''31 - 60 Days'' 
			WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 THEN ''61 - 90 Days''
			WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90 THEN ''Over 90'' 
			ELSE ''Current'' END AS strAge
	FROM  
	(
		SELECT 
		intBillId
		,SUM(tmpAPPayables.dblTotal) AS dblTotal
		,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
		,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
		,SUM(tmpAPPayables.dblInterest) AS dblInterest
		,(SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS dblAmountDue
		FROM ('
				+ @innerQuery +
			') tmpAPPayables 
		--WHERE dblAmountDue <> 0
		GROUP BY intBillId
	) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblAPBill A
	ON A.intBillId = tmpAgingSummaryTotal.intBillId
	LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEntity C ON B.[intEntityVendorId] = C.intEntityId)
	ON B.[intEntityVendorId] = A.[intEntityVendorId]
	LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
	LEFT JOIN dbo.tblSMTerm T ON A.intTermsId = T.intTermID
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
) MainQuery'


IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

--PRINT @filter
--PRINT @query

EXEC sp_executesql @query
GO