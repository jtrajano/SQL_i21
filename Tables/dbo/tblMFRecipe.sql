﻿CREATE TABLE [dbo].[tblMFRecipe]
(
	[intRecipeId] INT NOT NULL  IDENTITY(1,1),
	[strName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intItemUOMId] INT NULL, 
	[intLocationId] INT NULL,  
    [intVersionNo] INT NOT NULL CONSTRAINT [DF_tblMFRecipe_intVersionNo] DEFAULT 1, 
	[intRecipeTypeId] INT NULL,
	[intManufacturingProcessId] INT NULL,
    [ysnActive] BIT NOT NULL CONSTRAINT [DF_tblMFRecipe_ysnActive] DEFAULT 0, 
    [ysnImportOverride] BIT NOT NULL CONSTRAINT [DF_tblMFRecipe_ysnImportOverride] DEFAULT 0,
	[ysnAutoBlend] BIT NOT NULL CONSTRAINT [DF_tblMFRecipe_ysnAutoBlend] DEFAULT 0,
	[intCustomerId] INT,
	[intFarmId] INT,
	[intFieldId] INT,
	[intCostTypeId] INT NULL,
	[intMarginById] [int] NULL,
	[dblMargin] NUMERIC(18,6) NULL DEFAULT 0,
	[dblDiscount] NUMERIC(18,6) NULL DEFAULT 0,
	[intMarginUOMId] [int] NULL,
	[intOneLinePrintId] INT NULL,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFRecipe_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFRecipe_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFRecipe_intConcurrencyId] DEFAULT 0, 
	[dtmValidFrom] DATETIME NULL,
	[dtmValidTo] DATETIME NULL,
	[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,

    CONSTRAINT [PK_tblMFRecipe_intRecipeId] PRIMARY KEY ([intRecipeId]), 
    CONSTRAINT [FK_tblMFRecipe_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFRecipe_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFRecipe_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblMFRecipe_tblMFManufacturingProcess_intManufacturingProcessId] FOREIGN KEY ([intManufacturingProcessId]) REFERENCES [tblMFManufacturingProcess]([intManufacturingProcessId]),
	CONSTRAINT [FK_tblMFRecipe_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer]([intEntityId]),
	CONSTRAINT [FK_tblMFRecipe_tblMFRecipeType_intRecipeTypeId] FOREIGN KEY ([intRecipeTypeId]) REFERENCES [tblMFRecipeType]([intRecipeTypeId]),
	CONSTRAINT [FK_tblMFRecipe_tblMFMarginBy_intMarginById] FOREIGN KEY ([intMarginById]) REFERENCES [tblMFMarginBy]([intMarginById]),
	CONSTRAINT [FK_tblMFRecipe_tblMFCostType_intCostTypeId] FOREIGN KEY ([intCostTypeId]) REFERENCES [tblMFCostType]([intCostTypeId]),
	CONSTRAINT [FK_tblMFRecipe_tblICUnitMeasure_intMarginUOMId] FOREIGN KEY ([intMarginUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblMFRecipe_tblMFOneLinePrint_intOneLinePrintId] FOREIGN KEY ([intOneLinePrintId]) REFERENCES [tblMFOneLinePrint]([intOneLinePrintId])
)

GO

CREATE INDEX [IX_tblMFRecipe_intItemId] ON [dbo].[tblMFRecipe] ([intItemId])
