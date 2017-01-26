﻿CREATE PROCEDURE [dbo].[uspICCopyItemLocation]
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
       [intLocationId] = s.intLocationId
      ,[intVendorId] = s.intVendorId
      ,[strDescription] = s.strDescription
      ,[intCostingMethod] = s.intCostingMethod
      ,[intAllowNegativeInventory] = s.intAllowNegativeInventory
      ,[intSubLocationId] = s.intSubLocationId
      ,[intStorageLocationId] = s.intStorageLocationId
      ,[intIssueUOMId] = s.intIssueUOMId
      ,[intReceiveUOMId] = s.intReceiveUOMId
      ,[intFamilyId] = s.intFamilyId
      ,[intClassId] = s.intClassId
      ,[intProductCodeId] = s.intProductCodeId
      ,[intFuelTankId] = s.intFuelTankId
      ,[strPassportFuelId1] = s.strPassportFuelId1
      ,[strPassportFuelId2] = s.strPassportFuelId2
      ,[strPassportFuelId3] = s.strPassportFuelId3
      ,[ysnTaxFlag1] = s.ysnTaxFlag1
      ,[ysnTaxFlag2] = s.ysnTaxFlag2
      ,[ysnTaxFlag3] = s.ysnTaxFlag3
      ,[ysnTaxFlag4] = s.ysnTaxFlag4
      ,[ysnPromotionalItem] = s.ysnPromotionalItem
      ,[intMixMatchId] = s.intMixMatchId
      ,[ysnDepositRequired] = s.ysnDepositRequired
      ,[intDepositPLUId] = s.intDepositPLUId
      ,[intBottleDepositNo] = s.intBottleDepositNo
      ,[ysnSaleable] = s.ysnSaleable
      ,[ysnQuantityRequired] = s.ysnQuantityRequired
      ,[ysnScaleItem] = s.ysnScaleItem
      ,[ysnFoodStampable] = s.ysnFoodStampable
      ,[ysnReturnable] = s.ysnReturnable
      ,[ysnPrePriced] = s.ysnPrePriced
      ,[ysnOpenPricePLU] = s.ysnOpenPricePLU
      ,[ysnLinkedItem] = s.ysnLinkedItem
      ,[strVendorCategory] = s.strVendorCategory
      ,[ysnCountBySINo] = s.ysnCountBySINo
      ,[strSerialNoBegin] = s.strSerialNoBegin
      ,[strSerialNoEnd] = s.strSerialNoEnd
      ,[ysnIdRequiredLiquor] = s.ysnIdRequiredLiquor
      ,[ysnIdRequiredCigarette] = s.ysnIdRequiredCigarette
      ,[intMinimumAge] = s.intMinimumAge
      ,[ysnApplyBlueLaw1] = s.ysnApplyBlueLaw1
      ,[ysnApplyBlueLaw2] = s.ysnApplyBlueLaw2
      ,[ysnCarWash] = s.ysnCarWash
      ,[intItemTypeCode] = s.intItemTypeCode
      ,[intItemTypeSubCode] = s.intItemTypeSubCode
      ,[ysnAutoCalculateFreight] = s.ysnAutoCalculateFreight
      ,[intFreightMethodId] = s.intFreightMethodId
      ,[dblFreightRate] = s.dblFreightRate
      ,[intShipViaId] = s.intShipViaId
      ,[intNegativeInventory] = s.intNegativeInventory
      ,[dblReorderPoint] = s.dblReorderPoint
      ,[dblMinOrder] = s.dblMinOrder
      ,[dblSuggestedQty] = s.dblSuggestedQty
      ,[dblLeadTime] = s.dblLeadTime
      ,[strCounted] = s.strCounted
      ,[intCountGroupId] = s.intCountGroupId
      ,[ysnCountedDaily] = s.ysnCountedDaily
      ,[ysnLockedInventory] = s.ysnLockedInventory
      ,[intSort] = s.intSort
FROM tblICItemLocation d
	INNER JOIN @Source s ON s.intLocationId = d.intLocationId
WHERE d.intItemId IN (SELECT Value FROM dbo.fnICSplitStringToTable(@strDestinationItemIds, ','))

DECLARE @intItemId INT

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

DECLARE cur CURSOR
FOR
	SELECT DISTINCT Value
	FROM dbo.fnICSplitStringToTable(@strDestinationItemIds, ',')

OPEN cur

FETCH NEXT FROM cur INTO @intItemId

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO @New(intItemId, intLocationId, intVendorId, strDescription, intCostingMethod, intAllowNegativeInventory, intSubLocationId, intStorageLocationId, intIssueUOMId, intReceiveUOMId, intFamilyId
		, intClassId, intProductCodeId, intFuelTankId, strPassportFuelId1, strPassportFuelId2, strPassportFuelId3, ysnTaxFlag1, ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnPromotionalItem, intMixMatchId
		, ysnDepositRequired, intDepositPLUId, intBottleDepositNo, ysnSaleable, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable, ysnReturnable, ysnPrePriced, ysnOpenPricePLU, ysnLinkedItem, strVendorCategory
		, ysnCountBySINo, strSerialNoBegin, strSerialNoEnd, ysnIdRequiredLiquor, ysnIdRequiredCigarette, intMinimumAge, ysnApplyBlueLaw1, ysnApplyBlueLaw2, ysnCarWash, intItemTypeCode, intItemTypeSubCode
		, ysnAutoCalculateFreight, intFreightMethodId, dblFreightRate, intShipViaId, intNegativeInventory, dblReorderPoint, dblMinOrder, dblSuggestedQty, dblLeadTime, strCounted, intCountGroupId, ysnCountedDaily
		, ysnLockedInventory, intSort)
	SELECT
		  @intItemId, s.intLocationId, s.intVendorId, s.strDescription, s.intCostingMethod, s.intAllowNegativeInventory, s.intSubLocationId, s.intStorageLocationId, s.intIssueUOMId, s.intReceiveUOMId, s.intFamilyId
		, s.intClassId, s.intProductCodeId, s.intFuelTankId, s.strPassportFuelId1, s.strPassportFuelId2, s.strPassportFuelId3, s.ysnTaxFlag1, s.ysnTaxFlag2, s.ysnTaxFlag3, s.ysnTaxFlag4, s.ysnPromotionalItem, s.intMixMatchId
		, s.ysnDepositRequired, s.intDepositPLUId, s.intBottleDepositNo, s.ysnSaleable, s.ysnQuantityRequired, s.ysnScaleItem, s.ysnFoodStampable, s.ysnReturnable, s.ysnPrePriced, s.ysnOpenPricePLU, s.ysnLinkedItem, s.strVendorCategory
		, s.ysnCountBySINo, s.strSerialNoBegin, s.strSerialNoEnd, s.ysnIdRequiredLiquor, s.ysnIdRequiredCigarette, s.intMinimumAge, s.ysnApplyBlueLaw1, s.ysnApplyBlueLaw2, s.ysnCarWash, s.intItemTypeCode, s.intItemTypeSubCode
		, s.ysnAutoCalculateFreight, s.intFreightMethodId, s.dblFreightRate, s.intShipViaId, s.intNegativeInventory, s.dblReorderPoint, s.dblMinOrder, s.dblSuggestedQty, s.dblLeadTime, s.strCounted, s.intCountGroupId, s.ysnCountedDaily
		, s.ysnLockedInventory, s.intSort
	FROM @Source s
		LEFT OUTER JOIN tblICItemLocation d ON d.intLocationId = s.intLocationId
			AND d.intItemId = @intItemId
	WHERE d.intItemId IS NULL
	
	FETCH NEXT FROM cur INTO @intItemId
END

CLOSE cur
DEALLOCATE cur

INSERT INTO tblICItemLocation(intItemId, intLocationId, intVendorId, strDescription, intCostingMethod, intAllowNegativeInventory, intSubLocationId, intStorageLocationId, intIssueUOMId, intReceiveUOMId, intFamilyId
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
FROM @New