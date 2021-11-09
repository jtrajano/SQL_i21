CREATE PROCEDURE [dbo].[uspApiSchemaTRTransformCustomerFreight]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @tmpFreightType TABLE (
		strFreightType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	)

	INSERT INTO @tmpFreightType (strFreightType) VALUES ('Rate')
	INSERT INTO @tmpFreightType (strFreightType) VALUES ('Miles')
	INSERT INTO @tmpFreightType (strFreightType) VALUES ('Amount')

	-- VALIDATE Customer Name
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Customer Name'
		, strValue = CF.strCustomerName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Cannot find the Customer Name ''' + CF.strCustomerName + ''' in i21 Customers'
	FROM tblApiSchemaTRCustomerFreight CF
	LEFT JOIN tblEMEntity E ON E.strName = CF.strCustomerName
	LEFT JOIN tblARCustomer C ON C.intEntityId = E.intEntityId
	WHERE C.intEntityId IS NULL 
	AND CF.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Tariff Type
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Tariff Type'
		, strValue = CF.strTariffType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Cannot find the Tariff Type ''' + CF.strTariffType + ''' in i21 Tariff types'
	FROM tblApiSchemaTRCustomerFreight CF
	LEFT JOIN tblEMEntityTariffType T ON T.strTariffType = CF.strTariffType
	WHERE T.intEntityTariffTypeId IS NULL 
	AND CF.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Customer Location
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Customer Location'
		, strValue = CF.strCustomerLocation
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Cannot find the Customer Location ''' + CF.strCustomerLocation + ''' in i21 Customer Locations'
	FROM tblApiSchemaTRCustomerFreight CF
	LEFT JOIN tblEMEntity E ON E.strName = CF.strCustomerName
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = CF.strCustomerLocation
	WHERE EL.intEntityLocationId IS NULL 
	AND CF.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Category
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Category'
		, strValue = CF.strCategory
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Cannot find the Category ''' + CF.strCategory + ''' in i21 Categories'
	FROM tblApiSchemaTRCustomerFreight CF
	LEFT JOIN tblICCategory C ON C.strCategoryCode = CF.strCategory
	WHERE C.intCategoryId IS NULL 
	AND CF.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Freight Type
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Freight Type'
		, strValue = CF.strFreightType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Cannot find the Freight Type ''' + CF.strFreightType + ''' in i21 Freight Types'
	FROM tblApiSchemaTRCustomerFreight CF
	LEFT JOIN @tmpFreightType F ON F.strFreightType = CF.strFreightType
	WHERE F.strFreightType IS NULL 
	AND CF.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Ship Via
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Ship Via Name'
		, strValue = CF.strShipViaName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Cannot find the Ship Via Name ''' + CF.strShipViaName + ''' in i21 Ship Via'
	FROM tblApiSchemaTRCustomerFreight CF
	LEFT JOIN tblSMShipVia S ON S.strShipVia = CF.strShipViaName
	WHERE S.intEntityId IS NULL 
	AND ISNULL(CF.strShipViaName, '') != ''
	AND CF.guiApiUniqueId = @guiApiUniqueId

	-- CHECK IF ALREADY EXISTS IN CUSTOMER SETUP
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = ''
		, strValue = CF.strCustomerName + ', ' + CF.strTariffType + ', ' + CF.strCustomerLocation + ', ' + CF.strCategory + ', ' + CF.strFreightType + ', ' + ISNULL(CF.strShipViaName, '')
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Data is already existing in i21 Customer Freight'	
	FROM tblApiSchemaTRCustomerFreight CF
	INNER JOIN tblEMEntity E ON E.strName = CF.strCustomerName
	INNER JOIN tblARCustomer C ON C.intEntityId = E.intEntityId
	INNER JOIN tblEMEntityTariffType T ON T.strTariffType = CF.strTariffType
	INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = CF.strCustomerLocation
	INNER JOIN tblICCategory CA ON CA.strCategoryCode = CF.strCategory
	INNER JOIN @tmpFreightType F ON F.strFreightType = CF.strFreightType
	LEFT JOIN tblSMShipVia S ON S.strShipVia = CF.strShipViaName
	LEFT JOIN tblARCustomerFreightXRef CFX ON CFX.intEntityCustomerId = C.intEntityId 
		AND CFX.intEntityLocationId = EL.intEntityLocationId
		AND CFX.strZipCode = CF.strSupplierZipCode 
		AND CFX.intCategoryId = CA.intCategoryId
		AND CFX.strFreightType = F.strFreightType
		AND ISNULL(CFX.intShipViaId, 0) = ISNULL(S.intEntityId, 0)
	WHERE (ISNULL(CF.strShipViaName, '') = '' OR (S.intEntityId IS NOT NULL AND ISNULL(CF.strShipViaName, '') != '')) 
	AND CF.guiApiUniqueId = @guiApiUniqueId
	AND CFX.intFreightXRefId IS NOT NULL


	-- PROCESS
	INSERT INTO tblARCustomerFreightXRef (intEntityCustomerId
		, intEntityLocationId
		, strZipCode
		, intCategoryId
		, ysnFreightOnly
		, strFreightType
		, intShipViaId
		, dblFreightAmount
		, dblFreightRate
		, dblFreightMiles
		, ysnFreightInPrice
		, dblMinimumUnits
		, intConcurrencyId
		, guiApiUniqueId)
	SELECT C.intEntityId
		, EL.intEntityLocationId
		, CF.strSupplierZipCode
		, CA.intCategoryId
		, CF.ysnFreightOnly
		, F.strFreightType
		, S.intEntityId
		, CF.dblFreightAmount
		, CF.dblFreightRate
		, CF.dblFreightMile
		, CF.ysnFreightInPrice
		, CF.dblMinimumUnit
		, 1
		, CF.guiApiUniqueId
	FROM tblApiSchemaTRCustomerFreight CF
		INNER JOIN tblEMEntity E ON E.strName = CF.strCustomerName
		INNER JOIN tblARCustomer C ON C.intEntityId = E.intEntityId
		INNER JOIN tblEMEntityTariffType T ON T.strTariffType = CF.strTariffType
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = CF.strCustomerLocation
		INNER JOIN tblICCategory CA ON CA.strCategoryCode = CF.strCategory
		INNER JOIN @tmpFreightType F ON F.strFreightType = CF.strFreightType
		LEFT JOIN tblSMShipVia S ON S.strShipVia = CF.strShipViaName
		LEFT JOIN tblARCustomerFreightXRef CFX ON CFX.intEntityCustomerId = C.intEntityId 
			AND CFX.intEntityLocationId = EL.intEntityLocationId
			AND CFX.strZipCode = CF.strSupplierZipCode 
			AND CFX.intCategoryId = CA.intCategoryId
			AND CFX.strFreightType = F.strFreightType
			AND ISNULL(CFX.intShipViaId, 0) = ISNULL(S.intEntityId, 0)
		WHERE CF.guiApiUniqueId = @guiApiUniqueId
		AND (ISNULL(CF.strShipViaName, '') = '' OR (S.intEntityId IS NOT NULL AND ISNULL(CF.strShipViaName, '') != ''))
		AND CFX.intFreightXRefId IS NULL

END

