CREATE TABLE [dbo].[tblMFItemDemandStage]
(
	[intItemDemandStageId] INT NOT NULL IDENTITY(1,1),
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[dblQuantity] NUMERIC(38,20),
	[strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strCompanyCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[dtmCreated] [datetime] NULL DEFAULT GetDate(),
	CONSTRAINT [PK_tblMFItemDemandStage_intItemDemandStageId] PRIMARY KEY ([intItemDemandStageId])
)
