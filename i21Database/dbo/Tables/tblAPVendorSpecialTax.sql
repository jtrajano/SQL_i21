CREATE TABLE [dbo].[tblAPVendorSpecialTax]
(
	[intAPVendorSpecialTaxId]				INT NOT NULL identity,

	[intEntityVendorId]						INT NOT NULL,
	
	[intTaxEntityVendorId]					INT NULL,
	
	[intItemId]								INT NULL,
	
	[intCategoryId]							INT NULL,
	
	[intTaxGroupMasterId]					INT	NULL,
	
	[intEntityVendorLocationId]				INT	NULL,
	
	[intTaxGroupId]	INT	NULL,

	[intConcurrencyId]	INT	DEFAULT(0) NOT NULL,
	
	CONSTRAINT [PK_dbo_tblAPVendorSpecialTax]					PRIMARY KEY CLUSTERED ([intAPVendorSpecialTaxId] ASC),
	
	CONSTRAINT FK_tblAPVendorSpecialTax_tblAPVendor_Parent		FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	
	CONSTRAINT FK_tblAPVendorSpecialTax_tblAPVendor_Tax			FOREIGN KEY ([intTaxEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	
	CONSTRAINT FK_tblAPVendorSpecialTax_tbltblICItem			FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	
	CONSTRAINT FK_tblAPVendorSpecialTax_tblICCategory			FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	
	--CONSTRAINT FK_tblAPVendorSpecialTax_tblSMTaxGroupMaster		FOREIGN KEY ([intTaxGroupMasterId]) REFERENCES [tblSMTaxGroupMaster]([intTaxGroupMasterId]),
	
	CONSTRAINT FK_tblAPVendorSpecialTax_tblEMEntityLocation		FOREIGN KEY ([intEntityVendorLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),

	CONSTRAINT FK_tblAPVendorSpecialTax_tblSMTaxGroup FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId])

)
