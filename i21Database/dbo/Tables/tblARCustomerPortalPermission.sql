CREATE TABLE [dbo].[tblARCustomerPortalPermission] (
    [intCustomerPortalPermissionId] INT IDENTITY (1, 1) NOT NULL,
    [intARCustomerToContactId]      INT NOT NULL,
    [intCustomerPortalMenuId]       INT NOT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblARCustomerPortalPermission_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomerPortalPermission] PRIMARY KEY CLUSTERED ([intCustomerPortalPermissionId] ASC),
    CONSTRAINT [FK_tblARCustomerPortalPermission_tblARCustomerPortalMenu] FOREIGN KEY ([intCustomerPortalMenuId]) REFERENCES [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId]),
    CONSTRAINT [FK_tblARCustomerPortalPermission_tblARCustomerToContact] FOREIGN KEY ([intARCustomerToContactId]) REFERENCES [dbo].[tblARCustomerToContact] ([intARCustomerToContactId] ) ON DELETE CASCADE
);





