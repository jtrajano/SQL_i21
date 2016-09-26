CREATE PROCEDURE [dbo].[uspAPRptCheckRegister]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @query NVARCHAR(MAX), 
	    @innerQuery NVARCHAR(MAX), 
		@filter NVARCHAR(MAX) = '';
DECLARE @dateFrom DATETIME = NULL;
DECLARE @dateTo DATETIME = NULL;
DECLARE @dtmDateTo DATETIME = NULL;
DECLARE @dtmDate DATETIME ;
DECLARE @total NUMERIC(18,6), 
		@amountDue NUMERIC(18,6), 
		@amountPad NUMERIC(18,6);
DECLARE @count INT = 0;
DECLARE @fieldname NVARCHAR(MAX)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @from NVARCHAR(MAX)
DECLARE @to NVARCHAR(MAX)
DECLARE @join NVARCHAR(10)
DECLARE @begingroup NVARCHAR(50)
DECLARE @endgroup NVARCHAR(50)
DECLARE @datatype NVARCHAR(50)

	-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
--Add this so that XtraReports have fields to get
	SELECT 

	0 AS ysnCheckVoid,
	0 AS ysnClr,
	NULL AS strSystem,
	0 AS intBankId,
	NULL AS strBankTransactionTypeName,
	NULL AS dtmClearedDate,
	0 AS dblDiscount,
	0 AS dblWithheldAmount,
	0 AS dblAmount,
	NULL AS strCbkNo,
	NULL AS strNotes,
	NULL AS dtmDate,
	NULL AS chkNo,
	NULL AS strPayee,
	NULL AS strBankName,			
	NULL AS strCompanyAddress,
	NULL AS strCompanyName

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
SELECT @dateFrom = [from], @dateTo = [to] FROM @temp_xml_table WHERE [fieldname] = 'dtmClearedDate';
SELECT @dtmDate = [from], @dtmDateTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
SET @innerQuery = 
		'SELECT 
			ysnCheckVoid,
			ysnClr,
			strSystem,
			intBankId,
			strBankTransactionTypeName,
			dtmClearedDate,
			dblDiscount,
			dblWithheldAmount,
			dblAmount,
			strCbkNo,
			strNotes,
			dtmDate,
			chkNo,
			strPayee,
			strBankName,			
			(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress,
			(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup) as strCompanyName
		FROM dbo.vyuAPRptCheckRegister'

IF @dateFrom IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmClearedDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
		SET @dateTo = GETDATE();
	END
    ELSE 
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmClearedDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
		SET @dateTo = @dateTo;
	END  
END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmClearedDate'

IF @dtmDate IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + ''''
		SET @dateTo = GETDATE();
	END
    ELSE 
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dtmDateTo, 110) + ''''	
		SET @dateTo = @dtmDateTo;
	END  
	SET @dateFrom = CONVERT(VARCHAR(10), @dtmDate, 110)
END
ELSE
BEGIN
	SET @dateFrom = CONVERT(VARCHAR(10), '1/1/1900', 110)
	SET @dateTo = GETDATE();
END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'

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

SET @query = 
'SELECT * FROM (
	(' 	+ @innerQuery + ')  
) MainQuery'

SET @query = REPLACE(@query, 'GETDATE()', '''' + CONVERT(VARCHAR(10), @dateTo, 110) + '''');

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

--PRINT @filter
--PRINT @query

EXEC sp_executesql @query

GO