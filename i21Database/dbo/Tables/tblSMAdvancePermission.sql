CREATE TABLE [dbo].[tblSMAdvancePermission]
(
	[intAdvancePermissionId]			INT NOT NULL PRIMARY KEY IDENTITY, 
	[intModuleId]						INT NOT NULL, 
    [strDescription]					NVARCHAR(1000) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId]					INT NOT NULL DEFAULT (1), 

    CONSTRAINT [FK_tblSMAdvancePermission_tblSMModule] FOREIGN KEY ([intModuleId]) REFERENCES [tblSMModule]([intModuleId])
)
