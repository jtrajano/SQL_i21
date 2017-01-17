CREATE PROCEDURE [dbo].[uspICDuplicateCategory]
	@intCategoryId INT,
	@intNewCategoryId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Duplicate primary details
INSERT INTO [dbo].[tblICCategory]
           ([strCategoryCode]
           ,[strDescription]
           ,[strInventoryType]
           ,[intLineOfBusinessId]
           ,[intCostingMethod]
           ,[strInventoryTracking]
           ,[dblStandardQty]
           ,[intUOMId]
           ,[strGLDivisionNumber]
           ,[ysnSalesAnalysisByTon]
           ,[strMaterialFee]
           ,[intMaterialItemId]
           ,[ysnAutoCalculateFreight]
           ,[intFreightItemId]
           ,[strERPItemClass]
           ,[dblLifeTime]
           ,[dblBOMItemShrinkage]
           ,[dblBOMItemUpperTolerance]
           ,[dblBOMItemLowerTolerance]
           ,[ysnScaled]
           ,[ysnOutputItemMandatory]
           ,[strConsumptionMethod]
           ,[strBOMItemType]
           ,[strShortName]
           ,[imgReceiptImage]
           ,[imgWIPImage]
           ,[imgFGImage]
           ,[imgShipImage]
           ,[dblLaborCost]
           ,[dblOverHead]
           ,[dblPercentage]
           ,[strCostDistributionMethod]
           ,[ysnSellable]
           ,[ysnYieldAdjustment]
           ,[ysnWarehouseTracked])
SELECT [strCategoryCode] + '-copy'
           ,[strDescription] + '-copy'
           ,[strInventoryType]
           ,[intLineOfBusinessId]
           ,[intCostingMethod]
           ,[strInventoryTracking]
           ,[dblStandardQty]
           ,[intUOMId]
           ,[strGLDivisionNumber]
           ,[ysnSalesAnalysisByTon]
           ,[strMaterialFee]
           ,[intMaterialItemId]
           ,[ysnAutoCalculateFreight]
           ,[intFreightItemId]
           ,[strERPItemClass]
           ,[dblLifeTime]
           ,[dblBOMItemShrinkage]
           ,[dblBOMItemUpperTolerance]
           ,[dblBOMItemLowerTolerance]
           ,[ysnScaled]
           ,[ysnOutputItemMandatory]
           ,[strConsumptionMethod]
           ,[strBOMItemType]
           ,[strShortName]
           ,[imgReceiptImage]
           ,[imgWIPImage]
           ,[imgFGImage]
           ,[imgShipImage]
           ,[dblLaborCost]
           ,[dblOverHead]
           ,[dblPercentage]
           ,[strCostDistributionMethod]
           ,[ysnSellable]
           ,[ysnYieldAdjustment]
           ,[ysnWarehouseTracked]
FROM tblICCategory
WHERE intCategoryId = @intCategoryId

SET @intNewCategoryId = SCOPE_IDENTITY()

-- Duplicate Tax Info
INSERT INTO [dbo].[tblICCategoryTax] (intCategoryId, [intTaxClassId], [ysnActive])
SELECT @intNewCategoryId, intTaxClassId, ysnActive
FROM tblICCategoryTax
WHERE intCategoryId = @intCategoryId 

-- Duplicate Location info
INSERT INTO [dbo].[tblICCategoryLocation]
           ([intCategoryId]
           ,[intLocationId]
           ,[intRegisterDepartmentId]
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
           ,[intSort])
SELECT
			@intNewCategoryId
           ,[intLocationId]
           ,[intRegisterDepartmentId]
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
FROM tblICCategoryLocation
WHERE intCategoryId = @intCategoryId

-- Duplicate Vendor
INSERT INTO [dbo].[tblICCategoryVendor]
           ([intCategoryId]
           ,[intCategoryLocationId]
           ,[intVendorId]
           ,[strVendorDepartment]
           ,[ysnAddOrderingUPC]
           ,[ysnUpdateExistingRecords]
           ,[ysnAddNewRecords]
           ,[ysnUpdatePrice]
           ,[intFamilyId]
           ,[intSellClassId]
           ,[intOrderClassId]
           ,[strComments]
           ,[intSort])
SELECT		n.intCategoryId,
			n.intCategoryLocationId
           ,v.[intVendorId]
           ,v.[strVendorDepartment]
           ,v.[ysnAddOrderingUPC]
           ,v.[ysnUpdateExistingRecords]
           ,v.[ysnAddNewRecords]
           ,v.[ysnUpdatePrice]
           ,v.[intFamilyId]
           ,v.[intSellClassId]
           ,v.[intOrderClassId]
           ,v.[strComments]
           ,v.[intSort]
FROM tblICCategoryLocation n
	INNER JOIN tblICCategoryLocation o ON o.intLocationId = n.intLocationId
	INNER JOIN tblICCategoryVendor v ON v.intCategoryId = o.intCategoryId
WHERE n.intCategoryId = @intNewCategoryId
	AND o.intCategoryId = @intCategoryId

-- Duplicate Accounts
INSERT INTO [dbo].[tblICCategoryAccount]
           ([intCategoryId]
           ,[intAccountCategoryId]
           ,[intAccountId]
           ,[intSort])
SELECT @intNewCategoryId, intAccountCategoryId, intAccountId, intSort
FROM tblICCategoryAccount
WHERE intCategoryId = @intCategoryId