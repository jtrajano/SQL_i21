CREATE TABLE [dbo].[tblAPVendorPortalPermission]
(
	[intVendorPortalPermissionId] INT IDENTITY (1, 1) NOT NULL,
    [intVendorToContactId]      INT NOT NULL,
    [intVendorPortalMenuId]       INT NOT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblAPVendorPortalPermission_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblAPVendorPortalPermission] PRIMARY KEY CLUSTERED ([intVendorPortalPermissionId] ASC),
    CONSTRAINT [FK_tblAPVendorPortalPermission_tblAPVendorPortalMenu] FOREIGN KEY ([intVendorPortalMenuId]) REFERENCES [dbo].[tblAPVendorPortalMenu] ([intVendorPortalMenuId]),
    CONSTRAINT [FK_tblAPVendorPortalPermission_tblAPVendorToContact] FOREIGN KEY ([intVendorToContactId]) REFERENCES [dbo].[tblAPVendorToContact] ([intVendorToContactId]) ON DELETE CASCADE
)
