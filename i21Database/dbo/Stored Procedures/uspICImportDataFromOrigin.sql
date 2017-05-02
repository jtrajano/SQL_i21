CREATE PROCEDURE [dbo].[uspICImportDataFromOrigin]
	@strLineOfBusiness VARCHAR(50),
	@strType VARCHAR(50)
AS

IF @strLineOfBusiness IS NULL OR LTRIM(RTRIM(@strLineOfBusiness)) = ''
BEGIN
	EXEC uspICRaiseError 80165; 
	GOTO _Exit;
END

IF @strType IS NULL OR LTRIM(RTRIM(@strType)) = ''
BEGIN
	EXEC uspICRaiseError 80166; 
	GOTO _Exit;
END

IF @strLineOfBusiness = 'Petro' 
BEGIN
	IF		@strType = 'UOM'				EXEC dbo.uspICDCUomMigrationPt
	ELSE IF @strType = 'Locations'			BEGIN EXEC dbo.uspICDCSubLocationMigration EXEC dbo.uspICDCStorageMigrationPt END
	ELSE IF @strType = 'CategoryClass'		EXEC dbo.uspICDCCatMigrationPt
	ELSE IF @strType = 'CategoryGLAccts'	EXEC dbo.uspICDCCatGLAcctsMigrationPt
	ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
	ELSE IF @strType = 'Items'				EXEC dbo.uspICDCItemMigrationPt
	ELSE IF @strType = 'ItemGLAccts'		EXEC dbo.uspICDCItmGLAcctsMigrationPt
	ELSE IF @strType = 'Balance'			EXEC dbo.uspICDCBeginInventoryPt
END
ELSE IF @strLineOfBusiness = 'Ag'
BEGIN
	IF		@strType = 'UOM'				EXEC dbo.uspICDCUomMigrationAg
	ELSE IF @strType = 'Locations'			BEGIN EXEC dbo.uspICDCSubLocationMigration EXEC dbo.uspICDCStorageMigrationAg END
	ELSE IF @strType = 'CategoryClass'		EXEC dbo.uspICDCCatMigrationAg
	ELSE IF @strType = 'CategoryGLAccts'	EXEC dbo.uspICDCCatGLAcctsMigrationAg
	ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
	ELSE IF @strType = 'Items'				EXEC dbo.uspICDCItemMigrationAg
	ELSE IF @strType = 'ItemGLAccts'		EXEC dbo.uspICDCItmGLAcctsMigrationAg
	ELSE IF @strType = 'Balance'			EXEC dbo.uspICDCBeginInventoryAg
END
ELSE IF @strLineOfBusiness = 'Grain'
BEGIN
	IF		@strType = 'UOM'				EXEC dbo.uspICDCUomMigrationGr
	ELSE IF @strType = 'Locations'			BEGIN EXEC dbo.uspICDCSubLocationMigration EXEC dbo.uspICDCStorageMigrationGr END
	ELSE IF @strType = 'Commodity'			BEGIN EXEC dbo.uspICDCCommodityMigrationGr EXEC dbo.uspICDCCommodityGLMigrationGr END
	ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
END
ELSE IF @strLineOfBusiness = 'C-Store'
BEGIN
	IF		@strType = 'Locations'			EXEC dbo.uspICDCSubLocationMigration
	ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
END

UPDATE tblICCompanyPreference
SET strOriginLastTask = @strType,
	strOriginLineOfBusiness = @strLineOfBusiness

_Exit:
GO