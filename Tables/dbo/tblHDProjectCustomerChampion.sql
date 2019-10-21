CREATE TABLE [dbo].[tblHDProjectCustomerChampion]
(
	[intProjectCustomerChampionId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[strName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnActive] [bit] NOT NULL DEFAULT 1,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDProjectCustomerChampion] PRIMARY KEY CLUSTERED ([intProjectCustomerChampionId] ASC),
	CONSTRAINT [UNQ_ChampionName] UNIQUE ([intProjectId],[strName]),
    CONSTRAINT [FK_Project_CustomerChampion] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) on delete cascade
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Customer Champion Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectCustomerChampion',
    @level2type = N'COLUMN',
    @level2name = N'intProjectCustomerChampionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectCustomerChampion',
    @level2type = N'COLUMN',
    @level2name = N'intProjectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectCustomerChampion',
    @level2type = N'COLUMN',
    @level2name = N'strName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectCustomerChampion',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectCustomerChampion',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectCustomerChampion',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'