CREATE TABLE [dbo].[tblVRProgramItem](
	[intProgramItemId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] [int] NULL,
	[intCategoryId] [int] NULL,
	[strRebateBy] [nvarchar](15) NOT NULL CONSTRAINT [DF_tblVRProgramItem_strRebateBy]  DEFAULT (N'Amount'),
	[dblRebateRate] [numeric](18, 6) NULL,
	[dtmBeginDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[intProgramId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRProgramItem_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRProgramItem] PRIMARY KEY CLUSTERED ([intProgramItemId] ASC),
	CONSTRAINT [FK_tblVRProgramItem_tblICCategory] FOREIGN KEY([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId]),
	CONSTRAINT [FK_tblVRProgramItem_tblICItem] FOREIGN KEY([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblVRProgramItem_tblVRProgramItem] FOREIGN KEY([intProgramItemId])REFERENCES [dbo].[tblVRProgramItem] ([intProgramItemId]),
)
GO
