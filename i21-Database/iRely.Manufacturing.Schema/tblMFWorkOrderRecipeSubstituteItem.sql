﻿CREATE TABLE [dbo].[tblMFWorkOrderRecipeSubstituteItem]
(
	[intWorkOrderId] int Not NULL,
	[intRecipeSubstituteItemId] INT NOT NULL, 
    [intRecipeItemId] INT NOT NULL,
	[intRecipeId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [intSubstituteItemId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [dblSubstituteRatio] NUMERIC(18, 6) NOT NULL, 
    [dblMaxSubstituteRatio] NUMERIC(18, 6) NOT NULL,
    [dblCalculatedUpperTolerance] NUMERIC(18, 6) NOT NULL , 
    [dblCalculatedLowerTolerance] NUMERIC(18, 6) NOT NULL , 
	[intRecipeItemTypeId] INT NOT NULL,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeSubstituteItem_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeSubstituteItem_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeSubstituteItem_intConcurrencyId] DEFAULT 0,
	[ysnLock] BIT CONSTRAINT [DF_tblMFWorkOrderRecipeSubstituteItem_ysnLock] DEFAULT 0, 
    CONSTRAINT [PK_tblMFWorkOrderRecipeSubstituteItem_intRecipeSubstituteItemId] PRIMARY KEY ([intRecipeSubstituteItemId],[intWorkOrderId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeSubstituteItem_tblMFRecipe_intRecipeId] FOREIGN KEY ([intRecipeId],[intWorkOrderId]) REFERENCES [tblMFWorkOrderRecipe]([intRecipeId],[intWorkOrderId]), 
	CONSTRAINT [FK_tblMFWorkOrderRecipeSubstituteItem_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeSubstituteItem_tblICItem_intItemId_intSubstituteItemId] FOREIGN KEY ([intSubstituteItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeSubstituteItem_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeSubstituteItem_tblMFRecipeItemType_intRecipeItemTypeId] FOREIGN KEY ([intRecipeItemTypeId]) REFERENCES [tblMFRecipeItemType]([intRecipeItemTypeId])
)
