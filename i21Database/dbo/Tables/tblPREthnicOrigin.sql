CREATE TABLE [dbo].[tblPREthnicOrigin]
(
	[intEthnicOriginId] INT NOT NULL IDENTITY, 
    [strEthnicOrigin] NVARCHAR(50) NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREthnicOrigin] PRIMARY KEY ([intEthnicOriginId]), 
    CONSTRAINT [AK_tblPREthnicOrigin_strEthnicOrigin] UNIQUE ([strEthnicOrigin]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREthnicOrigin',
    @level2type = N'COLUMN',
    @level2name = N'intEthnicOriginId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ethnic Origin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREthnicOrigin',
    @level2type = N'COLUMN',
    @level2name = N'strEthnicOrigin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREthnicOrigin',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREthnicOrigin',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'