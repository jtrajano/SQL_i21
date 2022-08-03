CREATE PROCEDURE [dbo].[uspSTCopyCategoryLocation]
	@intCategorySourceId INT,
	@intCategoryLocationSourceId INT,
	@intCopyFromLocationId INT,
	@intCopyToLocationId INT,
	@intUserId INT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

--------------------------
-- Generate Category Code --
--------------------------
DECLARE 
	@strCategoryCode NVARCHAR(50),
	@strNewCategoryCode NVARCHAR(50),
	@strNewCategoryCodeWithCounter NVARCHAR(50),
	@counter INT,
	@strNewDescription NVARCHAR(50)

-- Duplicate Location info
INSERT INTO [dbo].[tblICCategoryLocation]
           ([intCategoryId]
           ,[intLocationId]
           ,[strCashRegisterDepartment]
           ,[ysnUpdatePrices]
           ,[ysnUseTaxFlag1]
           ,[ysnUseTaxFlag2]
           ,[ysnUseTaxFlag3]
           ,[ysnUseTaxFlag4]
           ,[ysnBlueLaw1]
           ,[ysnBlueLaw2]
           ,[intNucleusGroupId]
           ,[dblTargetGrossProfit]
           ,[dblTargetInventoryCost]
           ,[dblCostInventoryBOM]
           ,[dblLowGrossMarginAlert]
           ,[dblHighGrossMarginAlert]
           ,[dtmLastInventoryLevelEntry]
		   ,[intGeneralItemId]
           ,[ysnNonRetailUseDepartment]
           ,[ysnReportNetGross]
           ,[ysnDepartmentForPumps]
           ,[intConvertPaidOutId]
           ,[ysnDeleteFromRegister]
           ,[ysnDeptKeyTaxed]
           ,[intProductCodeId]
           ,[intFamilyId]
           ,[intClassId]
           ,[ysnFoodStampable]
           ,[ysnReturnable]
           ,[ysnSaleable]
           ,[ysnPrePriced]
           ,[ysnIdRequiredLiquor]
           ,[ysnIdRequiredCigarette]
           ,[intMinimumAge]
           ,[intSort]
           ,[intConcurrencyId])
SELECT
			intCategoryId
           ,@intCopyToLocationId
           ,[strCashRegisterDepartment]
           ,[ysnUpdatePrices]
           ,[ysnUseTaxFlag1]
           ,[ysnUseTaxFlag2]
           ,[ysnUseTaxFlag3]
           ,[ysnUseTaxFlag4]
           ,[ysnBlueLaw1]
           ,[ysnBlueLaw2]
           ,[intNucleusGroupId]
           ,[dblTargetGrossProfit]
           ,[dblTargetInventoryCost]
           ,[dblCostInventoryBOM]
           ,[dblLowGrossMarginAlert]
           ,[dblHighGrossMarginAlert]
           ,[dtmLastInventoryLevelEntry]
		   ,[intGeneralItemId]
           ,[ysnNonRetailUseDepartment]
           ,[ysnReportNetGross]
           ,[ysnDepartmentForPumps]
           ,[intConvertPaidOutId]
           ,[ysnDeleteFromRegister]
           ,[ysnDeptKeyTaxed]
           ,[intProductCodeId]
           ,[intFamilyId]
           ,[intClassId]
           ,[ysnFoodStampable]
           ,[ysnReturnable]
           ,[ysnSaleable]
           ,[ysnPrePriced]
           ,[ysnIdRequiredLiquor]
           ,[ysnIdRequiredCigarette]
           ,[intMinimumAge]
           ,[intSort]
		   ,1
FROM tblICCategoryLocation
WHERE intCategoryLocationId = @intCategoryLocationSourceId

DECLARE @intItemId AS INT = ISNULL((SELECT TOP 1 intGeneralItemId FROM tblICCategoryLocation WHERE intCategoryLocationId = @intCategoryLocationSourceId), 0)

IF NOT EXISTS (SELECT TOP 1 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intCopyToLocationId)
	BEGIN
		EXEC dbo.uspSTCopyItemLocation
		@intSourceItemId 			= @intItemId,
		@intSourceLocationId		= @intCopyFromLocationId,
		@intToLocationId 			= @intCopyToLocationId
	END

-- Add the audit logs
BEGIN 

DECLARE @strDescription NVARCHAR(400)

SET @strDescription = 'Duplicated category location from Copy to Store screen'
EXEC	dbo.uspSMAuditLog 
			@keyValue = @intCategorySourceId						-- Item Id. 
			,@screenName = 'Inventory.view.Category'     -- Screen Namespace
			,@entityId = @intUserId						-- Entity Id.
			,@actionType = 'Duplicated'                  -- Action Type
			,@changeDescription = @strDescription
END
