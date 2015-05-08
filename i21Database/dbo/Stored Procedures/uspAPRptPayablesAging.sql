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

DECLARE @query NVARCHAR(MAX), @innerQuery NVARCHAR(MAX), @filter NVARCHAR(MAX);
DECLARE @dateFrom DATETIME = NULL;
DECLARE @dateTo DATETIME = NULL;
DECLARE @vendorId INT;
DECLARE @total NUMERIC(18,6), @amountDue NUMERIC(18,6), @amountPad NUMERIC(18,6);

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

DECLARE @xmlDocumentId AS INT;
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	[fieldname] NVARCHAR(50)
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

--CREATE date filter
SELECT @dateFrom = [from], @dateTo = [to] FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
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
	SET @innerQuery = @innerQuery + ' WHERE dtmDate BETWEEN ' + @dateFrom + ' AND '  + @dateTo
END

--CREATE vendor filter
SELECT @vendorId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intEntityVendorId';
IF @vendorId IS NOT NULL
BEGIN
	SET @filter = ' intEntityVendorId = ' + @vendorId;
END

SET @query = '
SELECT
A.dtmDate
,A.dtmDueDate
,B.strVendorId
,B.[intEntityVendorId]
,A.intBillId
,A.strBillId
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
	GROUP BY intBillId
) AS tmpAgingSummaryTotal
LEFT JOIN dbo.tblAPBill A
ON A.intBillId = tmpAgingSummaryTotal.intBillId
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEntity C ON B.[intEntityVendorId] = C.intEntityId)
ON B.[intEntityVendorId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId'

IF @filter IS NOT NULL
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

EXEC sp_executesql @query