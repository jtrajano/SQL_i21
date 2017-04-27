CREATE TABLE [dbo].[tblSMUserLogin]
(
	[intUserLoginId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [strResult] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMUserLogin_tblSMUserSecurity] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE
)
