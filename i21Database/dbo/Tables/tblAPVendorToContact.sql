CREATE TABLE [dbo].[tblAPVendorToContact] (
    [intVendorToContactId] INT IDENTITY (1, 1) NOT NULL,
    [intEntityVendorId]          INT NULL,
    [intEntityContactId]         INT NULL,
    [intEntityLocationId]        INT NULL,
    [intConcurrencyId]     INT DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblAPVendorToContact] PRIMARY KEY CLUSTERED ([intVendorToContactId] ASC),
    CONSTRAINT [FK_tblAPVendorToContact_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblAPVendorToContact_tblEntityContact] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityContactId]),
    CONSTRAINT [FK_tblAPVendorToContact_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
);

GO
CREATE NONCLUSTERED INDEX [IX_intVendortToContactId]
    ON [dbo].[tblAPVendorToContact]([intVendorToContactId] ASC);




