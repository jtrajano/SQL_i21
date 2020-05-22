CREATE TABLE [dbo].[tblApiUserAccount]
(
	[guiApiUserAccountId] UNIQUEIDENTIFIER NOT NULL, 
    [strUsername] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strPasswordHash] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT NULL DEFAULT(1), 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblApiUserAccount_guiApiUserAccountId] PRIMARY KEY ([guiApiUserAccountId])
)
GO