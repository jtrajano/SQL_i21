CREATE TABLE [dbo].[tblVRProgramItem](
	[intProgramItemId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] [int] NULL,
	[intCategoryId] [int] NULL,
	[strRebateBy] [nvarchar](15) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_tblVRProgramItem_strRebateBy]  DEFAULT (N'Percentage'),
	[dblRebateRate] [numeric](18, 6) NULL,
	[dtmBeginDate] [datetime] NOT NULL,
	[dtmEndDate] [datetime] NULL,
	[intProgramId] [int] NOT NULL,
	[intUnitMeasureId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRProgramItem_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRProgramItem] PRIMARY KEY CLUSTERED ([intProgramItemId] ASC),
	CONSTRAINT [FK_tblVRProgramItem_tblICCategory] FOREIGN KEY([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId]),
	CONSTRAINT [FK_tblVRProgramItem_tblICItem] FOREIGN KEY([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblVRProgramItem_tblVRProgram] FOREIGN KEY([intProgramId])REFERENCES [dbo].[tblVRProgram] ([intProgramId]) ON DELETE CASCADE, 
)
GO
