CREATE TABLE [dbo].[tblARCustomerPortalPermission] (
    [intCustomerPortalPermissionId] INT IDENTITY (1, 1) NOT NULL,
    [intContactId]                  INT NOT NULL,
    [intCustomerPortalMenuId]       INT NOT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblARCustomerPortalPermission_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomerPortalPermission] PRIMARY KEY CLUSTERED ([intCustomerPortalPermissionId] ASC),
    CONSTRAINT [FK_tblARCustomerPortalPermission_tblEntityContact] FOREIGN KEY ([intContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityId])
);

