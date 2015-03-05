CREATE TABLE [dbo].[tblHDAnnouncementDisplay]
(
	[intAnnouncementDisplayId] INT IDENTITY (1, 1) NOT NULL,
	[intAnnouncementId] INT NOT NULL,
    [intEntityId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDAnnouncementDisplay] PRIMARY KEY CLUSTERED ([intAnnouncementDisplayId] ASC),
    CONSTRAINT [FK_AnnouncementDisplay_Announcement] FOREIGN KEY ([intAnnouncementId]) REFERENCES [dbo].[tblHDAnnouncement] ([intAnnouncementId]),
    CONSTRAINT [FK_AnnouncementDisplay_UserEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
)
