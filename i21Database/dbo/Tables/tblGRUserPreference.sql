CREATE TABLE [dbo].[tblGRUserPreference]
(
	[intUserPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [strQuoteProvider] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT (''), 
    [strProviderUserId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT (''), 
    [strProviderPassword] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT (''), 
    [strProviderAccessType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT (''), 
    [intConcurrencyId] INT NOT NULL DEFAULT 1--, 
    --CONSTRAINT [FK_tblGRUserPreference_tblSMUserSecurity] FOREIGN KEY (intUserSecurityId) REFERENCES tblSMUserSecurity(intUserSecurityID) ON DELETE CASCADE
)
