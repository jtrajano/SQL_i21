CREATE TABLE [dbo].[tblAPVendorLien]
(
	[intEntityVendorLienId] INT NOT NULL IDENTITY(1,1),
	[intEntityVendorId] INT NOT NULL,
	[intEntityLienId] INT NOT NULL,
	[ysnActive] BIT NOT NULL DEFAULT(0),
	[dtmStartDate] DATETIME NULL,
	[dtmEndDate] DATETIME NULL,	
	[intCommodityId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((0)) NOT NULL,	
	CONSTRAINT [PK_tblAPVendorLien] PRIMARY KEY CLUSTERED ([intEntityVendorLienId] ASC),
	CONSTRAINT [FK_tblAPVendorLien_tblAPVendor_intEntityVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_tblAPVendorLien_tblEMEntity_intEntityLienId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),	
	CONSTRAINT [FK_tblAPVendorLien_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [tblICCommodity] ([intCommodityId]),
)
