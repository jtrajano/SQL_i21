﻿CREATE TABLE [dbo].[tblEMEntityToRole]
(
	[intEntityToRoleId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [intEntityRoleId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblEMEntityToRole_tblEntity] FOREIGN KEY (intEntityId) REFERENCES [tblEntity]([intEntityId]), 
    CONSTRAINT [FK_tblEMEntityToRole_tblSMUserRole] FOREIGN KEY (intEntityRoleId) REFERENCES [tblSMUserRole]([intUserRoleID])
)
