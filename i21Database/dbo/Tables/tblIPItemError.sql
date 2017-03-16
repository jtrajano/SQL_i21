CREATE TABLE [dbo].[tblIPItemError]
(
	intStageItemId INT identity(1, 1)
	,strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
	,strItemType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strShortName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strCommodity NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strCategoryCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strItemStatus NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_tblIPItemError_strItemStatus] DEFAULT(('Active'))
	,strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strItemControl NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[strStockUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,ysnStockUOM BIT CONSTRAINT [DF_tblIPItemError_ysnStockUOM] DEFAULT((1))
	,dblStockUOMQty NUMERIC(18, 6) NULL
	,dblWeight NUMERIC(18, 6) NULL
	,dblWidth NUMERIC(18, 6) NULL
	,dblDepth NUMERIC(18, 6) NULL
	,dblHeight NUMERIC(18, 6) NULL
	,strReceiveUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strIssueUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strDimensionUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strRecipeItemName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strLifeTimeType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intLifeTime INT NULL
	,intReceiveLife INT NULL
	,strPackingType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strRotationType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strNMFC NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
	,ysnStrictTracking BIT NULL
	,dblPalletQty NUMERIC(18, 6)
	,strRouteName1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strRouteName2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strRouteName3 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strMaterialCode2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strMaterialCode3 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strMaterialCode4 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strMaterialSizeCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strInventoryTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[intBagsPerCase] INT NULL
	,intInnerUnits INT NULL
	,intLayerPerPallet INT NULL
	,intUnitPerLayer INT NULL
	,intCasesPerPallet INT NULL
	,dblUnitsPerCase NUMERIC(18, 6) NULL
	,strOwner NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL
	,strCustomerItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strPackingTypeUOM NVARCHAR(16) COLLATE Latin1_General_CI_AS NULL
	,dtmCreated DATETIME NULL
	,strCreatedUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmLastModified DATETIME NULL
	,strLastModifiedUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strWorkInstruction NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,strNote NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intShelfLifeTime INT NULL
	,intStorageLifeTime INT NULL
	,strPackType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strWeightControlCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[dblBlendWeight] NUMERIC(18, 6) NULL
	,strScheduleLine NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dblNetWeightLB NUMERIC(18, 6) NULL
	,dblCaseWeight NUMERIC(18, 6) NULL
	,strWarehouseStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,ysnRepack BIT NULL
	,ysnPrintCircleU BIT NULL
	,[ysnIsVendorLotIdMandatory] BIT NULL
	,ysnIsLotAliasMandatory BIT NULL
	,ysnSellableItem BIT NULL
	,dblPricePerUnit NUMERIC(18, 6) NULL
	,dblQuarantineDuration NUMERIC(18, 6) NULL
	,dblRiskScore INT NULL
	,dblDensity NUMERIC(18, 6) NULL
	,dblMinStockWeeks NUMERIC(18, 6) NULL
	,dblFullContainerSize NUMERIC(18, 6) NULL
	,strItemGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strBlender NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmDateAvailable DATETIME NULL
	,strSKUItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,ysnDeleted BIT DEFAULT 0
	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[strImportStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL  
	,[strSessionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strLoggedOnUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_tblIPItemError_strLoggedOnUserName] DEFAULT((HOST_NAME()))
	,dtmTransactionDate DATETIME NULL CONSTRAINT [DF_tblMFItemError_dtmTransactionDate] DEFAULT((getdate()))
	,CONSTRAINT [PK_tblIPItemError_intStageItemId] PRIMARY KEY ([intStageItemId]) 
)
