CREATE TABLE [dbo].[tblEMEntityPortalPermission] (
    [intEntityPortalPermissionId]	INT IDENTITY (1, 1) NOT NULL,
    [intEntityToContactId]			INT NOT NULL,
    [intEntityPortalMenuId]			INT NOT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblEntityPortalPermission_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityPortalPermission] PRIMARY KEY CLUSTERED ([intEntityPortalPermissionId] ASC),
    CONSTRAINT [FK_tblEntityPortalPermission_tblEntityPortalMenu] FOREIGN KEY ([intEntityPortalMenuId]) REFERENCES [dbo].[tblEMEntityPortalMenu]([intEntityPortalMenuId]),
    CONSTRAINT [FK_tblEntityPortalPermission_tblEntityToContact] FOREIGN KEY ([intEntityToContactId]) REFERENCES [dbo].[tblEMEntityToContact]([intEntityToContactId]) ON DELETE CASCADE
);

