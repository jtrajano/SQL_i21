CREATE PROCEDURE [dbo].[uspAPRptPayablesAgingSummary]
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

DECLARE @query NVARCHAR(MAX), @innerQuery NVARCHAR(MAX),  @originInnerQuery NVARCHAR(MAX), @prepaidInnerQuery NVARCHAR(MAX), @deletedQuery NVARCHAR(MAX), @arQuery NVARCHAR(MAX);
DECLARE @filter NVARCHAR(MAX) = '';
DECLARE @dateFrom DATETIME = NULL;
DECLARE @dateTo DATETIME = NULL;
DECLARE @dtmDueDate DATETIME = NULL;
DECLARE @total NUMERIC(18,6), @amountDue NUMERIC(18,6), @amountPad NUMERIC(18,6);
DECLARE @count INT = 0;
DECLARE @fieldname NVARCHAR(50)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @from NVARCHAR(50)
DECLARE @to NVARCHAR(50)
DECLARE @join NVARCHAR(10)
DECLARE @begingroup NVARCHAR(50)
DECLARE @endgroup NVARCHAR(50)
DECLARE @datatype NVARCHAR(50)
DECLARE @ysnFilter NVARCHAR(50) = 0
DECLARE @dtmDateFilter NVARCHAR(50)
DECLARE @strPeriod NVARCHAR(50)
DECLARE @strPeriodTo NVARCHAR(50)

	-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
--Add this so that XtraReports have fields to get
	SELECT 
		NULL AS dtmDate,
		NULL AS dtmDueDate,
		NULL AS dtmDateFilter,
		NULL AS strVendorId,
		NULL AS strVendorName,
		0 AS intEntityVendorId,
		0 AS intBillId,
		NULL AS strBillId,
		NULL AS strVendorOrderNumber,
		NULL AS strTerm,
		NULL AS strCompanyName,
		NULL AS strCompanyAddress,
		NULL AS strAccountId,
		NULL AS strVendorIdName,
		NULL AS strAge,
		NULL AS strClass,
		NULL AS strDateDesc,
		0 AS intAccountId,
		0 AS dblTotal,
		0 AS dblAmountPaid,
		0 AS dblDiscount,
		0 AS dblInterest,
		0 AS dblAmountDue,
		0 AS dblUnappliedAmount,
		0 AS dblCurrent,
		0 AS dbl0,
		0 AS dbl1,
		0 AS dbl30,
		0 AS dbl60,
		0 AS dbl90,
		0 AS intAging,
		NULL AS strPeriod,
		NULL AS strPeriodTo
END

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
SELECT @dateFrom = [from], @dateTo = [to],@condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
SELECT @dtmDueDate = [from], @dateTo = [to],@condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDueDate';
SELECT @strPeriod = [from], @strPeriodTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'strPeriod';
SET @innerQuery = 'SELECT --DISTINCT
				   intBillId
				   ,dblTotal
				   ,dblAmountDue
				   ,dblAmountPaid
				   ,dblDiscount
				   ,dblInterest
				   ,dtmDate
				   ,dtmDueDate
				   ,FP.strPeriod
				FROM dbo.vyuAPPayables A
				LEFT JOIN dbo.tblGLFiscalYearPeriod FP
				ON A.dtmDate BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR A.dtmDate = FP.dtmStartDate OR A.dtmDate = FP.dtmEndDate'

SET @deletedQuery = 'SELECT --DISTINCT 
					intBillId
					--,strAccountId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
					,dtmDate
					,FP.strPeriod
					,intCount
				  FROM dbo.vyuAPPayablesAgingDeleted A
				  LEFT JOIN dbo.tblGLFiscalYearPeriod FP
				  ON A.dtmDate BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR A.dtmDate = FP.dtmStartDate OR A.dtmDate = FP.dtmEndDate'

SET @prepaidInnerQuery = 'SELECT --DISTINCT 
					intBillId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
					,dtmDate
					,FP.strPeriod
					,intPrepaidRowType
				  FROM dbo.vyuAPPrepaidPayables A
				  LEFT JOIN dbo.tblGLFiscalYearPeriod FP
				  ON A.dtmDate BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR A.dtmDate = FP.dtmStartDate OR A.dtmDate = FP.dtmEndDate'

SET @arQuery = 'SELECT --DISTINCT 
					intInvoiceId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
					,dtmDate
					,FP.strPeriod
				  FROM dbo.vyuAPSalesForPayables A
				  LEFT JOIN dbo.tblGLFiscalYearPeriod FP
				  ON A.dtmDate BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR A.dtmDate = FP.dtmStartDate OR A.dtmDate = FP.dtmEndDate'

IF @dateFrom IS NOT NULL
BEGIN
	SET @ysnFilter = 1
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
		SET @deletedQuery = @deletedQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
		SET @prepaidInnerQuery = @prepaidInnerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
		SET @arQuery = @arQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
		SET @dtmDateFilter = '(SELECT ''' + CONVERT(VARCHAR(10), @dateFrom, 101) +''')';
	END
	ELSE
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @deletedQuery = @deletedQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @prepaidInnerQuery = @prepaidInnerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @arQuery = @arQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @dtmDateFilter = '(SELECT ''' + CONVERT(VARCHAR(10), @dateTo, 101) +''')';
	END  
	
END
ELSE IF @dtmDueDate IS NOT NULL
BEGIN
	SET @ysnFilter = 1
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''''
		SET @deletedQuery = @deletedQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''''
		SET @prepaidInnerQuery = @prepaidInnerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''''
		SET @arQuery = @arQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''''
		SET @dtmDateFilter = '(SELECT ''' + CONVERT(VARCHAR(10), @dtmDueDate, 101) +''')';
	END
	ELSE
	BEGIN
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @deletedQuery = @deletedQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @prepaidInnerQuery = @prepaidInnerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @arQuery = @arQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDueDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDueDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''
		SET @dtmDateFilter = '(SELECT ''' + CONVERT(VARCHAR(10), @dateTo, 101) +''')';
	END  
	
END
ELSE
BEGIN
	SET @dateFrom = CONVERT(VARCHAR(10), '1/1/1900', 110)
	SET @dateTo = GETDATE();
	SET @dtmDateFilter =  '(SELECT ''' + CONVERT(VARCHAR(10), GETDATE(), 101) +''')';
    
END

IF @strPeriod IS NOT NULL
BEGIN 
	IF @condition = 'Equal To' OR @condition = 'Like' OR @condition = 'Starts With' OR @condition = 'Ends With'
	BEGIN 
		SET @innerQuery =  @innerQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod = ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod = ''' + @strPeriod + '''' END
		SET @deletedQuery = @deletedQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod = ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod = ''' + @strPeriod + '''' END
		SET @prepaidInnerQuery = @prepaidInnerQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod = ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod = ''' + @strPeriod + '''' END
		SET @arQuery = @arQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod = ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod = ''' + @strPeriod + '''' END
	END
	ELSE IF @condition = 'Between'
	BEGIN
	SET @innerQuery =  @innerQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +''''
										 ELSE  ' WHERE strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +'''' END
		SET @deletedQuery = @deletedQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +''''
										 ELSE  ' WHERE strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +'''' END
		SET @prepaidInnerQuery = @prepaidInnerQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +''''
										 ELSE  ' WHERE strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +'''' END
		SET @arQuery = @arQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +''''
										 ELSE  ' WHERE strPeriod BETWEEN ''' + @strPeriod + ''' AND ''' + @strPeriodTo +'''' END
	END
	ELSE
	BEGIN
		SET @innerQuery =  @innerQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod != ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod != ''' + @strPeriod + '''' END
		SET @deletedQuery = @deletedQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod != ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod != ''' + @strPeriod + '''' END
		SET @prepaidInnerQuery = @prepaidInnerQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod != ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod != ''' + @strPeriod + '''' END
		SET @arQuery = @arQuery + CASE
										 WHEN @dateFrom IS NOT NULL AND @dateFrom <> '1/1/1900' OR @dtmDueDate IS NOT NULL
										 THEN ' AND strPeriod != ''' + @strPeriod + ''''
										 ELSE  ' WHERE strPeriod != ''' + @strPeriod + '''' END
	END
END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'
DELETE FROM @temp_xml_table WHERE [fieldname] = 'strPeriod'
DELETE FROM @temp_xml_table  where [condition] = 'Dummy'
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

----CREATE vendor filter
--SELECT @vendorId = [fieldname], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table WHERE [fieldname] = 'intEntityVendorId';
--IF @vendorId IS NOT NULL
--BEGIN
--	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @from, @to, @join, @datatype)
--END

--SELECT @accountId = [fieldname], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table WHERE [fieldname] = 'intAccountId';
--IF @accountId IS NOT NULL
--BEGIN
--	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@accountId, @from, @to, @join, @datatype)
--END

--SELECT @billId = [fieldname], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table WHERE [fieldname] = 'intBillId';
--IF @billId IS NOT NULL
--BEGIN
--	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@billId, @from, @to, @join, @datatype)
--END

SET @query = '
	SELECT * FROM (
	SELECT 
		intEntityVendorId
		,strVendorId
		,strVendorName
		,strVendorIdName
		,strCompanyName
		,strCompanyAddress
		,strClass
		,strDateDesc
		,dtmDateFilter
		,SUM(dblCurrent) dblCurrent
		,SUM(dbl0) dbl0
		,SUM(dbl1) dbl1
		,SUM(dbl30) dbl30
		,SUM(dbl60) dbl60
		,SUM(dbl90) dbl90
		,SUM(dblTotal) dblTotal
		,SUM(dblAmountPaid) dblAmountPaid
		,SUM(dblDiscount) dblDiscount
		,SUM(dblInterest) dblInterest
		,SUM(dblAmountDue) dblAmountDue
		,SUM(dblUnappliedAmount) dblUnappliedAmount
	FROM (
		SELECT
		A.dtmDate
		,A.dtmDueDate
		,B.strVendorId
		,C.strName as strVendorName
		,B.intEntityId as intEntityVendorId
		,A.intBillId
		,A.strBillId
		,A.intAccountId
		,D.strAccountId
		,EC.strClass
		,(CASE WHEN ' + @ysnFilter + ' = 1 THEN ''As Of'' ELSE ''All Dates'' END ) as strDateDesc
		, '+ @dtmDateFilter +' as dtmDateFilter
		,tmpAgingSummaryTotal.dblTotal
		,tmpAgingSummaryTotal.dblAmountPaid
		,tmpAgingSummaryTotal.dblDiscount
		,tmpAgingSummaryTotal.dblInterest
		,tmpAgingSummaryTotal.dblAmountDue
		,dbo.fnTrim(ISNULL(B.strVendorId,'''') + '' - '' + isnull(C.strName,'''')) as strVendorIdName 
		,(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup) as strCompanyName
		,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
		,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 THEN 0 
				ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 0
				ELSE DATEDIFF(dayofyear,A.dtmDueDate,GETDATE()) END AS intAging
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblCurrent
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=10 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl0
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>10 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl1 
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl30 
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl60
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
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
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (' 
					+ @innerQuery +
				') tmpAPPayables
			--WHERE dblAmountDue <> 0
			GROUP BY intBillId
			UNION ALL
			SELECT 
				intBillId
				,SUM(tmpAPPrepaidPayables.dblTotal) AS dblTotal
				,SUM(tmpAPPrepaidPayables.dblAmountPaid) AS dblAmountPaid
				,SUM(tmpAPPrepaidPayables.dblDiscount)AS dblDiscount
				,SUM(tmpAPPrepaidPayables.dblInterest) AS dblInterest
				,CAST((SUM(tmpAPPrepaidPayables.dblTotal) + SUM(tmpAPPrepaidPayables.dblInterest) - SUM(tmpAPPrepaidPayables.dblAmountPaid) - SUM(tmpAPPrepaidPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM ('
					+ @prepaidInnerQuery +
				') tmpAPPrepaidPayables 
			GROUP BY intBillId, intPrepaidRowType
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBill A
		ON A.intBillId = tmpAgingSummaryTotal.intBillId
		LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = A.[intEntityVendorId]
		LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
		LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C.intEntityClassId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
		UNION ALL --voided deleted voucher
		SELECT
		A.dtmDate
		,A.dtmDueDate
		,B.strVendorId
		,C.strName as strVendorName
		,B.[intEntityId] as intEntityVendorId
		,A.intBillId
		,A.strBillId
		,A.intAccountId
		,D.strAccountId
		,EC.strClass
		,(CASE WHEN ' + @ysnFilter + ' = 1 THEN ''As Of'' ELSE ''All Dates'' END ) as strDateDesc
		, '+ @dtmDateFilter +' as dtmDateFilter
		,tmpAgingSummaryTotal.dblTotal
		,tmpAgingSummaryTotal.dblAmountPaid
		,tmpAgingSummaryTotal.dblDiscount
		,tmpAgingSummaryTotal.dblInterest
		,tmpAgingSummaryTotal.dblAmountDue
		,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + '' - '' + isnull(C.strName,'''')) as strVendorIdName 
		,(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup) as strCompanyName
		,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
		,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 THEN 0 
				ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 0
				ELSE DATEDIFF(dayofyear,A.dtmDueDate,GETDATE()) END AS intAging
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblCurrent
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=10 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl0
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>10 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl1 
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl30
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl60
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
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
				,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM ('
					+ @deletedQuery +
				') tmpAPPayables 
			GROUP BY intBillId
			HAVING SUM(DISTINCT intCount) > 1 --DO NOT INCLUDE DELETED REPORT IF THAT IS ONLY THE PART OF DELETED DATA
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBillArchive A
		ON A.intBillId = tmpAgingSummaryTotal.intBillId
		LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = A.[intEntityVendorId]
		LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
		LEFT JOIN dbo.tblSMTerm T ON A.intTermsId = T.intTermID
		LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C.intEntityClassId
		LEFT JOIN vyuAPVoucherCommodity F ON F.intBillId = tmpAgingSummaryTotal.intBillId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
		UNION ALL
		SELECT
		A.dtmDate
		,A.dtmDueDate
		,B.strVendorId
		,C.strName as strVendorName
		,B.intEntityId as intEntityVendorId
		,A.intInvoiceId
		,A.strInvoiceNumber
		,A.intAccountId
		,D.strAccountId
		,EC.strClass
		,(CASE WHEN ' + @ysnFilter + ' = 1 THEN ''As Of'' ELSE ''All Dates'' END ) as strDateDesc
		, '+ @dtmDateFilter +' as dtmDateFilter
		,tmpAgingSummaryTotal.dblTotal
		,tmpAgingSummaryTotal.dblAmountPaid
		,tmpAgingSummaryTotal.dblDiscount
		,tmpAgingSummaryTotal.dblInterest
		,tmpAgingSummaryTotal.dblAmountDue
		,dbo.fnTrim(ISNULL(B.strVendorId,'''') + '' - '' + isnull(C.strName,'''')) as strVendorIdName 
		,(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup) as strCompanyName
		,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
		,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 THEN 0 
				ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 0
				ELSE DATEDIFF(dayofyear,A.dtmDueDate,GETDATE()) END AS intAging
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblCurrent
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=10 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl0
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>10 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl1 
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl30 
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl60
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
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
			intInvoiceId
			,SUM(tmpAPPayables.dblTotal) AS dblTotal
			,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
			,SUM(tmpAPPayables.dblInterest) AS dblInterest
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (' 
					+ @arQuery +
				') tmpAPPayables
			GROUP BY intInvoiceId
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblARInvoice A
		ON A.intInvoiceId = tmpAgingSummaryTotal.intInvoiceId
		LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = A.[intEntityCustomerId]
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId
		LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C.intEntityClassId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
		AND D.strAccountCategory = ''AP Account''
) SubQuery
	GROUP BY 
		intEntityVendorId
		,strVendorId
		,strVendorName
		,strVendorIdName
		,strCompanyName
		,strCompanyAddress
		,strClass
		,strDateDesc
		,dtmDateFilter
	) MainQuery 
'

IF @dateTo IS NOT NULL
BEGIN
	SET @query = REPLACE(@query, 'GETDATE()', '''' + CONVERT(VARCHAR(10), @dateTo, 110) + '''');
END

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

--PRINT @filter
--PRINT @query

EXEC sp_executesql @query
