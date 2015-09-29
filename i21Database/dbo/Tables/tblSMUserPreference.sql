﻿CREATE TABLE [dbo].[tblSMUserPreference]
(
	[intUserPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    --[intEntityId] INT NOT NULL, 
    [intOriginScreensLimit] INT NULL DEFAULT 3, 
    [ysnAllowUserSelfPost] BIT NULL DEFAULT 1, 
    [ysnShowReminderList] BIT NULL DEFAULT 0, 
	[imgMenuBackground] VARBINARY (MAX) NULL, 
	[dblImageSizePercent] DECIMAL (18, 6) NULL DEFAULT 0,
	[ysnPreviewAttachment] BIT NULL DEFAULT 1, 
	[ysnEnableScreenLockout] BIT NULL DEFAULT 0, 
	[intScreenTimeout] INT NOT NULL DEFAULT 30, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1--, 
    --CONSTRAINT [FK_tblSMUserPreference_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES tblSMUserSecurity(intUserSecurityID) ON DELETE CASCADE
)
