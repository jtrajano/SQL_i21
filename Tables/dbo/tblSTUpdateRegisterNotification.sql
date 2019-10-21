CREATE TABLE [dbo].[tblSTUpdateRegisterNotification]
(
	[intUpdateRegisterNotificationId] INT NOT NULL IDENTITY,
	[intEntityId] INT NOT NULL UNIQUE,
	[ysnClick] BIT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblSTUpdateRegisterNotification_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE
)
