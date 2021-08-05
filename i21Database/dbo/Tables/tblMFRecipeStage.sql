﻿CREATE TABLE [dbo].[tblMFRecipeStage]
(
	[intRecipeStageId] INT NOT NULL IDENTITY(1,1),
	[strRecipeName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strQuantity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strVersionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strManufacturingProcess] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCustomer] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFarm] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strField] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCostType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarginBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMargin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDiscount] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOneLinePrint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated] [datetime] NULL DEFAULT GetDate(),
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strSessionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intRowNo] INT Default 0,
	strValidFrom NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strValidTo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTransactionType nvarchar(50) COLLATE Latin1_General_CI_AS,
	strCreatedBy nvarchar(50) COLLATE Latin1_General_CI_AS,
	intRecipeId int,
	strRecipeRowState nvarchar(50) COLLATE Latin1_General_CI_AS,
	ysnImport Bit Constraint DF_tblMFRecipeStage_ysnImport Default 1,
	ysnMailSent BIT NULL,
	intStatusId int,
	intTrxSequenceNo BIGINT,
	strERPRecipeNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	intActive int,
	strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblMFRecipeStage_intRecipeStageId] PRIMARY KEY ([intRecipeStageId])
)
