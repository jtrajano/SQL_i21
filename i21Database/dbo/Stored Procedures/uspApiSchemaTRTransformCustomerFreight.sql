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
		, strField = 'Customer Entity No'
		, strValue = CF.strCustomerEntityNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CF.intRowNumber
		, strMessage = 'Cannot find the Customer Entity No ''' + CF.strCustomerEntityNo + ''' in i21 Customers'
	FROM tblApiSchemaTRCustomerFreight CF
	LEFT JOIN tblEMEntity E ON E.strEntityNo = CF.strCustomerEntityNo
	LEFT JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
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
	LEFT JOIN tblEMEntity E ON E.strEntityNo = CF.strCustomerEntityNo
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
	-- INSERT INTO tblApiImportLogDetail (
	-- 	guiApiImportLogDetailId
	-- 	, guiApiImportLogId
	-- 	, strField
	-- 	, strValue
	-- 	, strLogLevel
	-- 	, strStatus
	-- 	, intRowNo
	-- 	, strMessage
	-- )
	-- SELECT guiApiImportLogDetailId = NEWID()
	-- 	, guiApiImportLogId = @guiLogId
	-- 	, strField = ''
	-- 	, strValue = CF.strCustomerEntityNo + ', ' + CF.strTariffType + ', ' + CF.strCustomerLocation + ', ' + CF.strCategory + ', ' + CF.strFreightType + ', ' + ISNULL(CF.strShipViaName, '')
	-- 	, strLogLevel = 'Error'
	-- 	, strStatus = 'Failed'
	-- 	, intRowNo = CF.intRowNumber
	-- 	, strMessage = 'Data is already existing in i21 Customer Freight'	
	-- FROM tblApiSchemaTRCustomerFreight CF
	-- INNER JOIN tblEMEntity E ON E.strEntityNo = CF.strCustomerEntityNo
	-- INNER JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
	-- INNER JOIN tblEMEntityTariffType T ON T.strTariffType = CF.strTariffType
	-- INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = CF.strCustomerLocation
	-- INNER JOIN tblICCategory CA ON CA.strCategoryCode = CF.strCategory
	-- INNER JOIN @tmpFreightType F ON F.strFreightType = CF.strFreightType
	-- LEFT JOIN tblSMShipVia S ON S.strShipVia = CF.strShipViaName
	-- LEFT JOIN tblARCustomerFreightXRef CFX ON CFX.intEntityCustomerId = C.intEntityId 
	-- 	AND CFX.intEntityLocationId = EL.intEntityLocationId
	-- 	AND CFX.intEntityTariffTypeId = T.intEntityTariffTypeId
	-- 	AND CFX.strZipCode = CF.strSupplierZipCode 
	-- 	AND CFX.intCategoryId = CA.intCategoryId
	-- 	AND CFX.strFreightType = F.strFreightType		
	-- 	AND ISNULL(CFX.intShipViaId, 0) = ISNULL(S.intEntityId, 0)
	-- WHERE (ISNULL(CF.strShipViaName, '') = '' OR (S.intEntityId IS NOT NULL AND ISNULL(CF.strShipViaName, '') != '')) 
	-- AND CF.guiApiUniqueId = @guiApiUniqueId
	-- AND CFX.intFreightXRefId IS NOT NULL

	-- PROCESS
	DECLARE @intCustomerEntityId INT = NULL
		, @intEntityTariffTypeId INT = NULL
		, @intCustomerEntityLocationId INT = NULL
		,@strSupplierZipCode INT = NULL
		,@intCategoryId INT = NULL
		,@ysnFreightOnly BIT = NULL
		,@strFreightType NVARCHAR(100) = NULL
		,@intShipViaEntityId  INT = NULL
		,@dblFreightAmount NUMERIC (18, 6) = NULL
		,@dblFreightRate NUMERIC (18, 6) = NULL
		,@dblFreightMile NUMERIC (18, 6) = NULL
		,@ysnFreightInPrice BIT = NULL
		,@dblMinimumUnit NUMERIC (18, 6) = NULL
		,@intRowNumber INT = NULL
		,@dblFreightRateIn NUMERIC (18, 6) = NULL
		,@dblMinimumUnitsIn NUMERIC (18, 6) = NULL
		,@dblSurchargeOut NUMERIC (18, 6) = NULL

	 DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
     FOR 
	 SELECT C.intEntityId 
	 	, T.intEntityTariffTypeId
		, EL.intEntityLocationId
		, CF.strSupplierZipCode
		, CA.intCategoryId
		, ISNULL(CF.ysnFreightOnly, 0) AS ysnFreightOnly
		, F.strFreightType
		, S.intEntityId
		, CF.dblFreightAmount
		, CF.dblFreightRate
		, CF.dblFreightMile
		, ISNULL(CF.ysnFreightInPrice, 0) AS ysnFreightInPrice
		, CF.dblMinimumUnit
		, CF.dblFreightRateIn
		, CF.dblMinimumUnitsIn
		, CF.dblSurchargeOut
		, CF.intRowNumber
	FROM tblApiSchemaTRCustomerFreight CF
		INNER JOIN tblEMEntity E ON E.strEntityNo = CF.strCustomerEntityNo
		INNER JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
		INNER JOIN tblEMEntityTariffType T ON T.strTariffType = CF.strTariffType
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = CF.strCustomerLocation
		INNER JOIN tblICCategory CA ON CA.strCategoryCode = CF.strCategory
		INNER JOIN @tmpFreightType F ON F.strFreightType = CF.strFreightType
		LEFT JOIN tblSMShipVia S ON S.strShipVia = CF.strShipViaName
		LEFT JOIN tblARCustomerFreightXRef CFX ON CFX.intEntityCustomerId = C.intEntityId 
			AND CFX.intEntityLocationId = EL.intEntityLocationId
			AND CFX.intEntityTariffTypeId = T.intEntityTariffTypeId
			AND CFX.strZipCode = CF.strSupplierZipCode 
			AND CFX.intCategoryId = CA.intCategoryId
			AND CFX.strFreightType = F.strFreightType
			AND ISNULL(CFX.intShipViaId, 0) = ISNULL(S.intEntityId, 0)
		WHERE CF.guiApiUniqueId = @guiApiUniqueId
		AND (ISNULL(CF.strShipViaName, '') = '' OR (S.intEntityId IS NOT NULL AND ISNULL(CF.strShipViaName, '') != ''))
		--AND CFX.intFreightXRefId IS NULL

	 OPEN DataCursor
	 FETCH NEXT FROM DataCursor INTO @intCustomerEntityId, @intEntityTariffTypeId, @intCustomerEntityLocationId, @strSupplierZipCode, @intCategoryId, @ysnFreightOnly, @strFreightType, @intShipViaEntityId, @dblFreightAmount, @dblFreightRate, @dblFreightMile, @ysnFreightInPrice, @dblMinimumUnit, @dblFreightRateIn, @dblMinimumUnitsIn, @dblSurchargeOut, @intRowNumber
	 WHILE @@FETCH_STATUS = 0
     BEGIN
		DECLARE @intFreightXRefId INT = NULL
		PRINT(1)

		SELECT @intFreightXRefId = intFreightXRefId FROM tblARCustomerFreightXRef WHERE intEntityCustomerId = @intCustomerEntityId 
			AND intEntityLocationId = @intCustomerEntityLocationId 
			AND ISNULL(strZipCode, '') = ISNULL(@strSupplierZipCode, '')
			AND intCategoryId = @intCategoryId
			--AND strFreightType = @strFreightType
			AND ISNULL(intEntityTariffTypeId, 0) = ISNULL(@intEntityTariffTypeId, 0)
			AND ISNULL(intShipViaId, 0) = ISNULL(@intShipViaEntityId, 0)
			--AND ISNULL(dblFreightAmount, 0) = ISNULL(@dblFreightAmount, 0)
			--AND ISNULL(dblFreightRate, 0) = ISNULL(@dblFreightRate, 0) 
			--AND ISNULL(dblFreightMiles, 0) = ISNULL(@dblFreightMile, 0) 
			--AND ISNULL(dblMinimumUnits, 0) = ISNULL(@dblMinimumUnit, 0) 
			--AND ISNULL(ysnFreightOnly, 0) = ISNULL(@ysnFreightOnly, 0)
			--AND ISNULL(ysnFreightInPrice, 0) = ISNULL(@ysnFreightInPrice, 0)

		IF (@intFreightXRefId IS NULL) 
		BEGIN
			-- INSERT FREIGHT TYPE IN CUSTOMER

			-- INSERT FREIGHT SETUP
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
				, guiApiUniqueId
				, intEntityTariffTypeId
				, dblFreightRateIn
				, dblMinimumUnitsIn
				, dblSurchargeOut)
			VALUES(@intCustomerEntityId
				, @intCustomerEntityLocationId
				, @strSupplierZipCode
				, @intCategoryId
				, @ysnFreightOnly
				, @strFreightType
				, @intShipViaEntityId
				, ISNULL(@dblFreightAmount, 0)
				, ISNULL(@dblFreightRate, 0)
				, ISNULL(@dblFreightMile, 0)
				, @ysnFreightInPrice
				, ISNULL(@dblMinimumUnit, 0)
				, 1
				, @guiApiUniqueId
				, @intEntityTariffTypeId
				, ISNULL(@dblFreightRateIn, 0)
				, ISNULL(@dblMinimumUnitsIn, 0)
				, ISNULL(@dblSurchargeOut, 0)
			)

			-- INSERT LOGS
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
				, strValue = ''
				, strLogLevel = 'Success'
				, strStatus = 'Success'
				, intRowNo = @intRowNumber
				, strMessage = 'Successfully added'	
		END
		ELSE
		BEGIN

			UPDATE tblARCustomerFreightXRef SET ysnFreightOnly = @ysnFreightOnly
				, strFreightType = @strFreightType
				--, intShipViaId = @intShipViaEntityId
				, dblFreightAmount = ISNULL(@dblFreightAmount, 0)
				, dblFreightRate = ISNULL(@dblFreightRate, 0)
				, dblFreightMiles = ISNULL(@dblFreightMile, 0)
				, ysnFreightInPrice = @ysnFreightInPrice
				, dblMinimumUnits = ISNULL(@dblMinimumUnit, 0)
				, guiApiUniqueId = @guiApiUniqueId
				, dblFreightRateIn = ISNULL(@dblFreightRateIn, 0)
				, dblMinimumUnitsIn = ISNULL(@dblMinimumUnitsIn, 0)
				, dblSurchargeOut = ISNULL(@dblSurchargeOut, 0)
			WHERE intFreightXRefId = @intFreightXRefId
	 
			-- INSERT LOGS
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
				, strValue = '' 
				, strLogLevel = 'Success'
				, strStatus = 'Success'
				, intRowNo = @intRowNumber
				, strMessage = 'Successfully updated'	
		END
   	 	
	 	FETCH NEXT FROM DataCursor INTO @intCustomerEntityId, @intEntityTariffTypeId, @intCustomerEntityLocationId, @strSupplierZipCode, @intCategoryId, @ysnFreightOnly, @strFreightType, @intShipViaEntityId, @dblFreightAmount, @dblFreightRate, @dblFreightMile, @ysnFreightInPrice, @dblMinimumUnit, @dblFreightRateIn, @dblMinimumUnitsIn, @dblSurchargeOut, @intRowNumber
	 END
	 CLOSE DataCursor
	 DEALLOCATE DataCursor

END