CREATE TABLE [dbo].[tblTRSupplyPoint]
(
	[intSupplyPointId] INT NOT NULL IDENTITY,
	[intEntityVendorId] INT NOT NULL,		
	[intEntityLocationId] INT NOT NULL,	
	[strTerminalNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strGrossOrNet] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFuelDealerId1] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFuelDealerId2] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDefaultOrigin] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTaxGroupId] INT NOT NULL,
	[ysnMultipleDueDates]  BIT  DEFAULT ((0)) NOT NULL,
    [ysnMultipleBolInvoiced]  BIT  DEFAULT ((0)) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRSupplyPoint] PRIMARY KEY ([intSupplyPointId]),
	CONSTRAINT [AK_tblTRSupplyPoint] UNIQUE ([strTerminalNumber]),
	CONSTRAINT [AK_tblTRSupplyPoint_intEntityVendorId_intEntityLocationId] UNIQUE ([intEntityVendorId],[intEntityLocationId]),
	CONSTRAINT [FK_tblTRSupplyPoint_tblAPVendor_intEntityVendorId] FOREIGN KEY (intEntityVendorId) REFERENCES [dbo].[tblAPVendor] (intEntityVendorId),
	CONSTRAINT [FK_tblTRSupplyPoint_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblTRSupplyPoint_tblEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
)
