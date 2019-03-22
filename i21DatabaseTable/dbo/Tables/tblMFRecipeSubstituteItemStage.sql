CREATE TABLE [dbo].[tblMFRecipeSubstituteItemStage]
(
	[intRecipeSubstituteItemStageId] INT NOT NULL IDENTITY(1,1),
	[strRecipeName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeHeaderItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVersionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strSubstituteItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSubstituteRatio] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 1,
    [strMaxSubstituteRatio] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 100,
	[dtmCreated] [datetime] NULL DEFAULT GetDate(),
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strSessionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intRowNo] INT Default 0,
	CONSTRAINT [PK_tblMFRecipeSubstituteItemStage_intRecipeSubstituteItemStageId] PRIMARY KEY ([intRecipeSubstituteItemStageId]),
)
