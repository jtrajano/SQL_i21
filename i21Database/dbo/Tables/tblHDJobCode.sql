CREATE TABLE [dbo].[tblHDJobCode]
(
	[intJobCodeId] [int] IDENTITY(1,1) NOT NULL,
	[strJobCode] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[ysnBillable] [bit] NOT NULL,
	[dblRate] [numeric](18, 6) NOT NULL,
	[ysnSupported] [bit] NOT NULL DEFAULT 1,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDJobCode] PRIMARY KEY CLUSTERED ([intJobCodeId] ASC),
 CONSTRAINT [UNQ_tblHDJobCode] UNIQUE ([strJobCode])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDJobCode',
    @level2type = N'COLUMN',
    @level2name = N'intJobCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Job Code (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDJobCode',
    @level2type = N'COLUMN',
    @level2name = N'strJobCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDJobCode',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Billable?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDJobCode',
    @level2type = N'COLUMN',
    @level2name = N'ysnBillable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDJobCode',
    @level2type = N'COLUMN',
    @level2name = N'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDJobCode',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDJobCode',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'