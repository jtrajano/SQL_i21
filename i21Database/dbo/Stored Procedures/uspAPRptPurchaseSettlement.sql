CREATE PROCEDURE [dbo].uspAPRptPurchaseSettlement
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON  

DECLARE @query NVARCHAR(MAX), @innerQuery NVARCHAR(MAX), @filter NVARCHAR(MAX) = '';
DECLARE @dtmBillDate DATETIME = NULL;
DECLARE @dateFrom DATETIME = NULL;
DECLARE @dateTo DATETIME = NULL;
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

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
	SELECT * FROM vyuAPRptPurchaseCustomerSettlement WHERE intTransactionId = 0 --RETURN NOTHING TO RETURN SCHEMA
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
SELECT @dateFrom = [from], @dateTo = [to], @condition = [condition] FROM @temp_xml_table WHERE [fieldname] = 'dtmDatePaid';
SELECT @dtmBillDate = [from], @dateTo = [to], @condition = [condition] FROM @temp_xml_table WHERE [fieldname] = 'dtmBillDate'; 
IF @dateFrom IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = ' DATEADD(dd, DATEDIFF(dd, 0,dtmDatePaid), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQuery = ' DATEADD(dd, DATEDIFF(dd, 0,dtmDatePaid), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
	END  
END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDatePaid'

IF @dtmBillDate IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery =  ' DATEADD(dd, DATEDIFF(dd, 0,dtmBillDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmBillDate, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQuery =  ' DATEADD(dd, DATEDIFF(dd, 0,dtmBillDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmBillDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
	END  
END
DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmBillDate'
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

SET @query = 'SELECT  transactions.* FROM 
				  (SELECT intBankAccountId ,
					intTransactionId ,
					strTransactionId ,
					strCompanyName ,
					strCompanyAddress ,
					strItemNo ,
					strCommodity ,
					dtmPaymentDate ,
					strAccountNumber ,
					strCheckNo ,
					strVendorName ,
					strVendorAddress ,
					intTicketId ,
					strTicketNumber ,
					strReceiptNumber ,
					intInventoryReceiptItemId ,
					RecordId ,
					strSourceType ,
					strSplitNumber ,
					strCustomerReference ,
					strTicketComment ,
					strFarmField ,
					dtmBillDate ,
					dblGrossWeight ,
					dblTareWeight ,
					dblNetWeight ,
					dblCost ,
					Net ,
					strUnitMeasure ,
					dblTotal ,
					dblTax ,
					strContractNumber ,
					TotalDiscount ,
					NetDue ,
					strId ,
					intPaymentId ,
					CheckAmount ,
					IsAdjustment
					FROM 
				 [vyuAPRptPurchaseCustomerSettlement]
			 WHERE strTicketNumber IS NOT NULL)
			 transactions'

	  
IF ISNULL(@innerQuery,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @innerQuery
END

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + (CASE WHEN ISNULL(@innerQuery,'') != '' THEN ' AND ' ELSE ' WHERE ' END) + @filter
END
PRINT @filter
PRINT @query
EXEC sp_executesql @query