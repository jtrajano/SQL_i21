CREATE TABLE [dbo].[tblSMUserSecurityPasswordHistory]
(
	[intUserSecurityPasswordHistoryId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityUserSecurityId] INT NOT NULL, 
    [strPassword] NVARCHAR(MAX) NOT NULL, 
    [dtmDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1 

)
