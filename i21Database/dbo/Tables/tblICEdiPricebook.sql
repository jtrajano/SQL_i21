﻿CREATE TABLE tblICEdiPricebook (
	intEdiPricebookId INT IDENTITY(1,1) PRIMARY KEY,
	intRecordNumber INT NULL,
	strUniqueId UNIQUEIDENTIFIER NULL,
	strStoreAccountCodeWithVendor NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSellingUpcNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strUpcModifierNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVendorId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVendorsItemNumberForOrdering NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strManufacturersBrandName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSellingUpcLongDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strSellingUpcShortDescription NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	strCaseBoxSizeQuantityPerCaseBox NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strPackageSizeQuantityPerSellUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strItemSizeNormally1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strItemUnitOfMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVendorCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strOrderCaseUpcNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strOrderPackageDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strCaseCost NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strCaseRetailPrice NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRetailPrice NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strStoreDepartmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strProductFamily NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strProductClass NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strDepositRequired NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strPromotionalItem NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strPrePriced NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSaleStartDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSaleEndingDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSalePriceMultiple NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSalePrice NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSuggestedOrderQuantity NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strMinimumOrderQuantity NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVendorDiscountBeginDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVendorDiscountEndDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVendorDiscountThruQuantity NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVendorDiscountThruAmount NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRebate1BeginDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRebate1EndDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRebate1AmountUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRebate2BeginDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRebate2EndDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRebate2AmountUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strActiveInactiveDeleteIndicator NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strBottleDepositNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strInventoryGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,

	-- Fields for the Category -> Vendor Category XRef
	intCategoryId INT NULL,
	intVendorId INT NULL,
	ysnAddOrderingUPC BIT NULL,
	ysnUpdateExistingRecords BIT NULL,
	ysnAddNewRecords BIT NULL,
	ysnUpdatePrice BIT NULL,

	dtmDateCreated DATETIME NULL,
    dtmDateModified DATETIME NULL,
    intCreatedByUserId INT NULL,
    intModifiedByUserId INT NULL,
	intConcurrencyId INT NULL,

	strSubcategory	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strProductCode	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTaxFlag1		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTaxFlag2		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTaxFlag3		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTaxFlag4		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strIdRequiredLiquor NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strIdRequiredCigarettes NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strMinimumAge NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSaleable NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strOpenPLU NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strFoodStamp NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCNumber1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCModifier1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCUOM1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCQuantity1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strPurchaseSale1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCCost1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCPrice1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCNumber2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCModifier2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCUOM2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCQuantity2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strPurchaseSale2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCCost2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAltUPCPrice2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICEdiPricebook_strUniqueId]
	ON [dbo].[tblICEdiPricebook]([strUniqueId] ASC)
GO