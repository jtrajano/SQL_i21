CREATE TABLE [dbo].[tblTMCOBOLPRICE] (
    [CustomerNumber] CHAR (10)       CONSTRAINT [DEF_tblTMCOBOLPRICE_CustomerNumber] DEFAULT ((0)) NOT NULL,
    [SiteNumber]     CHAR (4)        CONSTRAINT [DEF_tblTMCOBOLPRICE_SiteNumber] DEFAULT ((0)) NOT NULL,
    [Price]          DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLPRICE_TotalCapacity] DEFAULT ((0)) NOT NULL,
    [LastUpdateDate] CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLPRICE_LastUpdateDate] DEFAULT ('00000000') NOT NULL,
    [LastUpdateTime] CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLPRICE_LastUpdateTime] DEFAULT ('00000000') NOT NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_tblTMCOBOLPRICE_SiteNumber]
    ON [dbo].[tblTMCOBOLPRICE]([SiteNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTMCOBOLPRICE_CustomerNumber]
    ON [dbo].[tblTMCOBOLPRICE]([CustomerNumber] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLPRICE',
    @level2type = N'COLUMN',
    @level2name = N'CustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLPRICE',
    @level2type = N'COLUMN',
    @level2name = N'SiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLPRICE',
    @level2type = N'COLUMN',
    @level2name = N'Price'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Update Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLPRICE',
    @level2type = N'COLUMN',
    @level2name = N'LastUpdateDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Update Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLPRICE',
    @level2type = N'COLUMN',
    @level2name = N'LastUpdateTime'