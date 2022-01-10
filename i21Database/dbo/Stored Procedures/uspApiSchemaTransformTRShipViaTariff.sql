CREATE PROCEDURE [dbo].[uspApiSchemaTransformTRShipViaTariff]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

BEGIN

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

	--TRANSFORM
	DECLARE cur CURSOR FOR
	SELECT SVT.intKey 
	,SVT.intRowNumber   
	,E.intEntityId
	,SVT.strTariffDescription
	,ET.intEntityTariffId
	,ETT.intEntityTariffTypeId			
	,C.intCategoryId					
	,SVT.dblSurcharge				
	,SVT.dtmShipViaEffectiveDate		
	,SVT.dtmSurchargeEffectiveDate	
	,SVT.intFromMile					
	,SVT.intToMile					
	,SVT.dblCostRatePerUnit			
	,SVT.dblInvoiceRatePerUnit		
	FROM tblApiSchemaTRShipViaTariff SVT
		INNER JOIN tblSMShipVia SV ON SVT.strShipViaName = SV.strShipVia
		INNER JOIN tblEMEntity E ON SV.intEntityId = E.intEntityId
		INNER JOIN tblEMEntityTariffType ETT ON ETT.strTariffType = SVT.strTariffType
		INNER JOIN tblICCategory C ON C.strCategoryCode = SVT.strCategory
		LEFT JOIN tblEMEntityTariff ET ON ET.intEntityId = E.intEntityId
			AND ET.intEntityTariffTypeId = ETT.intEntityTariffTypeId
			AND SVT.strTariffDescription = ET.strDescription
	WHERE --ET.intEntityTariffId IS NULL
		--AND 
		SVT.guiApiUniqueId = @guiApiUniqueId

    DECLARE @intKey						INT = NULL
	DECLARE @intRowNumber				INT = NULL
	DECLARE @intEntityId				INT = NULL
	DECLARE @intEntityTariffId			INT = NULL
	DECLARE @intEntityTariffTypeId		INT = NULL
	DECLARE @strTariffDescription		NVARCHAR(50) = NULL
	DECLARE @intCategoryId				INT = NULL
	DECLARE @dblSurcharge				NUMERIC(18, 6) = NULL
	DECLARE @dtmShipViaEffectiveDate	DATETIME = NULL
	DECLARE @dtmSurchargeEffectiveDate	DATETIME = NULL
	DECLARE @intFromMile				INT	= NULL
	DECLARE @intToMile					INT	= NULL
	DECLARE @dblCostRatePerUnit			NUMERIC(18, 6) = NULL
	DECLARE @dblInvoiceRatePerUnit		NUMERIC(18, 6) = NULL

	OPEN cur
	FETCH NEXT FROM cur INTO
	 @intKey                     
	,@intRowNumber               
	,@intEntityId
	,@strTariffDescription
	,@intEntityTariffId
	,@intEntityTariffTypeId
	,@intCategoryId				
	,@dblSurcharge				
	,@dtmShipViaEffectiveDate	
	,@dtmSurchargeEffectiveDate	
	,@intFromMile				
	,@intToMile					
	,@dblCostRatePerUnit			
	,@dblInvoiceRatePerUnit		

	WHILE @@FETCH_STATUS = 0   
	BEGIN
		DECLARE @tariffId INT = NULL
		DECLARE @Updated BIT = 0

		-- Tariff
		IF @intEntityTariffId IS NULL
		BEGIN
			INSERT INTO tblEMEntityTariff ([intEntityId]
				, [strDescription]
				, [dtmEffectiveDate]
				, [intEntityTariffTypeId]
				, [guiApiUniqueId]
				, [intConcurrencyId])
			VALUES(@intEntityId
				, @strTariffDescription
				, @dtmShipViaEffectiveDate
				, @intEntityTariffTypeId
				, @guiApiUniqueId
				, 1)
			SET @tariffId = SCOPE_IDENTITY()
			--SET @Created = 1
		END
		ELSE
		BEGIN
			SET @tariffId = @intEntityTariffId
		END


		-- Tariff Category
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityTariffCategory WHERE intEntityTariffId = @tariffId AND intCategoryId = @intCategoryId)
		BEGIN
			INSERT INTO tblEMEntityTariffCategory([intEntityTariffId]
				, [intCategoryId]
				, [guiApiUniqueId]
				, [intConcurrencyId])
			VALUES (@tariffId
				, @intCategoryId
				, @guiApiUniqueId
				, 1)

			--SET @Created = 1
		END


		-- Tariff Fuel Surcharge
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityTariffFuelSurcharge WHERE intEntityTariffId = @tariffId AND dtmEffectiveDate = @dtmSurchargeEffectiveDate)
		BEGIN
			IF ISNULL(@dblSurcharge, -1) <> -1
			BEGIN
				INSERT INTO tblEMEntityTariffFuelSurcharge ([intEntityTariffId]
					, [dblFuelSurcharge]
					, [dtmEffectiveDate]
					, [guiApiUniqueId]
					, [intConcurrencyId])
				VALUES (@tariffId
					, @dblSurcharge
					, @dtmSurchargeEffectiveDate
					, @guiApiUniqueId
					, 1
				)

				--SET @Created = 1
			END
		END
		ELSE
		BEGIN
			UPDATE tblEMEntityTariffFuelSurcharge 
			SET [dblFuelSurcharge] = ISNULL(@dblSurcharge, 0), [guiApiUniqueId] = @guiApiUniqueId
			WHERE intEntityTariffId = @tariffId 
				AND dtmEffectiveDate = @dtmSurchargeEffectiveDate

			SET @Updated = 1
		END

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
				, strMessage = CASE WHEN @Updated = 1 THEN 'Data updated successfully' ELSE 'Data added successfully' END


	--	-- Tariff Mileage
		--	INSERT INTO tblEMEntityTariffMileage ([intEntityTariffId]
		--		, [intFromMiles]
		--		, [intToMiles]
		--		, [dblCostRatePerUnit]
		--		, [dblInvoiceRatePerUnit]
		--		, [guiApiUniqueId]
		--		, [intConcurrencyId])
		--	SELECT 
		--		@entityTariffId
		--		, SVT.intFromMile
		--		, SVT.intToMile
		--		, SVT.dblCostRatePerUnit
		--		, SVT.dblInvoiceRatePerUnit
		--		, SVT.guiApiUniqueId
		--		, 1
		--	FROM @ImportTable SVT
		--	WHERE SVT.guiApiUniqueId = @guiApiUniqueId
		--		AND SVT.rowNum = @rowNumber
		--		AND ISNULL(SVT.intFromMile, 0) > 0
		--		AND ISNULL(SVT.intToMile, 0) > 0
		--		AND NOT EXISTS (
		--			SELECT TOP 1 1 
		--			FROM tblEMEntityTariffMileage ETM
		--			WHERE SVT.intFromMile BETWEEN ETM.intFromMiles AND ETM.intToMiles
		--				AND SVT.intToMile BETWEEN ETM.intFromMiles AND ETM.intToMiles
		--				AND ISNULL(SVT.intFromMile, 0) > 0
		--				AND ISNULL(SVT.intToMile, 0) > 0
		--				AND ETM.intEntityTariffId = @entityTariffId)

	FETCH NEXT FROM cur INTO
	 @intKey                     
	,@intRowNumber               
	,@intEntityId
	,@strTariffDescription
	,@intEntityTariffId
	,@intEntityTariffTypeId				
	,@intCategoryId				
	,@dblSurcharge				
	,@dtmShipViaEffectiveDate	
	,@dtmSurchargeEffectiveDate	
	,@intFromMile				
	,@intToMile					
	,@dblCostRatePerUnit			
	,@dblInvoiceRatePerUnit		
	END
	CLOSE cur
	DEALLOCATE cur
END