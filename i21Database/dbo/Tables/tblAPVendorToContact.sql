CREATE TABLE [dbo].[tblAPVendorToContact] (
    [intVendorToContactId] INT IDENTITY (1, 1) NOT NULL,    
    [intEntityContactId]         INT NULL,
    [intEntityLocationId]        INT NULL,
    [intConcurrencyId]     INT DEFAULT ((0)) NOT NULL,
	[intEntityId]          INT NULL,
	CONSTRAINT [PK_tblAPVendorToContact] PRIMARY KEY CLUSTERED ([intVendorToContactId] ASC),
    --CONSTRAINT [FK_tblAPVendorToContact_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [dbo].[tblAPVendor] ([intVendorId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblAPVendorToContact_tblEntityContact] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityContactId]),
    CONSTRAINT [FK_tblAPVendorToContact_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblAPVendorToContact_tblAPVendor_entity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]) ON DELETE CASCADE,
);

GO
CREATE NONCLUSTERED INDEX [IX_intVendortToContactId]
    ON [dbo].[tblAPVendorToContact]([intVendorToContactId] ASC);




