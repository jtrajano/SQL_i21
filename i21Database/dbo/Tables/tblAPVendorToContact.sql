CREATE TABLE [dbo].[tblAPVendorToContact] (
    [intVendorToContactId] INT IDENTITY (1, 1) NOT NULL,
    [intVendorId]          INT NULL,
    [intContactId]         INT NULL,
    [intEntityLocationId]        INT NULL,
    [intConcurrencyId]     INT DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblAPVendorToContact] PRIMARY KEY CLUSTERED ([intVendorToContactId] ASC),
    CONSTRAINT [FK_tblAPVendorToContact_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [dbo].[tblAPVendor] ([intVendorId]),
    CONSTRAINT [FK_tblAPVendorToContact_tblEntityContact] FOREIGN KEY ([intContactId]) REFERENCES [dbo].[tblEntityContact] ([intContactId]),
    CONSTRAINT [FK_tblAPVendorToContact_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
);

GO
CREATE NONCLUSTERED INDEX [IX_intVendortToContactId]
    ON [dbo].[tblAPVendorToContact]([intVendorToContactId] ASC);




