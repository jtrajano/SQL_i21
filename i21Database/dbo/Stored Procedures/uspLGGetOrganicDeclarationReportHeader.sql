CREATE PROCEDURE uspLGGetOrganicDeclarationReportHeader
	@xmlParam NVARCHAR(MAX) = NULL  
AS
	DECLARE @intLoadId INT
	DECLARE @xmlDocumentId INT 
	DECLARE @strUserName NVARCHAR(100)

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

	SELECT	@intLoadId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intLoadId' 
 
	SELECT	@strUserName = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strUserName' 

SELECT E.intEntityId
	,E.strName AS strCustomerName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,E.strName  + CHAR(13) +  
	 EL.strAddress + CHAR(13) +  
	 EL.strZipCode + ' ' + EL.strCity + CHAR(13) + 
	 EL.strState + ' ' + EL.strCountry AS strBuyerFullAddress
	,E.strName  + CHAR(13) +  
	 EL.strAddress + CHAR(13) +  
	 EL.strZipCode + ' ' + EL.strCity + CHAR(13) + 
	 EL.strState + ' ' + EL.strCountry AS strDeliveryAddress
	,LOAD.intSCompanyLocationId
	,LOAD.intCustomerEntityId
	,LOAD.intCustomerEntityLocationId
	,LOAD.intLoadId
	,LOAD.strLoadNumber
	,CL.strLocationName
	,CL.strAddress
	,CL.strZipPostalCode
	,CL.strCity
	,CL.strStateProvince
	,CL.strCountry
	,CL.strLocationName + CHAR(13) +  
	 CL.strAddress + CHAR(13) +  
	 CL.strZipPostalCode + ' ' + CL.strCity + CHAR(13) +  
	 CL.strStateProvince + ' ' + CL.strCountry AS strSupplierFullAddress
	,'( ' + @strUserName + ' )' AS strUserName
	,dbo.fnSMGetCompanyLogo('OrganicDeclarationHeader') AS blbHeaderLogo
	,dbo.fnSMGetCompanyLogo('OrganicDeclarationFooter') AS blbFooterLogo
	,'015611' AS strCompanyNumberSupplier
	,'Skal (NL-BIO-01), Zwolle, Netherlands' AS strAuthoritySupplier
FROM tblEMEntity E
JOIN (
	SELECT TOP 1 LD.intSCompanyLocationId
		,LD.intCustomerEntityId
		,LD.intCustomerEntityLocationId
		,L.intLoadId
		,L.strLoadNumber
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	WHERE L.intLoadId = @intLoadId
	) LOAD ON LOAD.intCustomerEntityId = E.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ISNULL(LOAD.intCustomerEntityLocationId,E.intDefaultLocationId)
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LOAD.intSCompanyLocationId