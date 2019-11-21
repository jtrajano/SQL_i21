CREATE PROCEDURE dbo.uspICApplyLocationsToItems @intSourceLocationId INT, @strIdentifier NVARCHAR(100), @intUserId INT,
	@ysnCopyPrice BIT = 0, @ysnCopyPriceLevel BIT = 0, @ysnCopyPromotionalPrice BIT = 0
AS

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
	, intClassId, intProductCodeId, intFuelTankId, strPassportFuelId1, strPassportFuelId2, strPassportFuelId3, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
	, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
	, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
	, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
	, ysnLockedInventory, ysnStorageUnitRequired, intAllowZeroCostTypeId, intSort, intCreatedByUserId, dtmDateCreated
)
SElECT
	  si.intItemId
	, sil.intLocationId
	, source.intVendorId
	, source.strDescription
	, source.intCostingMethod
	, source.intAllowNegativeInventory
	, source.intSubLocationId
	, source.intStorageLocationId
	, source.intGrossUOMId
	, source.intIssueUOMId
	, source.intReceiveUOMId
	, source.intFamilyId
	, source.intClassId, source.intProductCodeId, source.intFuelTankId, source.strPassportFuelId1, source.strPassportFuelId2, source.strPassportFuelId3, source.ysnTaxFlag1, source.ysnTaxFlag2, source.ysnTaxFlag3, source.ysnTaxFlag4, source.ysnPromotionalItem, source.intMixMatchId
	, source.ysnDepositRequired, source.intDepositPLUId, source.intBottleDepositNo, source.ysnSaleable, source.ysnQuantityRequired, source.ysnScaleItem, source.ysnFoodStampable, source.ysnReturnable, source.ysnPrePriced, source.ysnOpenPricePLU, source.ysnLinkedItem, source.strVendorCategory
	, source.ysnCountBySINo, source.strSerialNoBegin, source.strSerialNoEnd, source.ysnIdRequiredLiquor, source.ysnIdRequiredCigarette, source.intMinimumAge, source.ysnApplyBlueLaw1, source.ysnApplyBlueLaw2, source.ysnCarWash, source.intItemTypeCode, source.intItemTypeSubCode
	, source.ysnAutoCalculateFreight, source.intFreightMethodId, source.dblFreightRate, source.intShipViaId, source.intNegativeInventory, source.dblReorderPoint, source.dblMinOrder, source.dblSuggestedQty, source.dblLeadTime, source.strCounted, source.intCountGroupId, source.ysnCountedDaily
	, source.ysnLockedInventory, source.ysnStorageUnitRequired, source.intAllowZeroCostTypeId, source.intSort, @intUserId, GETUTCDATE()
FROM tblICStagingItem si
	CROSS APPLY (
		SELECT DISTINCT csil.intLocationId
		FROM tblICStagingItemLocation csil
		WHERE csil.strLocationName = @strIdentifier
			AND csil.intLocationId <> @intSourceLocationId
	) sil
	CROSS APPLY (
		SELECT TOP 1 xl.*
		FROM tblICItemLocation xl
		WHERE xl.intLocationId = @intSourceLocationId
			AND xl.intLocationId <> sil.intLocationId
	) source
WHERE si.strItemNo = @strIdentifier
	AND NOT EXISTS(SELECT * FROM tblICItemLocation WHERE intItemId = si.intItemId AND intLocationId = sil.intLocationId)

IF ISNULL(@ysnCopyPrice, 0) = 0
BEGIN
	INSERT INTO tblICItemPricing (intItemId, intItemLocationId, strPricingMethod, intCreatedByUserId, dtmDateCreated)
	SELECT i.intItemId, il.intItemLocationId, 'None', @intUserId, GETUTCDATE()
	FROM tblICStagingItem i
		INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
			AND il.intLocationId <> @intSourceLocationId
	WHERE i.strItemNo = @strIdentifier
		AND NOT EXISTS(SELECT * FROM tblICItemPricing WHERE intItemId = i.intItemId AND intItemLocationId = il.intItemLocationId)
END
ELSE
BEGIN
	INSERT INTO tblICItemPricing (
		  intItemId
		, intItemLocationId
		, dblAmountPercent
		, dblSalePrice
		, dblMSRPPrice
		, strPricingMethod
		, dblLastCost
		, dblStandardCost
		, dblAverageCost
		, dblEndMonthCost
		, dblDefaultGrossPrice
		, intSort
		, ysnIsPendingUpdate
		, dtmDateChanged
		, intCreatedByUserId
		, dtmDateCreated)
	SELECT 
		  i.intItemId
		, il.intItemLocationId
		, source.dblAmountPercent
		, source.dblSalePrice
		, source.dblMSRPPrice
		, source.strPricingMethod
		, source.dblLastCost
		, source.dblStandardCost
		, source.dblAverageCost
		, source.dblEndMonthCost
		, source.dblDefaultGrossPrice
		, source.intSort
		, source.ysnIsPendingUpdate
		, source.dtmDateChanged
		, @intUserId, GETUTCDATE()
	FROM tblICStagingItem i
		INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
			AND il.intLocationId <> @intSourceLocationId
		OUTER APPLY (
			SELECT TOP 1 xp.*
			FROM tblICItemPricing xp
			INNER JOIN tblICItemLocation xl ON xl.intItemId = xp.intItemId
				AND xp.intItemId = i.intItemId
				AND xl.intLocationId = @intSourceLocationId
			INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = xl.intLocationId
			WHERE xl.intLocationId = @intSourceLocationId
				AND xl.intLocationId <> il.intLocationId
		) source
	WHERE i.strItemNo = @strIdentifier
		AND NOT EXISTS(SELECT * FROM tblICItemPricing WHERE intItemId = i.intItemId AND intItemLocationId = il.intItemLocationId)
END

IF ISNULL(@ysnCopyPriceLevel, 0) = 1
BEGIN
INSERT INTO tblICItemPricingLevel(
	  intItemId
	, intItemLocationId
	, strPriceLevel
	, intItemUnitMeasureId
	, dblUnit
	, dtmEffectiveDate
	, dblMin
	, dblMax
	, strPricingMethod
	, dblAmountRate
	, dblUnitPrice
	, strCommissionOn
	, dblCommissionRate
	, intCurrencyId
	, intSort
	, dtmDateChanged
	, dtmDateCreated
	, intCreatedByUserId
)
SELECT
	  i.intItemId
	, il.intItemLocationId
	, strPriceLevel = matchedLevel.strPricingLevelName
	, intItemUnitMeasureId = source.intItemUnitMeasureId
	, dblUnit = source.dblUnit
	, dtmEffectiveDate = source.dtmEffectiveDate
	, dblMin = source.dblMin
	, dblMax = source.dblMax
	, strPricingMethod = source.strPricingMethod
	, dblAmountRate = source.dblAmountRate
	, dblUnitPrice = source.dblUnitPrice
	, strCommissionOn = source.strCommissionOn
	, dblCommissionRate = source.dblCommissionRate
	, intCurrencyId = source.intCurrencyId
	, intSort = matchedLevel.intPricingLevel
	, dtmDateChanged = GETDATE()
	, dtmDateCreated = GETUTCDATE()
	, intCreatedByUserId = @intUserId
FROM tblICStagingItem i
	INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
		AND il.intLocationId <> @intSourceLocationId
	OUTER APPLY (
		SELECT xp.*, lvl.strPricingLevelName, lvl.intPricingLevel
		FROM tblICItemPricingLevel xp
			LEFT JOIN tblICItemLocation xl ON xl.intItemId = xp.intItemId
				AND xp.intItemId = i.intItemId
				AND xl.intLocationId = @intSourceLocationId
			LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = xl.intLocationId
			OUTER APPLY (
				SELECT TOP 1 innerLevel.strPricingLevelName, innerLevel.intSort intPricingLevel 
				FROM tblSMCompanyLocationPricingLevel innerLevel
				WHERE innerLevel.strPricingLevelName = xp.strPriceLevel
			) lvl
		WHERE xl.intLocationId = @intSourceLocationId
			AND xl.intLocationId <> il.intLocationId
	) source
	OUTER APPLY (
		SELECT MAX(innerLevel.strPricingLevelName) strPricingLevelName, MAX(innerLevel.intSort) intPricingLevel 
		FROM tblSMCompanyLocationPricingLevel innerLevel
		WHERE innerLevel.intCompanyLocationId = il.intLocationId
			AND (innerLevel.intSort <= source.intPricingLevel)
	) matchedLevel
WHERE i.strItemNo = @strIdentifier
	AND NOT EXISTS(
		SELECT * 
		FROM tblICItemPricingLevel
		WHERE intItemId = i.intItemId
			AND intItemLocationId = il.intItemLocationId
			AND intItemUnitMeasureId = source.intItemUnitMeasureId
			AND dtmEffectiveDate = source.dtmEffectiveDate
			AND intSort = source.intPricingLevel
	)
ORDER BY il.intLocationId
END

IF ISNULL(@ysnCopyPromotionalPrice, 0) = 1
BEGIN
	INSERT INTO tblICItemSpecialPricing(
		  intItemId
		, intItemLocationId
		, strPromotionType
		, dtmBeginDate
		, dtmEndDate
		, intItemUnitMeasureId
		, dblUnit
		, strDiscountBy
		, dblDiscount
		, dblUnitAfterDiscount
		, dblDiscountThruQty
		, dblDiscountThruAmount
		, dblAccumulatedQty
		, dblAccumulatedAmount
		, intCurrencyId
		, intSort
		, dtmDateCreated
		, intCreatedByUserId
	)
	SELECT
		  i.intItemId
		, il.intItemLocationId
		, source.strPromotionType
		, source.dtmBeginDate
		, dtmEndDate = CASE WHEN source.dtmEndDate >= source.dtmBeginDate THEN source.dtmEndDate ELSE source.dtmBeginDate END
		, source.intItemUnitMeasureId
		, source.dblUnit
		, source.strDiscountBy
		, source.dblDiscount
		, source.dblUnitAfterDiscount
		, source.dblDiscountThruQty
		, source.dblDiscountThruAmount
		, source.dblAccumulatedQty
		, source.dblAccumulatedAmount
		, source.intCurrencyId
		, source.intSort
		, dtmDateCreated = GETUTCDATE()
		, intCreatedByUserId = @intUserId
	FROM tblICStagingItem i
		INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
			AND il.intLocationId <> @intSourceLocationId
		OUTER APPLY (
			SELECT xp.*
			FROM tblICItemSpecialPricing xp
				LEFT JOIN tblICItemLocation xl ON xl.intItemId = xp.intItemId
					AND xp.intItemId = i.intItemId
					AND xl.intLocationId = @intSourceLocationId
				LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = xl.intLocationId
			WHERE xl.intLocationId = @intSourceLocationId
				AND xl.intLocationId <> il.intLocationId
		) source
	WHERE i.strItemNo = @strIdentifier
END

DELETE FROM tblICStagingItem WHERE strItemNo = @strIdentifier
DELETE FROM tblICStagingItemLocation WHERE strLocationName = @strIdentifier