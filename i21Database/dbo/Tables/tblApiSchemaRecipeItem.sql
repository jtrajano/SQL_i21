CREATE TABLE [dbo].[tblApiSchemaRecipeItem]
(
	[intKey] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [guiApiUniqueId] UNIQUEIDENTIFIER NOT NULL,
    [intRowNumber] INT NULL,

	[strRecipeName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeHeaderItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intVersionNo] INT NOT NULL,
	[strRecipeItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [dblQuantity] NUMERIC(18, 6) NULL,
    [strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemGroupName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblUpperTolerance] NUMERIC(18, 6) NULL,
    [dblLowerTolerance] NUMERIC(18, 6) NULL,
    [dblShrinkage] NUMERIC(18, 6) NULL,
    [ysnScaled] BIT NULL, 
    [strConsumptionMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strStorageLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dtmValidFrom] DATETIME NULL,
    [dtmValidTo] DATETIME NULL,
    [ysnYearValidationRequired] BIT NULL, 
    [ysnMinorIngredient] BIT NULL,
	[ysnOutputItemMandatory] BIT NULL,
	[dblScrap] NUMERIC(18, 6) NULL, 
    [ysnConsumptionRequired] BIT NULL,
	[dblCostAllocationPercentage] NUMERIC(18,6) NULL,
	[strMarginBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblMargin] NUMERIC(18,6) NULL,
	[ysnCostAppliedAtInvoice] BIT NULL,
	[strCommentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDocumentNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ysnPartialFillConsumption] BIT NULL,
)
