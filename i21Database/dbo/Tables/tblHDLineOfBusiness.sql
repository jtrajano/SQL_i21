CREATE TABLE [dbo].[tblSMLineOfBusiness]
(
	[intLineOfBusinessId] [int] IDENTITY(1,1) NOT NULL,
	[strLineOfBusiness] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strSICCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnVisibleOnWeb] [bit] NOT NULL DEFAULT 1,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblSMLineOfBusiness] PRIMARY KEY CLUSTERED ([intLineOfBusinessId] ASC),
 CONSTRAINT [FK_tblSMLineOfBusiness_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
 CONSTRAINT [UNQ_tblSMLineOfBusiness_SalesPersonEntity] UNIQUE ([strLineOfBusiness],[intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'intLineOfBusinessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line Of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'strLineOfBusiness'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Person Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = 'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Industry Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'strSICCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Visible on Web',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'ysnVisibleOnWeb'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Industry Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'