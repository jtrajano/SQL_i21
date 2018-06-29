CREATE PROCEDURE uspLGGetInvoiceIdealReport 
	@xmlParam NVARCHAR(MAX) = NULL
AS
DECLARE @intInvoiceId INT
DECLARE @xmlDocumentId INT
DECLARE @strUserName NVARCHAR(100)
DECLARE @intLoadId INT
DECLARE @strCompanyName NVARCHAR(100)
	,@strCompanyAddress NVARCHAR(100)
	,@strContactName NVARCHAR(50)
	,@strCounty NVARCHAR(25)
	,@strCity NVARCHAR(25)
	,@strState NVARCHAR(50)
	,@strZip NVARCHAR(12)
	,@strCountry NVARCHAR(25)
	,@strPhone NVARCHAR(50)
	,@ysnPrintLogo BIT

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

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

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
	,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

SELECT @intInvoiceId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intInvoiceId'

SELECT TOP 1 @ysnPrintLogo = ISNULL(ysnPrintLogo, 0)
FROM tblLGCompanyPreference

SELECT TOP 1 @strCompanyName = strCompanyName
	,@strCompanyAddress = strAddress
	,@strContactName = strContactName
	,@strCounty = strCounty
	,@strCity = strCity
	,@strState = strState
	,@strZip = strZip
	,@strCountry = strCountry
	,@strPhone = strPhone
FROM tblSMCompanySetup

SELECT @strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strContactName AS strCompanyContactName
	,@strCounty AS strCompanyCounty
	,@strCity AS strCompanyCity
	,@strState AS strCompanyState
	,@strZip AS strCompanyZip
	,@strCountry AS strCompanyCountry
	,@strPhone AS strCompanyPhone
	,@strCity + ', ' + @strState + ', ' + @strZip + ', ' AS strCityStateZip
	,@strCity + ', '+ CONVERT(NVARCHAR,GETDATE(),106) AS strCityAndDate
	,INV.intInvoiceId
	,INV.strInvoiceNumber
	,strCustomer = EN.strName
	,INV.strBillToAddress
	,INV.strBillToCity
	,INV.strBillToState
	,INV.strBillToZipCode
	,INV.strBillToCity + ', ' + INV.strBillToState + ', ' + INV.strBillToZipCode AS strCityStateZip
	,INV.strBillToCountry
	,dblTotalAmount = 384.00
	,strAmountCurrency = 'EURO'
	,strAmountInfo = 'EURO' + ' ' + LTRIM(384.00)
	,dtmCommissionReceiveDate = GETDATE()
	,dbo.fnSMGetCompanyLogo('FullHeaderLogo') AS blbFullHeaderLogo
	,dbo.fnSMGetCompanyLogo('FullFooterLogo') AS blbFullFooterLogo
	,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
	,dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo
	,CUS.strVatNumber
FROM tblARInvoice INV 
LEFT JOIN tblARCustomer CUS ON CUS.intEntityId = INV.intEntityCustomerId
LEFT JOIN tblEMEntity EN ON EN.intEntityId = INV.intEntityCustomerId
WHERE INV.intInvoiceId = @intInvoiceId