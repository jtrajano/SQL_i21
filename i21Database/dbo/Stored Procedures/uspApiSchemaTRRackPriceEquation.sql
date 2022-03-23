CREATE PROCEDURE [dbo].[uspApiSchemaTRRackPriceEquation]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @tmpOperand TABLE (
		strOperand NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL
	)

	INSERT INTO @tmpOperand (strOperand) VALUES ('+')
	INSERT INTO @tmpOperand (strOperand) VALUES ('-')
	INSERT INTO @tmpOperand (strOperand) VALUES ('*')
	INSERT INTO @tmpOperand (strOperand) VALUES ('/')

	-- VALIDATE Vendor Entity
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
		, strField = 'Vendor Entity Number'
		, strValue = PE.strVendorEntityNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = PE.intRowNumber
		, strMessage = 'Cannot find the Vendor Entity Number ''' + PE.strVendorEntityNo + ''' in i21 Vendors'
	FROM tblApiSchemaTRRackPriceEquation PE
	LEFT JOIN tblEMEntity E ON E.strEntityNo = PE.strVendorEntityNo
	LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	WHERE V.intEntityId IS NULL
	AND PE.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Location Name
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
		, strField = 'Location Name'
		, strValue = PE.strLocationName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = PE.intRowNumber
		, strMessage = 'Cannot find the Location Name ''' + PE.strLocationName + ''' in i21 Vendor Locations'
	FROM tblApiSchemaTRRackPriceEquation PE
	LEFT JOIN tblEMEntity E ON E.strEntityNo = PE.strVendorEntityNo
	LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = PE.strLocationName
	WHERE EL.intEntityLocationId IS NULL
	AND PE.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Item
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
		, strField = 'Item Number'
		, strValue = PE.strItemNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = PE.intRowNumber
		, strMessage = 'Cannot find the Item Number ''' + PE.strItemNo + ''' in i21 Items'
	FROM tblApiSchemaTRRackPriceEquation PE
	LEFT JOIN tblICItem I ON I.strItemNo = PE.strItemNo
	WHERE I.intItemId IS NULL
	AND PE.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Operand
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
		, strField = 'Operand'
		, strValue = PE.strOperand
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = PE.intRowNumber
		, strMessage = 'Cannot find the Operand''' + PE.strOperand + ''' in i21 Operands'
	FROM tblApiSchemaTRRackPriceEquation PE
	LEFT JOIN @tmpOperand O ON O.strOperand = PE.strOperand
	WHERE O.strOperand IS NULL 
	AND PE.guiApiUniqueId = @guiApiUniqueId

	DECLARE @intVendorEntityId INT = NULL
	, @intEntityLocationId INT = NULL
	, @strLocationName NVARCHAR(200) = NULL
	, @intItemId INT = NULL
	, @strOperand NVARCHAR(10) = NULL
	, @dblFactor NUMERIC(18,6) = NULL	
	, @intRowNumber INT = NULL
	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR 
	SELECT V.intEntityId AS intVendorEntityId
		, EL.intEntityLocationId AS intEntityLocationId
		, EL.strLocationName AS strLocationName
		, I.intItemId AS intItemId
		, O.strOperand AS strOperand
		, PE.dblFactor AS dblFactor
		, PE.intRowNumber
	FROM tblApiSchemaTRRackPriceEquation PE
	INNER JOIN tblEMEntity E ON E.strEntityNo = PE.strVendorEntityNo
	INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = PE.strLocationName
	INNER JOIN tblICItem I ON I.strItemNo = PE.strItemNo
	INNER JOIN @tmpOperand O ON O.strOperand = PE.strOperand
	WHERE PE.guiApiUniqueId = @guiApiUniqueId

	OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @intVendorEntityId, @intEntityLocationId, @strLocationName, @intItemId, @strOperand, @dblFactor, @intRowNumber
	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @intSupplyPointId INT = NULL
		SELECT @intSupplyPointId = intSupplyPointId FROM tblTRSupplyPoint WHERE intEntityVendorId = @intVendorEntityId AND intEntityLocationId = @intEntityLocationId

		IF(@intSupplyPointId IS NOT NULL)
		BEGIN
			DECLARE @strProcessType NVARCHAR(10) = NULL
			DECLARE @intSupplyPointRackPriceEquationId INT = NULL
			SELECT @intSupplyPointRackPriceEquationId = intSupplyPointRackPriceEquationId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = @intSupplyPointId AND intItemId = @intItemId

			IF(@intSupplyPointRackPriceEquationId IS NULL)
			BEGIN
				INSERT INTO tblTRSupplyPointRackPriceEquation (intItemId
					, intSupplyPointId
					, strOperand
					, dblFactor
					, intConcurrencyId
					, guiApiUniqueId
					, intRowNumber)
				VALUES (@intItemId
					, @intSupplyPointId
					, @strOperand
					, @dblFactor
					, 1
					, @guiApiUniqueId
					, @intRowNumber)

				SET @strProcessType = 'added'
			END
			ELSE
			BEGIN
				UPDATE tblTRSupplyPointRackPriceEquation SET strOperand = @strOperand
					, dblFactor = @dblFactor
					, guiApiUniqueId = @guiApiUniqueId
					, intRowNumber = @intRowNumber
				WHERE intSupplyPointRackPriceEquationId = @intSupplyPointRackPriceEquationId
			
				SET @strProcessType = 'updated'
			END

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
				, strMessage = 'Successfully ' + @strProcessType

		END
		ELSE
		BEGIN
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
				, strLogLevel = 'Error'
				, strStatus = 'Failed'
				, intRowNo = @intRowNumber
				, strMessage = 'Cannot find the Supply point ''' + @strLocationName + ''' in i21 Supply Points'
		END


		FETCH NEXT FROM DataCursor INTO @intVendorEntityId, @intEntityLocationId, @strLocationName, @intItemId, @strOperand, @dblFactor, @intRowNumber
	END
	CLOSE DataCursor
	DEALLOCATE DataCursor

END
