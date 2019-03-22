CREATE TABLE [dbo].[tblSMUserPreference]
(
	[intUserPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityUserSecurityId] INT NOT NULL, 
    --[intEntityId] INT NOT NULL, 
    [intOriginScreensLimit] INT NULL DEFAULT 3, 
    [ysnAllowUserSelfPost] BIT NULL DEFAULT 1, 
    [ysnShowReminderList] BIT NULL DEFAULT 0, 
	--[strTheme] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT (''), 
	[dtmNotificationEmailTime] DATETIME NULL, 
	--[strMenuBackground] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT (''), 
	--[imgMenuBackground] VARBINARY (MAX) NULL, 
	--[dblImageSizePercent] DECIMAL (18, 6) NULL DEFAULT 0,
	[ysnPreviewAttachment] BIT NULL DEFAULT 1, 
	[ysnEnableScreenLockout] BIT NULL DEFAULT 0,
	[ysnKeepSearchScreensOpen] BIT NOT NULL DEFAULT 0, 
	[intScreenTimeout] INT NOT NULL DEFAULT 30, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1--, 
    --CONSTRAINT [FK_tblSMUserPreference_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES tblSMUserSecurity(intUserSecurityID) ON DELETE CASCADE
)
