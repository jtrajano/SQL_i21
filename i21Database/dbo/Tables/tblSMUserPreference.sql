CREATE TABLE [dbo].[tblSMUserPreference]
(
	[intUserPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    --[intEntityId] INT NOT NULL, 
    [intOriginScreensLimit] INT NULL DEFAULT 3, 
    [ysnAllowUserSelfPost] BIT NULL DEFAULT 1, 
    [ysnShowReminderList] BIT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1--, 
    --CONSTRAINT [FK_tblSMUserPreference_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES tblSMUserSecurity(intUserSecurityID) ON DELETE CASCADE
)
