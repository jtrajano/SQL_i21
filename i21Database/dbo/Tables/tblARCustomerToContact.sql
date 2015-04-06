CREATE TABLE [dbo].[tblARCustomerToContact] (
    [intARCustomerToContactId] INT          IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]            INT          NULL,
    [intEntityContactId]             INT          NULL,
    [intEntityLocationId]      INT          NULL,
    [strUserType]              NVARCHAR (5) COLLATE Latin1_General_CI_AS NULL,
    [ysnPortalAccess]          BIT          NOT NULL,    
	[ysnDefaultContact] BIT NOT NULL DEFAULT ((0)), 
	[intConcurrencyId]         INT          CONSTRAINT [DF__tblEntity__intCo__578A682E] DEFAULT ((0)) NOT NULL,	
    CONSTRAINT [PK_tblEntity2Contact] PRIMARY KEY CLUSTERED ([intARCustomerToContactId] ASC),
    CONSTRAINT [FK_tblARCustomerToContact_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]) ON DELETE CASCADE,
    --CONSTRAINT [FK_tblARCustomerToContact_tblEntityContact] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityContactId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARCustomerToContact_tblEntity] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARCustomerToContact_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
);

