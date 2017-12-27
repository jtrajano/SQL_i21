CREATE TABLE [dbo].[tblTFTaxAuthorityBeginEndInventoryDetail]
(
	[intTaxAuthorityBeginEndInventoryDetailId] INT NOT NULL, 
    [intTaxAuthorityBeginEndInventoryId] INT NOT NULL, 
    [intProductCodeId] INT NOT NULL, 
    [dblBeginInventory] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblEndInventory] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTaxAuthorityBeginEndInventoryDetail] PRIMARY KEY ([intTaxAuthorityBeginEndInventoryDetailId]), 
    CONSTRAINT [FK_tblTFTaxAuthorityBeginEndInventoryDetail_tblTFTaxAuthorityBeginEndInventory] FOREIGN KEY ([intTaxAuthorityBeginEndInventoryId]) REFERENCES [tblTFTaxAuthorityBeginEndInventory]([intTaxAuthorityBeginEndInventoryId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTFTaxAuthorityBeginEndInventoryDetail_tblTFProductCode] FOREIGN KEY ([intProductCodeId]) REFERENCES [tblTFProductCode]([intProductCodeId]), 
    CONSTRAINT [AK_tblTFTaxAuthorityBeginEndInventoryDetail] UNIQUE ([intTaxAuthorityBeginEndInventoryId], [intProductCodeId]) 
)
