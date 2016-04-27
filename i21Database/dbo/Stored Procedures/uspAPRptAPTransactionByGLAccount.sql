﻿CREATE PROCEDURE [dbo].[uspAPRptAPTransactionByGLAccount]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--exec "dbo"."uspAPRptAPTransactionByGLAccount" @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>strBillId</fieldname>
--<condition>Equal To</condition><from>BL-4</from><join /><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>strVendorIdName</fieldname>
--<condition>Equal To</condition><from>0001005025 - Mercury Payment Systems</from><join /><begingroup /><endgroup /><datatype>String</datatype></filter></filters></xmlparam>'

--exec "dbo"."uspAPRptAPTransactionByGLAccount" @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmBillDate</fieldname>
--<condition>Equal To</condition><from>01/31/2015</from><join /><begingroup /><endgroup /><datatype>DateTime</datatype></filter></filters></xmlparam>'

-- Sample XML string structure:
--exec "dbo"."uspAPRptAPTransactionByGLAccount" @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmBillDate</fieldname>
--<condition>Between</condition><from>05/13/2015</from><to>05/14/2015</to><join /><begingroup /><endgroup /><datatype>DateTime</datatype></filter></filters></xmlparam>'

--exec "dbo"."uspAPRptAPTransactionByGLAccount" @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlRparam><filters><filter><fieldname>dblTotal</fieldname>
--<condition>Equal To</condition><from>91.00</from><join /><begingroup /><endgroup /><datatype>Int 32</datatype></filter></filters></xmlparam>'

--exec "dbo"."uspAPRptAPTransactionByGLAccount" @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dblTotal</fieldname>
--<condition>Equal To</condition><from>91.000000</from><join /><begingroup /><endgroup /><datatype>Decimal</datatype></filter></filters></xmlparam>'

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
	SELECT *, NULL AS strCorrected FROM vyuAPRptAPTransactionByGLAccount WHERE strBillId = '' --RETURN NOTHING TO RETURN SCHEMA
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
SELECT @dateFrom = [from], @dateTo = [to], @condition = [condition] FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
SELECT @dtmBillDate = [from], @dateTo = [to], @condition = [condition] FROM @temp_xml_table WHERE [fieldname] = 'dtmBillDate'; 
IF @dateFrom IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery = ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQuery = ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
	END  
END

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'

IF @dtmBillDate IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQuery =  ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmBillDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmBillDate, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQuery =  ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmBillDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmBillDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
	END  
END
DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmBillDate'

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

SET @query = 'SELECT [intEntityVendorId]
      ,[strMainCompanyName]
      ,[intTransactionId]
      ,[strVendorID]
      ,[strVendorIdName]
      ,[strCompanyName]
      ,[strVendorOrderNumber]
      ,[strInvoiceNumber]
      ,[strBillId]
      ,[strAccountID]
      ,[strDescription]
      ,[strAccount]
      ,[strTerms]
      ,[strReference]
      ,[strBillBatchNumber]
      ,[dtmBillDate]
      ,[dtmDate]
      ,[dtmDueDate]
      ,[dblAmountDue]
      ,[dblInterest]
      ,[dblWithheld]
      ,[dblDiscount]
      ,[dblTotal]
      ,[strTransactionType]
      ,[dblAmountPaid]
      ,[dblCost]
      ,[strTaxCode]
      ,[ysnPaid] FROM [vyuAPRptAPTransactionByGLAccount]'


IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

IF ISNULL(@innerQuery,'') != ''
BEGIN
	SET @query = @query + @innerQuery
END
PRINT @filter
PRINT @query
EXEC sp_executesql @query
GO