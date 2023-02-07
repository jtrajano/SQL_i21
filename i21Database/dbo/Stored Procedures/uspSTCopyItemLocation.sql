CREATE PROCEDURE [dbo].[uspSTCopyItemLocation]
	@intSourceItemId INT,
	@intSourceLocationId INT = NULL,
	@intToLocationId INT,
	@intEntityUserSecurityId INT = 1 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intItemId INT
DECLARE @intNewItemLocationId INT

DECLARE @New TABLE([intItemId] [int] NOT NULL,
	[intLocationId] [int] NULL,
	[intVendorId] [int] NULL,
	[strDescription] [nvarchar](max) NULL,
	[intCostingMethod] [int] NULL,
	[intAllowNegativeInventory] [int] NOT NULL DEFAULT ((3)),
	[intSubLocationId] [int] NULL,
	[intStorageLocationId] [int] NULL,
	[intGrossUOMId] [int] NULL,
	[intIssueUOMId] [int] NULL,
	[intReceiveUOMId] [int] NULL,
	[intFamilyId] [int] NULL,
	[intClassId] [int] NULL,
	[intProductCodeId] [int] NULL,
	[intFuelTankId] [int] NULL,
	[ysnTaxFlag1] [bit] NULL,
	[ysnTaxFlag2] [bit] NULL,
	[ysnTaxFlag3] [bit] NULL,
	[ysnTaxFlag4] [bit] NULL,
	[ysnPromotionalItem] [bit] NULL,
	[intMixMatchId] [int] NULL,
	[ysnDepositRequired] [bit] NULL,
	[intDepositPLUId] [int] NULL,
	[intBottleDepositNo] [int] NULL,
	[ysnSaleable] [bit] NULL,
	[ysnQuantityRequired] [bit] NULL,
	[ysnScaleItem] [bit] NULL,
	[ysnFoodStampable] [bit] NULL,
	[ysnReturnable] [bit] NULL,
	[ysnPrePriced] [bit] NULL,
	[ysnOpenPricePLU] [bit] NULL,
	[ysnLinkedItem] [bit] NULL,
	[strVendorCategory] [nvarchar](50) NULL,
	[ysnCountBySINo] [bit] NULL,
	[strSerialNoBegin] [nvarchar](50) NULL,
	[strSerialNoEnd] [nvarchar](50) NULL,
	[ysnIdRequiredLiquor] [bit] NULL,
	[ysnIdRequiredCigarette] [bit] NULL,
	[intMinimumAge] [int] NULL,
	[ysnApplyBlueLaw1] [bit] NULL,
	[ysnApplyBlueLaw2] [bit] NULL,
	[ysnCarWash] [bit] NULL,
	[intItemTypeCode] [int] NULL,
	[intItemTypeSubCode] [int] NULL,
	[ysnAutoCalculateFreight] [bit] NULL,
	[intFreightMethodId] [int] NULL,
	[dblFreightRate] [numeric](18, 6) NULL DEFAULT ((0)),
	[intShipViaId] [int] NULL,
	[intNegativeInventory] [int] NULL DEFAULT ((3)),
	[dblReorderPoint] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblMinOrder] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblSuggestedQty] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblLeadTime] [numeric](18, 6) NULL DEFAULT ((0)),
	[strCounted] [nvarchar](50) NULL,
	[intCountGroupId] [int] NULL,
	[ysnCountedDaily] [bit] NULL DEFAULT ((0)),
	[intAllowZeroCostTypeId] INT NULL,
	[ysnLockedInventory] [bit] NULL DEFAULT ((0)),
	[strStorageUnitNo] [nvarchar](100) NULL,
	[ysnStorageUnitRequired] BIT NULL DEFAULT ((1)),
	[intSort] [int] NULL)

	INSERT INTO @New(
		intItemId
		, intLocationId
		, intVendorId
		, strDescription
		, intCostingMethod
		, intAllowNegativeInventory
		, intSubLocationId
		, intStorageLocationId
		, intGrossUOMId
		, intIssueUOMId
		, intReceiveUOMId
		, intFamilyId
		, intClassId, intProductCodeId, intFuelTankId, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
		, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
		, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
		, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
		, ysnLockedInventory, strStorageUnitNo, ysnStorageUnitRequired, intAllowZeroCostTypeId, intSort)
	SELECT
		intItemId
		, @intToLocationId
		, intVendorId
		, strDescription
		, intCostingMethod
		, intAllowNegativeInventory
		, intSubLocationId
		, intStorageLocationId
		, intGrossUOMId
		, intIssueUOMId
		, intReceiveUOMId
		, intFamilyId
		, intClassId, intProductCodeId, intFuelTankId, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
		, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
		, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
		, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
		, ysnLockedInventory, strStorageUnitNo, ysnStorageUnitRequired, intAllowZeroCostTypeId, intSort
	FROM tblICItemLocation 
	WHERE intItemId = @intSourceItemId AND intLocationId = @intSourceLocationId
	
--	FETCH NEXT FROM cur INTO @intItemId
--END

--CLOSE cur
--DEALLOCATE cur

INSERT INTO tblICItemLocation(
	intItemId
	, intLocationId
	, intVendorId
	, strDescription
	, intCostingMethod
	, intAllowNegativeInventory
	, intSubLocationId
	, intStorageLocationId
	, intGrossUOMId
	, intIssueUOMId
	, intReceiveUOMId
	, intFamilyId
	, intClassId, intProductCodeId, intFuelTankId, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
	, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
	, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
	, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
	, ysnLockedInventory, strStorageUnitNo, ysnStorageUnitRequired, intAllowZeroCostTypeId, intSort, intConcurrencyId)
SELECT 
	NewDetails.intItemId
	, NewDetails.intLocationId
	, NewDetails.intVendorId
	, NewDetails.strDescription
	, NewDetails.intCostingMethod
	, NewDetails.intAllowNegativeInventory
	, NewDetails.intSubLocationId
	, NewDetails.intStorageLocationId
	, NewDetails.intGrossUOMId
	, NewDetails.intIssueUOMId
	, NewDetails.intReceiveUOMId
	, NewDetails.intFamilyId
	, NewDetails.intClassId, NewDetails.intProductCodeId, NewDetails.intFuelTankId, NewDetails.ysnTaxFlag1, NewDetails.ysnTaxFlag2, NewDetails.ysnTaxFlag3, NewDetails.ysnTaxFlag4, NewDetails.ysnPromotionalItem, NewDetails.intMixMatchId
	, NewDetails.ysnDepositRequired, NewDetails.intDepositPLUId, NewDetails.intBottleDepositNo, NewDetails.ysnSaleable, NewDetails.ysnQuantityRequired, NewDetails.ysnScaleItem, NewDetails.ysnFoodStampable, NewDetails.ysnReturnable, NewDetails.ysnPrePriced, NewDetails.ysnOpenPricePLU, NewDetails.ysnLinkedItem, NewDetails.strVendorCategory
	, NewDetails.ysnCountBySINo, NewDetails.strSerialNoBegin, NewDetails.strSerialNoEnd, NewDetails.ysnIdRequiredLiquor, NewDetails.ysnIdRequiredCigarette, NewDetails.intMinimumAge, NewDetails.ysnApplyBlueLaw1, NewDetails.ysnApplyBlueLaw2, NewDetails.ysnCarWash, NewDetails.intItemTypeCode, NewDetails.intItemTypeSubCode
	, NewDetails.ysnAutoCalculateFreight, NewDetails.intFreightMethodId, NewDetails.dblFreightRate, NewDetails.intShipViaId, NewDetails.intNegativeInventory, NewDetails.dblReorderPoint, NewDetails.dblMinOrder, NewDetails.dblSuggestedQty, NewDetails.dblLeadTime, NewDetails.strCounted, NewDetails.intCountGroupId, NewDetails.ysnCountedDaily
	, NewDetails.ysnLockedInventory, NewDetails.strStorageUnitNo, NewDetails.ysnStorageUnitRequired, NewDetails.intAllowZeroCostTypeId, NewDetails.intSort, 1
FROM @New NewDetails
LEFT JOIN tblICItemLocation ItemLocation
	ON ItemLocation.intLocationId = NewDetails.intLocationId AND ItemLocation.intItemId = NewDetails.intItemId
WHERE ItemLocation.intItemLocationId IS NULL

SET @intNewItemLocationId = SCOPE_IDENTITY()

IF (@intNewItemLocationId IS NOT NULL)
BEGIN
	INSERT INTO tblICItemPricing (intItemId, intItemLocationId) 
	SELECT  NewDetails.intItemId
		, @intNewItemLocationId
	FROM @New NewDetails
	LEFT JOIN tblICItemPricing ItemPricing
		ON ItemPricing.intItemLocationId = @intNewItemLocationId AND ItemPricing.intItemId = NewDetails.intItemId
	WHERE ItemPricing.intItemPricingId IS NULL
	
	-- Add the audit logs
	BEGIN
	DECLARE @strDescription NVARCHAR(400)
	
	SET @strDescription = 'Duplicated item location from Copy to Store screen'
	EXEC	dbo.uspSMAuditLog 
				@keyValue = @intSourceItemId			 -- Item Id. 
				,@screenName = 'Inventory.view.Item'     -- Screen Namespace
				,@entityId = @intEntityUserSecurityId		 -- Entity Id.
				,@actionType = 'Duplicated'                  -- Action Type
				,@changeDescription = @strDescription
	END
END
