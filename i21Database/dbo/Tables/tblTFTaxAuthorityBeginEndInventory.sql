CREATE TABLE [dbo].[tblTFTaxAuthorityBeginEndInventory]
(
	[intTaxAuthorityBeginEndInventoryId] INT NOT NULL, 
    [intTaxAuthorityId] INT NOT NULL, 
    [dtmBeginDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTaxAuthorityBeginEndInventory] PRIMARY KEY ([intTaxAuthorityBeginEndInventoryId]), 
    CONSTRAINT [FK_tblTFTaxAuthorityBeginEndInventory_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [tblTFTaxAuthority]([intTaxAuthorityId]) 
)
