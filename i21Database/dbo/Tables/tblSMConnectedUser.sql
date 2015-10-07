CREATE TABLE [dbo].[tblSMConnectedUser]
(
	[intConnectedUserId] INT NOT NULL IDENTITY, 
    [strContextId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [dtmConnectDate] DATETIME NOT NULL, 
    [strMachine] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strBrowser] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSMConnectedUser] PRIMARY KEY ([intConnectedUserId]), 
    CONSTRAINT [FK_tblSMConnectedUser_tblEntity] FOREIGN KEY (intEntityId) REFERENCES [tblEntity]([intEntityId]) 
)
