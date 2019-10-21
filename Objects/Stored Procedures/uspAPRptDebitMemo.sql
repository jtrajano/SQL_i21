CREATE PROCEDURE [dbo].[uspAPRptDebitMemo]
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
DECLARE @total NUMERIC(18,6), 
		@amountDue NUMERIC(18,6), 
		@amountPad NUMERIC(18,6);
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
DECLARE @billId INT;
	-- Sanitize the @xmlParam 
IF ISNULL(@xmlParam,'') = '' 
BEGIN
--SET @xmlParam = NULL 
--Add this so that XtraReports have fields to get
	SELECT 
		'' AS strCompanyName,
		'' AS strCompanyAddress,
		'' AS strShipFrom,
		'' AS strShipTo,
		'' AS strBillId,
		'' AS strAccountId,
		'' AS strContractNumber,
		'' AS strMiscDescription,
		'' AS strUnitMeasure,
		'' AS strCostUOM,
		'' AS strCurrency,
		'' AS strContactName,
		'' AS strContactEmail,
		'' AS strBillOfLading,
		'' AS strItemNo,
		'' AS strLPlant,
		'' AS strCountryOrigin,
		'' AS strERPPONumber,
		'' AS strDateLocation,
		'' AS strFooter,
		'' AS strBankName,
		'' AS strBankAccountHolder,
		'' AS strIBAN,
		'' AS strSWIFT,
		'' AS strTerm,
		'' AS strRemarks,
		'' AS strBankAddress,
		0 AS intBillId,
		0 AS intContractSeq,
		0 AS intUnitOfMeasureId,
		0 AS intCostUOMId,
		0.0 AS dblCost,
		0.0 AS dblTotal,
		0.0 AS dblQtyReceived
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

SET @query = 
		'SELECT 
			*
		FROM dbo.vyuAPRptDebitMemo'

--WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
--BEGIN
--	SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table
--	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
--	DELETE FROM @temp_xml_table WHERE id = @id
--	IF EXISTS(SELECT 1 FROM @temp_xml_table)
--	BEGIN
--		SET @filter = @filter + ' AND '
--	END
--END

IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@billId = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'intBillId'
END

SELECT 
*
FROM dbo.vyuAPRptDebitMemo
WHERE intBillId = (CASE WHEN @billId IS NOT NULL THEN @billId ELSE 0 END)

--IF ISNULL(@filter,'') != ''
--BEGIN
--	SET @query = @query + ' WHERE ' + @filter
--END

----PRINT @filter
----PRINT @query

--EXEC sp_executesql @query