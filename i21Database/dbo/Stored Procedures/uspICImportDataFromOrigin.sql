CREATE PROCEDURE [dbo].[uspICImportDataFromOrigin]
	@strLineOfBusiness VARCHAR(50),
	@strType VARCHAR(600),
	@intEntityUserSecurityId INT = 0,
	@options OriginImportOptions READONLY
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

DECLARE @strRawType NVARCHAR(600)
SET @strRawType = @strType

SET @strType = SUBSTRING(@strType, 0, CHARINDEX(':', @strType))
-- DECLARE @strStates NVARCHAR(600)
-- SET @strStates = SUBSTRING(@strRawType, CHARINDEX(':', @strRawType)+1, LEN(@strRawType))

DECLARE @Checking BIT
DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
DECLARE @Total INT
DECLARE @Location NVARCHAR(100)

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
	ELSE IF @strType = 'Balance'			
	BEGIN
		SELECT @Location = Value FROM @options WHERE Name = 'adjLoc'
		SELECT @StartDate = Value FROM @options WHERE Name = 'adjdt'
		EXEC dbo.uspICDCBeginInventoryPt @Location, @StartDate, @intEntityUserSecurityId
	END
	ELSE IF @strType = 'RecipeFormula'  EXEC dbo.uspMFImportRecipe 0, @intEntityUserSecurityId
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
		ALTER INDEX [AK_tblICItemUomUpc_strUpcCode] ON [dbo].[tblICItemUomUpc] DISABLE
		ALTER INDEX [AK_tblICItemUomUpc_strLongUpcCode] ON [dbo].[tblICItemUomUpc] DISABLE
     
		EXEC dbo.[uspICDCItemMigrationAg]  
     
		ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
		ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
		ALTER INDEX [AK_tblICItemUomUpc_strUpcCode] ON [dbo].[tblICItemUomUpc] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		ALTER INDEX [AK_tblICItemUomUpc_strLongUpcCode] ON [dbo].[tblICItemUomUpc] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

		END
	ELSE IF @strType = 'ItemGLAccts'		EXEC dbo.uspICDCItmGLAcctsMigrationAg
	ELSE IF @strType = 'Balance'			
	BEGIN
		SELECT @Location = Value FROM @options WHERE Name = 'adjLoc'
		SELECT @StartDate = Value FROM @options WHERE Name = 'adjdt'
		EXEC dbo.uspICDCBeginInventoryAg @Location, @StartDate, @intEntityUserSecurityId
	END
	ELSE IF @strType = 'RecipeFormula'  EXEC dbo.uspMFImportRecipe 0, @intEntityUserSecurityId  
END
ELSE IF @strLineOfBusiness = 'Grain'
BEGIN
	IF		@strType = 'UOM'				EXEC dbo.uspICDCUomMigrationGr
	ELSE IF @strType = 'Locations'			BEGIN EXEC dbo.uspICDCStorageMigrationGr END
	ELSE IF @strType = 'Balance'			
		BEGIN
			SELECT @Location = Value FROM @options WHERE Name = 'adjLoc'
			SELECT @StartDate = Value FROM @options WHERE Name = 'adjdt'
			EXEC dbo.uspICDCBeginInventoryGr @Location, @StartDate, @intEntityUserSecurityId
		END
	ELSE IF @strType = 'Commodity'			
		BEGIN
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] DISABLE
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] DISABLE
			
			EXEC dbo.uspICDCCommodityMigrationGr 
			EXEC dbo.uspICDCCommodityGLMigrationGr
			
			ALTER INDEX [AK_tblICItemUOM_strUpcCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
			ALTER INDEX [AK_tblICItemUOM_strLongUPCCode] ON [dbo].[tblICItemUOM] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
		END
	ELSE IF @strType = 'RecipeFormula'  EXEC dbo.uspMFImportRecipe 0, @intEntityUserSecurityId
	--ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
END
ELSE IF @strLineOfBusiness = 'C-Store'
BEGIN
	IF		@strType = 'Locations'			EXEC dbo.uspICDCSubLocationMigration
	--ELSE IF @strType = 'AdditionalGLAccts'	EXEC dbo.uspICDCCatExtraGLAccounts
END

IF @strType = 'Receipts'
BEGIN
	SELECT @Checking = CASE Value WHEN 'True' THEN 1 ELSE 0 END FROM @options WHERE Name = 'checking'
	SELECT @StartDate = Value FROM @options WHERE Name = 'startDate'
	SELECT @EndDate = Value FROM @options WHERE Name = 'endDate'
	EXEC dbo.uspICImportInventoryReceipts @Checking, @intEntityUserSecurityId, @Total OUTPUT, @StartDate, @EndDate 	
END

-- UPDATE tblICCompanyPreference
-- SET strOriginLastTask = @strStates,
-- 	strOriginLineOfBusiness = @strLineOfBusiness
UPDATE tblICCompanyPreference
SET strOriginLineOfBusiness = @strLineOfBusiness

_Exit:
