CREATE TABLE [dbo].[tblSMLoginDeviceToken]
(
	[intLoginDeviceTokenId] INT PRIMARY KEY IDENTITY (1, 1) NOT NULL,
	[intEntityId] INT NULL,
	[strDeviceToken] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strPlatform] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastLogin] DATETIME NULL,
	[intConcurrencyId] INT NOT NULL,
	CONSTRAINT [FK_tblSMLoginDeviceToken_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
)
