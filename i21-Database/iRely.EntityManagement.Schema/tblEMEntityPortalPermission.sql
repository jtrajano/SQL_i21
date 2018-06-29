CREATE TABLE [dbo].[tblEMEntityPortalPermission] (
    [intEntityPortalPermissionId]	INT IDENTITY (1, 1) NOT NULL,
    [intEntityToContactId]			INT NOT NULL,
    [intEntityPortalMenuId]			INT NOT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblEMEntityPortalPermission_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityPortalPermission] PRIMARY KEY CLUSTERED ([intEntityPortalPermissionId] ASC),
    CONSTRAINT [FK_tblEMEntityPortalPermission_tblEMEntityPortalMenu] FOREIGN KEY ([intEntityPortalMenuId]) REFERENCES [dbo].[tblEMEntityPortalMenu]([intEntityPortalMenuId]),
    CONSTRAINT [FK_tblEMEntityPortalPermission_tblEMEntityToContact] FOREIGN KEY ([intEntityToContactId]) REFERENCES [dbo].[tblEMEntityToContact]([intEntityToContactId]) ON DELETE CASCADE
);

