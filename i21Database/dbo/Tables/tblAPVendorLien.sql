﻿CREATE TABLE [dbo].[tblAPVendorLien]
(
	[intEntityVendorLienId] INT NOT NULL IDENTITY(1,1),
	[intEntityVendorId] INT NOT NULL,
	[intEntityLienId] INT NOT NULL,
	[ysnActive] BIT NOT NULL DEFAULT(0),
	[dtmStartDate] DATETIME NULL,
	[dtmEndDate] DATETIME NULL,	
	[intConcurrencyId] INT DEFAULT ((0)) NOT NULL,	
	CONSTRAINT [PK_tblAPVendorLien] PRIMARY KEY CLUSTERED ([intEntityVendorLienId] ASC),
	CONSTRAINT [FK_tblAPVendorLien_tblAPVendor_intEntityVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_tblAPVendorLien_tblEMEntity_intEntityLienId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) ON DELETE CASCADE	
)
