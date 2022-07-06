CREATE TABLE [dbo].[tblApiSchemaTransformItemLocation] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location.
	strStorageLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The storage location.
	strStorageUnit NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The storage unit.
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location description.
	strFamily NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location family.
	strClass NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location class.
	strProductCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location product code.
	strPassportFuelId1 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location passport fuel ID 1.
	strPassportFuelId2 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location passport fuel ID 2.
	strPassportFuelId3 NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location passport fuel ID 3.
	ysnTaxFlag1 BIT NULL, -- Check if tax flag 1.
	ysnTaxFlag2 BIT NULL, -- Check if tax flag 2.
	ysnTaxFlag3 BIT NULL, -- Check if tax flag 3.
	ysnTaxFlag4 BIT NULL, -- Check if tax flag 4.
	ysnPromotionalItem BIT NULL, -- Check if promotional item.
	ysnStorageUnitRequired BIT NULL, -- Check if storage unit required.
	ysnDepositRequired BIT NULL, -- Check if deposit required.
	ysnActive BIT NULL, -- Check if active.
	intBottleDepositNo INT NULL, -- The item location bottle deposit number.
	ysnSaleable BIT NULL, -- Check if sealable.
	ysnQuantityRequired BIT NULL, -- Check if quantity required.
	ysnScaleItem BIT NULL, -- Check if scale item.
	ysnFoodStampable BIT NULL, -- Check if food stampable.
	ysnReturnable BIT NULL, -- Check if returnable.
	ysnPrePriced BIT NULL, -- Check if pre-priced.
	ysnOpenPricePLU BIT NULL, -- Check if open price PLU.
	ysnLinkedItem BIT NULL, -- Check if linked item.
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location vendor.
	strVendorCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location vendor category.
	ysnIdRequiredLiquor BIT NULL, -- Check if ID is required for liquour.
	ysnIdRequiredCigarette BIT NULL, -- Check if ID is required for cigarette.
	intMinimumAge INT NULL, -- The item location minimum age.
	ysnApplyBlueLaw1 BIT NULL, -- Check if blue law 1 applies.
	ysnApplyBlueLaw2 BIT NULL, -- Check if blue law 2 applies.
	ysnCarWash BIT NULL, -- Check if car wash.
	strItemTypeCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location item type code.
	intItemTypeSubCode INT NULL, -- The item locatin item type subcode.
	dblReorderPoint NUMERIC(38, 20), -- The item location re-order point.
	dblMinOrder NUMERIC(38, 20), -- The item location minimum order.
	dblSuggestedQty NUMERIC(38, 20), -- The item location suggested quantity.
	dblLeadTime NUMERIC(38, 20), -- The item location lead time.
	strCounted NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location counted.
	strCountGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location count group.
	ysnCountedDaily BIT NULL, -- Check if counted daily.
	ysnCountBySINo BIT NULL, -- Check if count by serial number.
	strSerialNoBegin NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location serial number begin.
	strSerialNoEnd NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location serial number end.
	ysnAutoCalculateFreight BIT NULL, -- Check if auto calculate freight.
	dblFreightRate NUMERIC(38, 20), -- The item location freight rate.
	strFreightTerm NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location freight term.
	strCostingMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location costing method.
	strAllowNegativeInventory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location allow negative inventory.
	strReceiveUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location receive unit of measure.
	strIssueUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location issue unit of measure.
	strGrossUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location gross unit of measure.
	strDepositPLU NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location deposit PLU.
	strShipVia NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location ship via.
	strAllowZeroCost NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location allow zero cost.
	strStorageUnitNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item location storage unit number.
	strCostAdjustmentType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL -- The item location cost adjustment type.
)