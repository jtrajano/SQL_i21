CREATE TABLE [dbo].[tblTFTaxAuthorityBeginEndInventory]
(
	[intTaxAuthorityBeginEndInventoryId] INT NOT NULL IDENTITY, 
    [intTaxAuthorityId] INT NOT NULL, 
	[intCompanyLocationId] INT NOT NULL,
	[intProductCodeId] INT NOT NULL, 
    [dblBeginInventory] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblEndInventory] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTaxAuthorityBeginEndInventory] PRIMARY KEY ([intTaxAuthorityBeginEndInventoryId]), 
    CONSTRAINT [FK_tblTFTaxAuthorityBeginEndInventory_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [tblTFTaxAuthority]([intTaxAuthorityId]), 
    CONSTRAINT [AK_tblTFTaxAuthorityBeginEndInventory] UNIQUE ([intCompanyLocationId], [intProductCodeId], [intTaxAuthorityId]), 
    CONSTRAINT [FK_tblTFTaxAuthorityBeginEndInventory_tblTFProductCode] FOREIGN KEY ([intProductCodeId]) REFERENCES [tblTFProductCode]([intProductCodeId]), 
    CONSTRAINT [FK_tblTFTaxAuthorityBeginEndInventory_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)
