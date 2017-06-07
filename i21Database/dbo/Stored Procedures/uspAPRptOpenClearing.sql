CREATE PROCEDURE [dbo].[uspAPRptOpenClearing]
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
DECLARE @total NUMERIC(18,6),
		@amountDue NUMERIC(18,6), 
		@amountPad NUMERIC(18,6);
DECLARE @count INT = 0;
DECLARE @fieldname NVARCHAR(50)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @strBillId NVARCHAR(50) 
DECLARE @strAccountId NVARCHAR(50) 
DECLARE @strVendorIdName NVARCHAR(150) 
DECLARE @strVendorId NVARCHAR(50)
DECLARE @strReceiptNumber NVARCHAR(50)
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
BEGIN
--SET @xmlParam = NULL 
--Add this so that XtraReports have fields to get
	SELECT 
		0 AS intInventoryReceiptId,
		NULL AS dtmReceiptDate,
		NULL AS strReceiptNumber,
		NULL AS strBillOfLading,
		NULL AS strOrderNumber,
		NULL AS dtmDate,
		NULL AS dtmDueDate,
		NULL AS strVendorId,
		0 AS intEntityVendorId,
		0 AS intBillId,
		NULL AS strBillId,
		NULL AS strVendorOrderNumber,
		NULL AS strTerm,
		NULL AS strCompanyAddress,
		NULL AS strCompanyName,
		NULL AS strAccountId,
		NULL AS strVendorIdName,
		NULL AS strAge,
		0 AS intAccountId,
		0 AS dblVoucherAmount,
		0 AS dblTotal,
		0 AS dblAmountPaid,
		0 AS dblDiscount,
		0 AS dblInterest,
		0 AS dblAmountDue,
		0 AS dblCurrent,
		0 AS dbl1,
		0 AS dbl30,
		0 AS dbl60,
		0 AS dbl90,
		0 AS intAging,
		0 AS dblQtyToReceive,
		0 AS dblQtyVouchered,
		0 AS dblQtyToVoucher,
		0 AS dblAmountToVoucher,
		0 AS dblChargeAmount
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
SELECT @dateFrom = [from], @dateTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmReceiptDate';
SELECT @dtmDate = [from], @dtmDateTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
SET @innerQuery = 'SELECT DISTINCT
						intInventoryReceiptId
						,strBillId
						,intBillId
						,strVendorIdName
						,dblTotal
						,dblVoucherAmount
						,dblAmountDue
						,dblAmountPaid
						,dblDiscount
						,dblInterest
						,dtmDate
						,dtmDueDate
						,dtmReceiptDate
						,dblQtyToReceive
						,dblQtyVouchered
						,dblQtyToVoucher
						,dblAmountToVoucher
						,dblChargeAmount
						,strContainer
						,strVendorId
						,strOrderNumber
						,strTerm
				  FROM dbo.vyuAPClearables'

IF @dateFrom IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmReceiptDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmReceiptDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
	END  
END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmReceiptDate'

IF @dtmDate IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQuery = @innerQuery + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dtmDateTo, 110) + ''''	
	END  
	SET @dateFrom = CONVERT(VARCHAR(10), @dtmDate, 110)
	SET @dateTo = @dtmDateTo;
END
ELSE
BEGIN
	SET @dateFrom = CONVERT(VARCHAR(10), '1/1/1900', 110)
	SET @dateTo = GETDATE();
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

	 SELECT @strReceiptNumber = [fieldname], 
		   @from = [from], 
		   @to = [to], 
		   @join = [join], 
		   @datatype = [datatype] 
	FROM @temp_xml_table WHERE [fieldname] = 'strReceiptNumber';
	IF @strReceiptNumber IS NOT NULL
	BEGIN
		SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strReceiptNumber, @condition, @from, @to, @join, null, null, @datatype)				  
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
	 DISTINCT
	 IR.intInventoryReceiptId
	,IR.dtmReceiptDate
	,IR.strReceiptNumber
	,IR.strBillOfLading
	,tmpAgingSummaryTotal.strOrderNumber AS strOrderNumber
	,tmpAgingSummaryTotal.dtmDate
	,tmpAgingSummaryTotal.dtmDueDate
	,tmpAgingSummaryTotal.strVendorId
	,tmpAgingSummaryTotal.intBillId
	,tmpAgingSummaryTotal.strBillId
	,tmpAgingSummaryTotal.strTerm
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup) as strCompanyName
	,tmpAgingSummaryTotal.dblVoucherAmount
	,tmpAgingSummaryTotal.dblTotal
	,tmpAgingSummaryTotal.dblAmountPaid
	,ISNULL(tmpAgingSummaryTotal.dblAmountDue,0) as dblAmountDue
	,ISNULL(tmpAgingSummaryTotal.strVendorIdName,'''') as strVendorIdName 
	,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 
		THEN 0 
		ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
	,CASE WHEN DATEDIFF(dayofyear,tmpAgingSummaryTotal.dtmReceiptDate,GETDATE())<=0 
		THEN 0
		ELSE ISNULL(DATEDIFF(dayofyear,tmpAgingSummaryTotal.dtmReceiptDate,GETDATE()),0) END AS intAging
	,CASE WHEN DATEDIFF(dayofyear,tmpAgingSummaryTotal.dtmDueDate,GETDATE())<=0 
		THEN tmpAgingSummaryTotal.dblAmountDue 
		ELSE 0 END AS dblCurrent
	 ,tmpAgingSummaryTotal.dblQtyToReceive
	 ,tmpAgingSummaryTotal.dblQtyVouchered
	 ,tmpAgingSummaryTotal.dblQtyToVoucher
	 ,tmpAgingSummaryTotal.dblAmountToVoucher
	 ,tmpAgingSummaryTotal.dblChargeAmount
	 ,tmpAgingSummaryTotal.strContainer
	FROM  
	(
		SELECT DISTINCT
		 tmpAPClearables.intInventoryReceiptId
		,tmpAPClearables.intBillId
		,tmpAPClearables.strBillId
		,tmpAPClearables.strVendorIdName
		,tmpAPClearables.strOrderNumber
		,tmpAPClearables.strContainer
		,tmpAPClearables.strVendorId
		,tmpAPClearables.dtmDate
		,tmpAPClearables.dtmDueDate
		,tmpAPClearables.strTerm
		,tmpAPClearables.dtmReceiptDate
		,SUM(tmpAPClearables.dblVoucherAmount) as dblVoucherAmount
		,SUM(tmpAPClearables.dblTotal) AS dblTotal
		,SUM(tmpAPClearables.dblAmountPaid) AS dblAmountPaid
		,SUM(tmpAPClearables.dblAmountDue) AS dblAmountDue
		,SUM(tmpAPClearables.dblQtyToReceive) AS dblQtyToReceive
		,SUM(tmpAPClearables.dblQtyVouchered) AS dblQtyVouchered
		,SUM(tmpAPClearables.dblQtyToVoucher) AS dblQtyToVoucher
		,SUM(tmpAPClearables.dblAmountToVoucher) AS dblAmountToVoucher
		,SUM(tmpAPClearables.dblChargeAmount) AS dblChargeAmount
		FROM ('
				+ @innerQuery +
			   ') tmpAPClearables 
		GROUP BY intInventoryReceiptId,intBillId, dblAmountDue,strVendorIdName,strContainer,
				 strVendorId, strBillId ,strOrderNumber,dtmDate,dtmDueDate,dtmReceiptDate,strTerm
	) AS tmpAgingSummaryTotal
	INNER JOIN vyuICGetInventoryReceipt IR
		ON IR.intInventoryReceiptId = tmpAgingSummaryTotal.intInventoryReceiptId
	--WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
) MainQuery'



SET @query = REPLACE(@query, 'GETDATE()', '''' + CONVERT(VARCHAR(10), @dateTo, 110) + '''');

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

--PRINT @filter
--PRINT @query

EXEC sp_executesql @query