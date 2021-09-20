CREATE TABLE [dbo].[tblApiSchemaRecipe]
(
	[intKey] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [guiApiUniqueId] UNIQUEIDENTIFIER NOT NULL,
    [intRowNumber] INT NULL,
	[strRecipeName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblQuantity] NUMERIC(18, 6) NULL,
    [strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intVersionNo] INT NULL,
	[strRecipeType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strManufacturingProcess] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFarm] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCostType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarginBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblMargin] NUMERIC(38, 20) NULL,
	[dblDiscount] NUMERIC(38, 20) NULL,
	[strOneLinePrint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmValidFrom] DATETIME NULL,
	[dtmValidTo] DATETIME NULL
)
