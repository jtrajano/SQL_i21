CREATE TABLE [dbo].[tblSMOfflineMenu]
(
	[intOfflineMenu] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [strModuleName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strSubMenus] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0
)
