﻿CREATE TABLE [dbo].[tblMFRecipeItemStage]
(
	[intRecipeItemStageId] INT NOT NULL IDENTITY(1,1),
	[strRecipeName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeHeaderItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVersionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [strQuantity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
    [strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemGroupName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strUpperTolerance] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
    [strLowerTolerance] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
    [strShrinkage] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
    [strScaled] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 1, 
    [strConsumptionMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strStorageLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strValidFrom] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strValidTo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strYearValidationRequired] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0, 
    [strMinorIngredient] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
	[strOutputItemMandatory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
	[strScrap] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0, 
    [strConsumptionRequired] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
	[strCostAllocationPercentage] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarginBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMargin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCostAppliedAtInvoice] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 0,
	[strCommentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDocumentNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPartialFillConsumption] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 1,
	[dtmCreated] [datetime] NULL DEFAULT GetDate(),
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strSessionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intRowNo] INT Default 0,
	strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intRecipeItemId int,
	ysnMailSent BIT NULL,
	intStatusId int,
	ysnImport Bit Constraint DF_tblMFRecipeItemStage_ysnImport Default 1,
	intTrxSequenceNo BIGINT,
	intParentTrxSequenceNo BIGINT,
	ysnInitialAckSent BIT, 
	ysnVirtualRecipe BIT Constraint DF_tblMFRecipeItemStage_ysnVirtualRecipe DEFAULT 0,
	CONSTRAINT [PK_tblMFRecipeItemStage_intRecipeItemStageId] PRIMARY KEY ([intRecipeItemStageId]),
)
