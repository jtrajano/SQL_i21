CREATE TABLE [dbo].[tblSMAnnouncement]
(
	[intAnnouncementId] INT IDENTITY (1, 1) NOT NULL,
	[intAnnouncementTypeId] INT NOT NULL,
	[dtmStartDate] datetime NOT NULL,
	[dtmEndDate] datetime NOT NULL,
    [strAnnouncement] NVARCHAR(max) COLLATE Latin1_General_CI_AS NOT NULL,
    [intSort] INT NULL,
	[strImageId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblSMAnnouncement] PRIMARY KEY CLUSTERED ([intAnnouncementId] ASC),
    CONSTRAINT [FK_tblSMAnnouncement_tblSMAnnouncementType] FOREIGN KEY ([intAnnouncementTypeId]) REFERENCES [dbo].[tblSMAnnouncementType] ([intAnnouncementTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Announcement Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'intAnnouncementId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Announcement Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'intAnnouncementTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'dtmStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Announcement',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'strAnnouncement'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Image Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'strImageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncement',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'