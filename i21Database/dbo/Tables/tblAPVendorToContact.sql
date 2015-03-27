CREATE TABLE [dbo].[tblAPVendorToContact] (
    [intVendorToContactId] INT IDENTITY (1, 1) NOT NULL,
    [intEntityVendorId]          INT NULL,
    [intEntityContactId]         INT NULL,
    [intEntityLocationId]        INT NULL,   
	[ysnDefaultContact] BIT NOT NULL DEFAULT ((0)), 
	[ysnPortalAccess]          BIT          NOT NULL,
	[strUserType]              NVARCHAR (5) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]     INT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblAPVendorToContact] PRIMARY KEY CLUSTERED ([intVendorToContactId] ASC),
    CONSTRAINT [FK_tblAPVendorToContact_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]) ON DELETE CASCADE,
    --CONSTRAINT [FK_tblAPVendorToContact_tblEntityContact] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityContactId]),
    CONSTRAINT [FK_tblAPVendorToContact_tblEntity] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [FK_tblAPVendorToContact_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
);

GO
CREATE NONCLUSTERED INDEX [IX_intVendortToContactId]
    ON [dbo].[tblAPVendorToContact]([intVendorToContactId] ASC);




