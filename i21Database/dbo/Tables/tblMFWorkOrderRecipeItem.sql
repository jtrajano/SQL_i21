﻿CREATE TABLE [dbo].[tblMFWorkOrderRecipeItem]
(
	[intRecipeItemId] INT NOT NULL  IDENTITY(1,1), 
    [intRecipeId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
	[dblCalculatedQuantity] NUMERIC(18, 6) NOT NULL, 
    [intUOMId] INT NOT NULL,
	[intRecipeItemTypeId] INT NOT NULL,
	[strItemGroupName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_strItemGroupName] DEFAULT '', 
	[dblUpperTolerance] NUMERIC(18, 6) NOT NULL , 
    [dblLowerTolerance] NUMERIC(18, 6) NOT NULL ,
    [dblCalculatedUpperTolerance] NUMERIC(18, 6) NOT NULL , 
    [dblCalculatedLowerTolerance] NUMERIC(18, 6) NOT NULL , 
    [dblShrinkage] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_dblShrinkage] DEFAULT 0 , 
    [ysnScaled] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_ysnScaled] DEFAULT 0, 
    [intConsumptionMethodId] INT NULL, 
    [intStorageLocationId] INT NULL, 
    [dtmValidFrom] DATETIME NULL, 
    [dtmValidTo] DATETIME NULL, 
    [ysnYearValidationRequired] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_ysnYearValidationRequired] DEFAULT 0, 
    [ysnMinorIngredient] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_ysnMinorIngredient] DEFAULT 0,
	[intReferenceRecipeId] INT NULL,
	[ysnOutputItemMandatory] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_ysnOutputItemMandatory] DEFAULT 0,
    [dblScrap] NUMERIC(18, 16) NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_dblScrap] DEFAULT 0, 
    [ysnConsumptionRequired] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_ysnConsumptionRequired] DEFAULT 0,
	[dblLaborCostPerUnit] NUMERIC(18,16) NULL,
	[intLaborCostCurrencyId] INT NULL,
	[dblOverheadCostPerUnit] NUMERIC(18,16) NULL,
	[intOverheadCostCurrencyId] INT NULL,
	[dblPercentage] NUMERIC(18,16) NULL,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeItem_intConcurrencyId] DEFAULT 0,
	CONSTRAINT [PK_tblMFWorkOrderRecipeItem_intRecipeItemId] PRIMARY KEY ([intRecipeItemId]), 
    CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblMFRecipe_intRecipeId] FOREIGN KEY ([intRecipeId]) REFERENCES [tblMFRecipe]([intRecipeId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblICUnitMeasure_intUnitMeasureId_intStandardUOMId] FOREIGN KEY ([intUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblMFRecipeItemType_intRecipeItemTypeId] FOREIGN KEY ([intRecipeItemTypeId]) REFERENCES [tblMFRecipeItemType]([intRecipeItemTypeId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblMFConsumptionMethod_intConsumptionMethodId] FOREIGN KEY ([intConsumptionMethodId]) REFERENCES [tblMFConsumptionMethod]([intConsumptionMethodId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblMFRecipe_intRecipeId_intReferenceRecipeId] FOREIGN KEY ([intReferenceRecipeId]) REFERENCES [tblMFRecipe]([intRecipeId]), 
	CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblSMCurrency_intCurrencyId_intLaborCostCurrencyId] FOREIGN KEY ([intLaborCostCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
	CONSTRAINT [FK_tblMFWorkOrderRecipeItem_tblSMCurrency_intCurrencyId_intOverheadCostCurrencyId] FOREIGN KEY ([intOverheadCostCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)

GO

CREATE INDEX [IX_tblMFWorkOrderRecipeItem_intItemId] ON [dbo].[tblMFWorkOrderRecipeItem] ([intItemId])
