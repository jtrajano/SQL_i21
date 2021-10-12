CREATE PROCEDURE [dbo].[uspApiSchemaTransformTRShipViaTariff]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

BEGIN

	DECLARE @tmpFreightType TABLE (strFreightType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL)
	INSERT INTO @tmpFreightType (strFreightType) VALUES ('Rate')
	INSERT INTO @tmpFreightType (strFreightType) VALUES ('Miles')
	INSERT INTO @tmpFreightType (strFreightType) VALUES ('Amount')

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
		, strValue = SVT.strShipViaName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SVT.intRowNumber
		, strMessage = 'Cannot find the Ship Via Name ''' + SVT.strShipViaName + ''' in i21 Ship Via.'
	FROM tblApiSchemaTRShipViaTariff SVT
	LEFT JOIN tblSMShipVia S ON S.strShipVia = SVT.strShipViaName
	WHERE S.intEntityId IS NULL 
	AND ISNULL(SVT.strShipViaName, '') != ''
	AND SVT.guiApiUniqueId = @guiApiUniqueId

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
		, strValue = SVT.strTariffType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SVT.intRowNumber
		, strMessage = 'Cannot find the Tariff Type ''' + SVT.strTariffType + ''' in i21 Tariff Types.'
	FROM tblApiSchemaTRShipViaTariff SVT
	LEFT JOIN tblEMEntityTariffType T ON T.strTariffType = SVT.strTariffType
	WHERE T.intEntityTariffTypeId IS NULL 
	AND SVT.guiApiUniqueId = @guiApiUniqueId

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
		, strValue = SVT.strCategory
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SVT.intRowNumber
		, strMessage = 'Cannot find the Category ''' + SVT.strCategory + ''' in i21 Categories'
	FROM tblApiSchemaTRShipViaTariff SVT
	LEFT JOIN tblICCategory C ON C.strCategoryCode = SVT.strCategory
	WHERE C.intCategoryId IS NULL 
	AND SVT.guiApiUniqueId = @guiApiUniqueId

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
		, strValue = SVT.strFreightType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SVT.intRowNumber
		, strMessage = 'Cannot find the Freight Type ''' + SVT.strFreightType + ''' in i21 Freight Types'
	FROM tblApiSchemaTRShipViaTariff SVT
	LEFT JOIN @tmpFreightType F ON F.strFreightType = SVT.strFreightType
	WHERE F.strFreightType IS NULL 
	AND SVT.guiApiUniqueId = @guiApiUniqueId

	--TRANSFORM
	DECLARE @ImportTable TABLE 
	(
		rowNum						INT IDENTITY(1,1),
		guiApiUniqueId              UNIQUEIDENTIFIER NOT NULL,
		strShipViaName				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
		strTariffDescription		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		
		strTariffType				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
		strFreightType				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		
		strCategory					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			
		dblSurcharge				NUMERIC(18, 6) NULL,									
		dtmShipViaEffectiveDate		DATETIME NOT NULL,										
		dtmSurchargeEffectiveDate	DATETIME NULL,											
		intFromMile					INT NULL,												
		intToMile					INT NULL,												
		dblCostRatePerUnit			NUMERIC(18, 6) NULL,						
		dblInvoiceRatePerUnit		NUMERIC(18, 6) NULL						
	)

	INSERT INTO @ImportTable
	SELECT
		  guiApiUniqueId              
		, strShipViaName				
		, strTariffDescription		
		, strTariffType				
		, strFreightType				
		, strCategory					
		, dblSurcharge				
		, dtmShipViaEffectiveDate		
		, dtmSurchargeEffectiveDate	
		, intFromMile					
		, intToMile					
		, dblCostRatePerUnit			
		, dblInvoiceRatePerUnit		
	FROM tblApiSchemaTRShipViaTariff 
	WHERE guiApiUniqueId = @guiApiUniqueId

	DECLARE @rowCount INT;
	DECLARE @rowNumber INT = 1;

	SELECT @rowCount = COUNT(*) FROM @ImportTable;
		
	WHILE @rowNumber <= @rowCount
	BEGIN
		DECLARE @entityTariffId INT
		DECLARE @etRowCount INT = (SELECT COUNT(*) FROM tblEMEntityTariff)

		-- Entity Tariff
		INSERT INTO tblEMEntityTariff ([intEntityId]
			, [strDescription]
			, [dtmEffectiveDate]
			, [intEntityTariffTypeId]
			, [guiApiUniqueId]
			, [intConcurrencyId])
		SELECT E.intEntityId
			, SVT.strTariffDescription
			, SVT.dtmShipViaEffectiveDate
			, ETT.intEntityTariffTypeId
			, SVT.guiApiUniqueId
			, 1
		FROM @ImportTable SVT
			INNER JOIN tblSMShipVia SV on SVT.strShipViaName = SV.strShipVia
			INNER JOIN tblEMEntity E on SV.intEntityId = E.intEntityId
			INNER JOIN tblEMEntityTariffType ETT ON ETT.strTariffType = SVT.strTariffType
			LEFT JOIN tblEMEntityTariff ET ON ET.intEntityId = E.intEntityId
				AND ET.intEntityTariffTypeId = ETT.intEntityTariffTypeId
				AND SVT.strTariffDescription = ET.strDescription
			WHERE ET.intEntityTariffId IS NULL
				AND SVT.guiApiUniqueId = @guiApiUniqueId
				AND SVT.rowNum = @rowNumber
			
			IF(@etRowCount > (SELECT COUNT(*) FROM tblEMEntityTariff))
			BEGIN
				SET @entityTariffId = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				SET @entityTariffId = (SELECT TOP 1 ET.intEntityTariffId
				FROM @ImportTable SVT
					INNER JOIN tblSMShipVia SV on SVT.strShipViaName = SV.strShipVia
					INNER JOIN tblEMEntity E on SV.intEntityId = E.intEntityId
					INNER JOIN tblEMEntityTariffType ETT ON ETT.strTariffType = SVT.strTariffType
					LEFT JOIN tblEMEntityTariff ET ON ET.intEntityId = E.intEntityId
						AND ET.intEntityTariffTypeId = ETT.intEntityTariffTypeId
						AND SVT.strTariffDescription = ET.strDescription
				WHERE SVT.guiApiUniqueId = @guiApiUniqueId
						AND SVT.rowNum = @rowNumber)
			END

		IF  @entityTariffId IS NOT NULL
		BEGIN
			-- Entity Tariff Category
			INSERT INTO tblEMEntityTariffCategory([intEntityTariffId]
				, [intCategoryId]
				, [guiApiUniqueId]
				, [intConcurrencyId])
			SELECT @entityTariffId
				, C.intCategoryId
				, SVT.guiApiUniqueId
				, 1
			FROM @ImportTable SVT
				LEFT JOIN tblICCategory C ON C.strCategoryCode = SVT.strCategory
				LEFT JOIN tblEMEntityTariffCategory ETC ON ETC.intCategoryId = C.intCategoryId
					AND ETC.intEntityTariffCategoryId IS NULL
			WHERE SVT.guiApiUniqueId = @guiApiUniqueId
				AND (ISNULL(SVT.strCategory, '') <> '')
				AND SVT.strCategory NOT IN (
					SELECT B.strCategoryCode 
					FROM tblEMEntityTariffCategory A 
						INNER JOIN tblICCategory B ON A.intCategoryId = B.intCategoryId 
					WHERE A.intEntityTariffId = @entityTariffId)


			-- Entity Fuel Surcharge
			INSERT INTO tblEMEntityTariffFuelSurcharge ([intEntityTariffId]
				, [dblFuelSurcharge]
				, [dtmEffectiveDate]
				, [guiApiUniqueId]
				, [intConcurrencyId])
			SELECT @entityTariffId
				, SVT.dblSurcharge
				, SVT.dtmSurchargeEffectiveDate
				, SVT.guiApiUniqueId
				, 1
			FROM @ImportTable SVT
			WHERE SVT.guiApiUniqueId = @guiApiUniqueId
				AND SVT.rowNum = @rowNumber
				AND ISNULL(SVT.dblSurcharge, 0) > 0 


			-- Entity Tariff Mileage
			INSERT INTO tblEMEntityTariffMileage ([intEntityTariffId]
				, [intFromMiles]
				, [intToMiles]
				, [dblCostRatePerUnit]
				, [dblInvoiceRatePerUnit]
				, [guiApiUniqueId]
				, [intConcurrencyId])
			SELECT 
				@entityTariffId
				, SVT.intFromMile
				, SVT.intToMile
				, SVT.dblCostRatePerUnit
				, SVT.dblInvoiceRatePerUnit
				, SVT.guiApiUniqueId
				, 1
			FROM @ImportTable SVT
			WHERE SVT.guiApiUniqueId = @guiApiUniqueId
				AND SVT.rowNum = @rowNumber
				AND ISNULL(SVT.intFromMile, 0) > 0
				AND ISNULL(SVT.intToMile, 0) > 0
				AND NOT EXISTS (
					SELECT TOP 1 1 
					FROM tblEMEntityTariffMileage ETM
					WHERE SVT.intFromMile BETWEEN ETM.intFromMiles AND ETM.intToMiles
						AND SVT.intToMile BETWEEN ETM.intFromMiles AND ETM.intToMiles
						AND ISNULL(SVT.intFromMile, 0) > 0
						AND ISNULL(SVT.intToMile, 0) > 0
						AND ETM.intEntityTariffId = @entityTariffId)
		END
		SET @rowNumber += 1
	END
END