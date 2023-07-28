CREATE TABLE [dbo].[tblApiSchemaTransformCategoryLocation](
	  [intKey] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY
	, [guiApiUniqueId] [uniqueidentifier] NOT NULL
	, [intRowNumber] [int] NULL
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL			
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
	, strCashRegisterDepartment NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, ysnDefaultUseTaxFlag1 BIT NULL
	, ysnDefaultUseTaxFlag2 BIT NULL
	, ysnDefaultUseTaxFlag3 BIT NULL
	, ysnDefaultUseTaxFlag4 BIT NULL
	, ysnDefaultBlueLaw1 BIT NULL
	, ysnDefaultBlueLaw2 BIT NULL
	, intDefaultNucleusGroupID INT NULL
	, dblTargetGrossProfit NUMERIC(18,6) NULL
	, dblTargetInventoryAtCost NUMERIC(18,6) NULL
	, dblCostofInventoryatBOM NUMERIC(38,20) NULL
	, dblLowGrossMarginAlert NUMERIC(18,6) NULL
	, dblHighGrossMarginAlert NUMERIC(18,6) NULL
	, dtmLastInventoryLevelEntry DATETIME NULL
	, strGeneralItem NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, ysnNonRetailUseDepartment BIT NULL
	, ysnReportinNetorGross BIT NULL
	, ysnDepartmentforPumps BIT NULL
	, intConverttoPaidout INT NULL
	, ysnDeletefromRegister BIT NULL
	, ysnDepartmentKeyTaxed BIT NULL
	, strDefaultProductCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultFamily NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDefaultClass NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, ysnDefaultFoodStampable BIT NULL
	, ysnDefaultReturnable BIT NULL
	, ysnDefaultSaleable BIT NULL
	, ysnDefaultPrePriced BIT NULL
	, ysnDefaultIDRequiredLiquor BIT NULL
	, ysnDefaultIDRequiredCigarette BIT NULL
	, intDefaultMinimumAge INT NULL
	, ysnReportNetGross BIT NULL
	, ysnReturnable BIT NULL
	, ysnSaleable BIT NULL
	, ysnUpdatePrices BIT NULL
)