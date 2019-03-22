CREATE TABLE [dbo].[tblMFUserRoleEventMap]
(
	[intUserRoleEventMapId] INT NOT NULL IDENTITY, 
	[strEventName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intUserRoleID] INT NOT NULL, 
	
	CONSTRAINT [PK_tblMFUserRoleEventMap] PRIMARY KEY ([intUserRoleEventMapId]), 
	CONSTRAINT [AK_tblMFUserRoleEventMap_strEventName_intUserRoleID] UNIQUE ([strEventName],[intUserRoleID]), 
	CONSTRAINT [FK_tblMFUserRoleEventMap_tblSMUserRole] FOREIGN KEY ([intUserRoleID]) REFERENCES [tblSMUserRole]([intUserRoleID])
)