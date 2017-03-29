CREATE TABLE [dbo].[tblARSpecialTax]
(
	[intARSpecialTaxId]		INT NOT NULL identity,
	[intEntityCustomerId]	INT NOT NULL,
	[intEntityVendorId]		INT NULL,
	[intItemId]				INT NULL,
	[intCategoryId]			INT NULL,
	[intTaxGroupMasterId]	INT	NULL,
	[intTaxGroupId]	INT	NULL,
	[intEntityCustomerLocationId]	INT	NULL,
	[intConcurrencyId]	INT	DEFAULT(0) NOT NULL,
	CONSTRAINT [PK_dbo_tblARSpecialTax] PRIMARY KEY CLUSTERED ([intARSpecialTaxId] ASC),
	CONSTRAINT FK_tblARSpecialTax_tblARCustomer FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityId]),
	CONSTRAINT FK_tblARSpecialTax_tblAPVendor FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	CONSTRAINT FK_tblARSpecialTax_tbltblICItem FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT FK_tblARSpecialTax_tblICCategory FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	--CONSTRAINT FK_tblARSpecialTax_tblSMTaxGroupMaster FOREIGN KEY ([intTaxGroupMasterId]) REFERENCES [tblSMTaxGroupMaster]([intTaxGroupMasterId]),
	CONSTRAINT FK_tblARSpecialTax_tblSMTaxGroup FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId]),
	CONSTRAINT FK_tblARSpecialTax_tblEMEntityLocation FOREIGN KEY ([intEntityCustomerLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId])

)


--CREATE TABLE tblARSpecialTax
--(
--	intARSpecialTaxId	int not null identity,
--	intEntityCustomerId int not null,
--	strColumn1	nvarchar(100) COLLATE Latin1_General_CI_AS,
--	strColumn2	nvarchar(100) COLLATE Latin1_General_CI_AS,
--	strColumn3	nvarchar(100) COLLATE Latin1_General_CI_AS,
--	strColumn4	nvarchar(100) COLLATE Latin1_General_CI_AS,
--	CONSTRAINT [PK_dbo_tblARSpecialTax] PRIMARY KEY CLUSTERED ([intARSpecialTaxId] ASC),
--	CONSTRAINT FK_tblARSpecialTax_tblARCustomer FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]),
--)