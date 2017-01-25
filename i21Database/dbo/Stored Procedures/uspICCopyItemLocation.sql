CREATE PROCEDURE [dbo].[uspICCopyItemLocation]
	@intSourceItemId INT,
	@strDestinationItemIds VARCHAR(8000)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @Source TABLE([intItemId] [int] NOT NULL,
	[intLocationId] [int] NULL,
	[intVendorId] [int] NULL,
	[strDescription] [nvarchar](max) NULL,
	[intCostingMethod] [int] NULL,
	[intAllowNegativeInventory] [int] NOT NULL DEFAULT ((3)),
	[intSubLocationId] [int] NULL,
	[intStorageLocationId] [int] NULL,
	[intIssueUOMId] [int] NULL,
	[intReceiveUOMId] [int] NULL,
	[intFamilyId] [int] NULL,
	[intClassId] [int] NULL,
	[intProductCodeId] [int] NULL,
	[intFuelTankId] [int] NULL,
	[strPassportFuelId1] [nvarchar](50) NULL,
	[strPassportFuelId2] [nvarchar](50) NULL,
	[strPassportFuelId3] [nvarchar](50) NULL,
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
	[ysnLockedInventory] [bit] NULL DEFAULT ((0)),
	[intSort] [int] NULL)

INSERT INTO @Source(intItemId, intLocationId, intVendorId, strDescription, intCostingMethod, intAllowNegativeInventory, intSubLocationId, intStorageLocationId, intIssueUOMId, intReceiveUOMId, intFamilyId
, intClassId, intProductCodeId, intFuelTankId, strPassportFuelId1, strPassportFuelId2, strPassportFuelId3, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
, ysnLockedInventory, intSort)
SELECT intItemId, intLocationId, intVendorId, strDescription, intCostingMethod, intAllowNegativeInventory, intSubLocationId, intStorageLocationId, intIssueUOMId, intReceiveUOMId, intFamilyId
, intClassId, intProductCodeId, intFuelTankId, strPassportFuelId1, strPassportFuelId2, strPassportFuelId3, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
, ysnLockedInventory, intSort
FROM tblICItemLocation
WHERE intItemId = @intSourceItemId

UPDATE d
SET 
       [intLocationId] = x.intLocationId
      ,[intVendorId] = x.intVendorId
      ,[strDescription] = x.strDescription
      ,[intCostingMethod] = x.intCostingMethod
      ,[intAllowNegativeInventory] = x.intAllowNegativeInventory
      ,[intSubLocationId] = x.intSubLocationId
      ,[intStorageLocationId] = x.intStorageLocationId
      ,[intIssueUOMId] = x.intIssueUOMId
      ,[intReceiveUOMId] = x.intReceiveUOMId
      ,[intFamilyId] = x.intFamilyId
      ,[intClassId] = x.intClassId
      ,[intProductCodeId] = x.intProductCodeId
      ,[intFuelTankId] = x.intFuelTankId
      ,[strPassportFuelId1] = x.strPassportFuelId1
      ,[strPassportFuelId2] = x.strPassportFuelId2
      ,[strPassportFuelId3] = x.strPassportFuelId3
      ,[ysnTaxFlag1] = x.ysnTaxFlag1
      ,[ysnTaxFlag2] = x.ysnTaxFlag2
      ,[ysnTaxFlag3] = x.ysnTaxFlag3
      ,[ysnTaxFlag4] = x.ysnTaxFlag4
      ,[ysnPromotionalItem] = x.ysnPromotionalItem
      ,[intMixMatchId] = x.intMixMatchId
      ,[ysnDepositRequired] = x.ysnDepositRequired
      ,[intDepositPLUId] = x.intDepositPLUId
      ,[intBottleDepositNo] = x.intBottleDepositNo
      ,[ysnSaleable] = x.ysnSaleable
      ,[ysnQuantityRequired] = x.ysnQuantityRequired
      ,[ysnScaleItem] = x.ysnScaleItem
      ,[ysnFoodStampable] = x.ysnFoodStampable
      ,[ysnReturnable] = x.ysnReturnable
      ,[ysnPrePriced] = x.ysnPrePriced
      ,[ysnOpenPricePLU] = x.ysnOpenPricePLU
      ,[ysnLinkedItem] = x.ysnLinkedItem
      ,[strVendorCategory] = x.strVendorCategory
      ,[ysnCountBySINo] = x.ysnCountBySINo
      ,[strSerialNoBegin] = x.strSerialNoBegin
      ,[strSerialNoEnd] = x.strSerialNoEnd
      ,[ysnIdRequiredLiquor] = x.ysnIdRequiredLiquor
      ,[ysnIdRequiredCigarette] = x.ysnIdRequiredCigarette
      ,[intMinimumAge] = x.intMinimumAge
      ,[ysnApplyBlueLaw1] = x.ysnApplyBlueLaw1
      ,[ysnApplyBlueLaw2] = x.ysnApplyBlueLaw2
      ,[ysnCarWash] = x.ysnCarWash
      ,[intItemTypeCode] = x.intItemTypeCode
      ,[intItemTypeSubCode] = x.intItemTypeSubCode
      ,[ysnAutoCalculateFreight] = x.ysnAutoCalculateFreight
      ,[intFreightMethodId] = x.intFreightMethodId
      ,[dblFreightRate] = x.dblFreightRate
      ,[intShipViaId] = x.intShipViaId
      ,[intNegativeInventory] = x.intNegativeInventory
      ,[dblReorderPoint] = x.dblReorderPoint
      ,[dblMinOrder] = x.dblMinOrder
      ,[dblSuggestedQty] = x.dblSuggestedQty
      ,[dblLeadTime] = x.dblLeadTime
      ,[strCounted] = x.strCounted
      ,[intCountGroupId] = x.intCountGroupId
      ,[ysnCountedDaily] = x.ysnCountedDaily
      ,[ysnLockedInventory] = x.ysnLockedInventory
      ,[intSort] = x.intSort
FROM tblICItemLocation d
	INNER JOIN (
		SELECT s.*
		FROM @Source s
			CROSS JOIN tblICItemLocation d
		WHERE d.intLocationId = s.intLocationId			AND d.intItemId <> @intSourceItemId
	) x ON x.intLocationId = d.intLocationId
WHERE d.intItemId IN (SELECT Value FROM dbo.fnICSplitStringToTable(@strDestinationItemIds, ','))

DECLARE @New TABLE([intItemId] [int] NOT NULL,
	[intLocationId] [int] NULL,
	[intVendorId] [int] NULL,
	[strDescription] [nvarchar](max) NULL,
	[intCostingMethod] [int] NULL,
	[intAllowNegativeInventory] [int] NOT NULL DEFAULT ((3)),
	[intSubLocationId] [int] NULL,
	[intStorageLocationId] [int] NULL,
	[intIssueUOMId] [int] NULL,
	[intReceiveUOMId] [int] NULL,
	[intFamilyId] [int] NULL,
	[intClassId] [int] NULL,
	[intProductCodeId] [int] NULL,
	[intFuelTankId] [int] NULL,
	[strPassportFuelId1] [nvarchar](50) NULL,
	[strPassportFuelId2] [nvarchar](50) NULL,
	[strPassportFuelId3] [nvarchar](50) NULL,
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
	[ysnLockedInventory] [bit] NULL DEFAULT ((0)),
	[intSort] [int] NULL)
INSERT INTO @New(intItemId, intLocationId, intVendorId, strDescription, intCostingMethod, intAllowNegativeInventory, intSubLocationId, intStorageLocationId, intIssueUOMId, intReceiveUOMId, intFamilyId
	, intClassId, intProductCodeId, intFuelTankId, strPassportFuelId1, strPassportFuelId2, strPassportFuelId3, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
	, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
	, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
	, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
	, ysnLockedInventory, intSort)
SELECT DISTINCT 
	 d.[intItemId]
	, s.intLocationId, s.intVendorId, s.strDescription, s.intCostingMethod, s.intAllowNegativeInventory, s.intSubLocationId, s.intStorageLocationId, s.intIssueUOMId, s.intReceiveUOMId, s.intFamilyId
	, s.intClassId, s.intProductCodeId, s.intFuelTankId, s.strPassportFuelId1, s.strPassportFuelId2, s.strPassportFuelId3, s.ysnTaxFlag1, s.ysnTaxFlag2, s.ysnTaxFlag3, s.ysnTaxFlag4, s.ysnPromotionalItem, s.intMixMatchId
	, s.ysnDepositRequired, s.intDepositPLUId, s.intBottleDepositNo, s.ysnSaleable, s.ysnQuantityRequired, s.ysnScaleItem, s.ysnFoodStampable, s.ysnReturnable, s.ysnPrePriced, s.ysnOpenPricePLU, s.ysnLinkedItem, s.strVendorCategory
	, s.ysnCountBySINo, s.strSerialNoBegin, s.strSerialNoEnd, s.ysnIdRequiredLiquor, s.ysnIdRequiredCigarette, s.intMinimumAge, s.ysnApplyBlueLaw1, s.ysnApplyBlueLaw2, s.ysnCarWash, s.intItemTypeCode, s.intItemTypeSubCode
	, s.ysnAutoCalculateFreight, s.intFreightMethodId, s.dblFreightRate, s.intShipViaId, s.intNegativeInventory, s.dblReorderPoint, s.dblMinOrder, s.dblSuggestedQty, s.dblLeadTime, s.strCounted, s.intCountGroupId, s.ysnCountedDaily
	, s.ysnLockedInventory, s.intSort
FROM @Source s
	CROSS JOIN tblICItemLocation d
WHERE s.intLocationId <> d.intLocationId
	AND d.intLocationId NOT IN (
		SELECT d.intLocationId
		FROM tblICItemLocation d
			INNER JOIN (
				SELECT s.*
				FROM @Source s
					CROSS JOIN tblICItemLocation d
				WHERE d.intLocationId = s.intLocationId
					AND d.intItemId <> @intSourceItemId
					AND d.intItemId IN (SELECT Value FROM dbo.fnICSplitStringToTable(@strDestinationItemIds, ','))
			) x ON x.intLocationId = d.intLocationId
	)
	AND d.intItemId IN (SELECT Value FROM dbo.fnICSplitStringToTable(@strDestinationItemIds, ','))

DELETE n
FROM @New n
	INNER JOIN (
		SELECT d.*
		FROM @Source s
			CROSS JOIN tblICItemLocation d
		WHERE d.intLocationId = s.intLocationId
			AND d.intItemId <> @intSourceItemId
			AND d.intItemId IN (SELECT Value FROM dbo.fnICSplitStringToTable(@strDestinationItemIds, ','))
	) x ON x.intItemId = n.intItemId
		AND x.intLocationId = n.intLocationId

INSERT INTO tblICItemLocation(intItemId,  intLocationId, strDescription)
SELECT intItemId, intLocationId, strDescription
FROM @New
WHERE intItemId <> @intSourceItemId