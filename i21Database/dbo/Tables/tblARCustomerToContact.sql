CREATE TABLE [dbo].[tblARCustomerToContact] (
    [intARCustomerToContactId] INT          IDENTITY (1, 1) NOT NULL,
    [intCustomerId]            INT          NULL,
    [intContactId]             INT          NULL,
    [intEntityLocationId]      INT          NULL,
    [strUserType]              NVARCHAR (5) COLLATE Latin1_General_CI_AS NULL,
    [ysnPortalAccess]          BIT          NOT NULL,
    [intConcurrencyId]         INT          CONSTRAINT [DF__tblEntity__intCo__578A682E] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntity2Contact] PRIMARY KEY CLUSTERED ([intARCustomerToContactId] ASC),
    CONSTRAINT [FK_tblARCustomerToContact_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intCustomerId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARCustomerToContact_tblEntityContact] FOREIGN KEY ([intContactId]) REFERENCES [dbo].[tblEntityContact] ([intContactId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblEntityToContact_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
);

