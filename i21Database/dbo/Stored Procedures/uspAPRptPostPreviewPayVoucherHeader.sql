CREATE PROCEDURE [dbo].[uspAPRptPostPreviewPayVoucherHeader]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @query NVARCHAR(MAX);
DECLARE @intIds NVARCHAR(MAX);
DECLARE @intUserId INT = 0;

--Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL
--Add this so that XtraReports have fields to get
SELECT
	0 AS intPaymentId,
    NULL AS strPaymentRecordNum,
    NULL AS strPeriod,
    NULL AS strName,
	NULL AS strPrintedBy
	RETURN
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

IF EXISTS(SELECT 1 FROM @temp_xml_table)
 BEGIN
	SELECT @intUserId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intUserId'
 END

SET @query = '
				SELECT
				P.intPaymentId,
				P.strPaymentRecordNum,
				FORMAT(FP.dtmStartDate, ''yyyy'') + FORMAT(FP.dtmStartDate, ''MM'') AS strPeriod,
				E.strName,
				EM.strName AS strPrintedBy
				FROM tblAPPayment P
				JOIN dbo.tblGLFiscalYearPeriod FP ON P.dtmDatePaid BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR P.dtmDatePaid = FP.dtmStartDate OR P.dtmDatePaid = FP.dtmEndDate
				JOIN (tblAPVendor V JOIN tblEMEntity E ON V.intEntityId = E.intEntityId) ON V.intEntityId = P.intEntityVendorId
				LEFT JOIN tblEMEntity EM ON EM.intEntityId = ' + CAST(@intUserId AS VARCHAR) + '
			' 

 IF EXISTS(SELECT 1 FROM @temp_xml_table)
 BEGIN
	SELECT @intIds = [from] FROM @temp_xml_table WHERE [fieldname] = 'intPaymentId'
    SET @query = @query + ' WHERE P.intPaymentId IN (' + @intIds + ')'
 END
 ELSE
 BEGIN
    SET @query = @query + ' WHERE P.intPaymentId = -1'
 END

EXEC sp_executesql @query