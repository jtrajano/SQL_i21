CREATE TABLE [dbo].[tblSMConnectedUser]
(
	[intConnectedUserId] INT NOT NULL IDENTITY, 
    [strContextId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [dtmConnectDate] DATETIME NOT NULL, 
    [strMachine] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strBrowser] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strOS]      NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSMConnectedUser] PRIMARY KEY ([intConnectedUserId]), 
    CONSTRAINT [FK_tblSMConnectedUser_tblEMEntity] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity([intEntityId]), 
    CONSTRAINT [AK_tblSMConnectedUser_strContextId] UNIQUE ([strContextId]) 
)
