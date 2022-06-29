﻿CREATE TABLE [dbo].[tblMFRecipeItem]
(
	[intRecipeItemId] INT NOT NULL  IDENTITY(1,1), 
    [intRecipeId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
	[strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
	[dblCalculatedQuantity] NUMERIC(18, 6) NOT NULL, 
    [intItemUOMId] INT NULL,
	[intRecipeItemTypeId] INT NOT NULL,
	[strItemGroupName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_tblMFRecipeItem_strItemGroupName] DEFAULT '', 
	[dblUpperTolerance] NUMERIC(18, 6) NOT NULL , 
    [dblLowerTolerance] NUMERIC(18, 6) NOT NULL ,
    [dblCalculatedUpperTolerance] NUMERIC(18, 6) NOT NULL , 
    [dblCalculatedLowerTolerance] NUMERIC(18, 6) NOT NULL , 
    [dblShrinkage] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblMFRecipeItem_dblShrinkage] DEFAULT 0 , 
    [ysnScaled] BIT NOT NULL CONSTRAINT [DF_tblMFRecipeItem_ysnScaled] DEFAULT 0, 
    [intConsumptionMethodId] INT NULL, 
    [intStorageLocationId] INT NULL, 
    [dtmValidFrom] DATETIME NULL, 
    [dtmValidTo] DATETIME NULL, 
    [ysnYearValidationRequired] BIT NOT NULL CONSTRAINT [DF_tblMFRecipeItem_ysnYearValidationRequired] DEFAULT 0, 
    [ysnMinorIngredient] BIT NOT NULL CONSTRAINT [DF_tblMFRecipeItem_ysnMinorIngredient] DEFAULT 0,
	[intReferenceRecipeId] INT NULL,
	[ysnOutputItemMandatory] BIT NOT NULL CONSTRAINT [DF_tblMFRecipeItem_ysnOutputItemMandatory] DEFAULT 0,
    [dblScrap] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblMFRecipeItem_dblScrap] DEFAULT 0, 
    [ysnConsumptionRequired] BIT NOT NULL CONSTRAINT [DF_tblMFRecipeItem_ysnConsumptionRequired] DEFAULT 0,
	[dblCostAllocationPercentage] NUMERIC(18,6) NULL,
	[intCostDriverId] [int] NULL,
	[dblCostRate] NUMERIC(18,6) NULL,
	[intMarginById] [int] NULL,
	[dblMargin] NUMERIC(18,6) NULL,
	[ysnCostAppliedAtInvoice] BIT,
	[intCommentTypeId] INT NULL,
	[strDocumentNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intSequenceNo] INT NULL,
	ysnPartialFillConsumption BIT NOT NULL CONSTRAINT [DF_tblMFRecipeItem_ysnPartialFillConsumption] DEFAULT 1,
	[intManufacturingCellId] [int] NULL,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFRecipeItem_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFRecipeItem_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFRecipeItem_intConcurrencyId] DEFAULT 0,
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL,
	[intRowNumber] INT NULL,
	ysnImported INT NULL,
	CONSTRAINT [PK_tblMFRecipeItem_intRecipeItemId] PRIMARY KEY ([intRecipeItemId]), 
    CONSTRAINT [FK_tblMFRecipeItem_tblMFRecipe_intRecipeId] FOREIGN KEY ([intRecipeId]) REFERENCES [tblMFRecipe]([intRecipeId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMFRecipeItem_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFRecipeItem_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFRecipeItem_tblMFRecipeItemType_intRecipeItemTypeId] FOREIGN KEY ([intRecipeItemTypeId]) REFERENCES [tblMFRecipeItemType]([intRecipeItemTypeId]),
	CONSTRAINT [FK_tblMFRecipeItem_tblMFConsumptionMethod_intConsumptionMethodId] FOREIGN KEY ([intConsumptionMethodId]) REFERENCES [tblMFConsumptionMethod]([intConsumptionMethodId]),
	CONSTRAINT [FK_tblMFRecipeItem_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
	CONSTRAINT [FK_tblMFRecipeItem_tblMFMarginBy_intMarginById] FOREIGN KEY ([intMarginById]) REFERENCES [tblMFMarginBy]([intMarginById]),
	CONSTRAINT [FK_tblMFRecipeItem_tblMFCommentType_intCommentTypeId] FOREIGN KEY ([intCommentTypeId]) REFERENCES [tblMFCommentType]([intCommentTypeId]),
	CONSTRAINT [FK_tblMFRecipeItem_tblMFManufacturingCell_intManufacturingCellId] FOREIGN KEY ([intManufacturingCellId]) REFERENCES [tblMFManufacturingCell]([intManufacturingCellId]),
	CONSTRAINT [FK_tblMFRecipeItem_tblMFCostDriver_intCostDriverId] FOREIGN KEY ([intCostDriverId]) REFERENCES [tblMFCostDriver]([intCostDriverId]),
)

GO

CREATE INDEX [IX_tblMFRecipeItem_intItemId] ON [dbo].[tblMFRecipeItem] ([intItemId])
