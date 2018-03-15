CREATE PROCEDURE [dbo].[uspICImportDataFromOrigin]
	@strLineOfBusiness VARCHAR(50),
	@strType VARCHAR(50),
	@intEntityUserSecurityId INT = 0

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
	ELSE IF @strType = 'Locations'			BEGIN EXEC dbo.uspICDCStorageMigrationPt END
	ELSE IF @strType = 'CategoryClass'		EXEC dbo.uspICDCCatMigrationPt
	ELSE IF @strType = 'CategoryGLAccts'	EXEC dbo.uspICDCCatGLAcctsMigrationPt
	--ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
	ELSE IF @strType = 'Items'				
		BEGIN
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] DISABLE
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] DISABLE
			
			EXEC dbo.uspICDCItemMigrationPt
			
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		END
	ELSE IF @strType = 'ItemGLAccts'		EXEC dbo.uspICDCItmGLAcctsMigrationPt
	ELSE IF @strType = 'Balance'			EXEC dbo.uspICDCBeginInventoryPt NULL, NULL, @intEntityUserSecurityId
	ELSE IF @strType = 'RecipeFormula'		EXEC dbo.uspICDCRecipeFormulaMigrationPt @intEntityUserSecurityId	

END
ELSE IF @strLineOfBusiness = 'Ag'
BEGIN
	IF		@strType = 'UOM'				EXEC dbo.uspICDCUomMigrationAg
	ELSE IF @strType = 'Locations'			BEGIN EXEC dbo.uspICDCStorageMigrationAg END
	ELSE IF @strType = 'CategoryClass'		EXEC dbo.uspICDCCatMigrationAg
	ELSE IF @strType = 'CategoryGLAccts'	EXEC dbo.uspICDCCatGLAcctsMigrationAg
	--ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
	ELSE IF @strType = 'Items'				
		BEGIN
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] DISABLE
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] DISABLE
			
			EXEC dbo.[uspICDCItemMigrationAg]
			
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		END
	ELSE IF @strType = 'ItemGLAccts'		EXEC dbo.uspICDCItmGLAcctsMigrationAg
	ELSE IF @strType = 'Balance'			EXEC dbo.uspICDCBeginInventoryAg NULL, NULL, @intEntityUserSecurityId
END
ELSE IF @strLineOfBusiness = 'Grain'
BEGIN
	IF		@strType = 'UOM'				EXEC dbo.uspICDCUomMigrationGr
	ELSE IF @strType = 'Locations'			BEGIN EXEC dbo.uspICDCStorageMigrationGr END
	ELSE IF @strType = 'Commodity'			
		BEGIN
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] DISABLE
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] DISABLE
			
			EXEC dbo.uspICDCCommodityMigrationGr 
			EXEC dbo.uspICDCCommodityGLMigrationGr
			
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
		END
	--ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
END
ELSE IF @strLineOfBusiness = 'C-Store'
BEGIN
	IF		@strType = 'Locations'			EXEC dbo.uspICDCSubLocationMigration
	--ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
END

UPDATE tblICCompanyPreference
SET strOriginLastTask = @strType,
	strOriginLineOfBusiness = @strLineOfBusiness

_Exit:
GO