CREATE TABLE [dbo].[tblSMAnnouncementDisplay]
(
	[intAnnouncementDisplayId] INT IDENTITY (1, 1) NOT NULL,
	[intAnnouncementId] INT NOT NULL,
    [intEntityId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblSMAnnouncementDisplay] PRIMARY KEY CLUSTERED ([intAnnouncementDisplayId] ASC),
    CONSTRAINT [FK_tblSMAnnouncementDisplay_tblSMAnnouncement] FOREIGN KEY ([intAnnouncementId]) REFERENCES [dbo].[tblSMAnnouncement] ([intAnnouncementId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSMAnnouncementDisplay_tblSMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Announcement Display Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementDisplay',
    @level2type = N'COLUMN',
    @level2name = N'intAnnouncementDisplayId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Announcement Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementDisplay',
    @level2type = N'COLUMN',
    @level2name = N'intAnnouncementId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementDisplay',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMAnnouncementDisplay',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'