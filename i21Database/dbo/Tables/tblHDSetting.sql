CREATE TABLE [dbo].[tblHDSetting]
(
	[intSettingId] [int] IDENTITY(1,1) NOT NULL,
	[strHelpDeskName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strHelpDeskURL] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strJIRAURL] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strTimeZone] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intTicketStatusId] [int] NULL,
	[intTicketTypeId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblHDSettings] PRIMARY KEY CLUSTERED 
(
	[intSettingId] ASC
)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'intSettingId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Help Desk Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'strHelpDeskName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Help Desk URL',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'strHelpDeskURL'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JIRA URL',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'strJIRAURL'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Zone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'strTimeZone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'intTicketStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSetting',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'