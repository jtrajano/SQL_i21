CREATE TABLE [dbo].[tblEntityCredential]
(
	[intEntityCredentialId] INT IDENTITY NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [strUserName] NVARCHAR(100) NOT NULL, 
    [strPassword] NVARCHAR(100) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblEntityCredential_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]), 
    CONSTRAINT [AK_tblEntityCredential_strUserName] UNIQUE ([strUserName]), 
    CONSTRAINT [PK_tblEntityCredential] PRIMARY KEY ([intEntityCredentialId]) 
)
