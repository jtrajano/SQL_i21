CREATE TABLE [dbo].[tblHDAnnouncementType]
(
	[intAnnouncementTypeId] INT IDENTITY (1, 1) NOT NULL,
    [strAnnouncementType] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDisplayTo] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strFontColor] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
	[strBackColor] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDAnnouncementType] PRIMARY KEY CLUSTERED ([intAnnouncementTypeId] ASC),
	CONSTRAINT [UNQ_AnnouncementType] UNIQUE ([strAnnouncementType])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Announcement Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDAnnouncementType',
    @level2type = N'COLUMN',
    @level2name = N'intAnnouncementTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Announcement Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDAnnouncementType',
    @level2type = N'COLUMN',
    @level2name = N'strAnnouncementType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDAnnouncementType',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Display To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDAnnouncementType',
    @level2type = N'COLUMN',
    @level2name = N'strDisplayTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Font Color',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDAnnouncementType',
    @level2type = N'COLUMN',
    @level2name = N'strFontColor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Back COlor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDAnnouncementType',
    @level2type = N'COLUMN',
    @level2name = N'strBackColor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDAnnouncementType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'