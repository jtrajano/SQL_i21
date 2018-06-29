CREATE TABLE [dbo].[tblTFTaxAuthorityCountyLocation]
(
	[intTaxAuthorityCountyLocationId] INT IDENTITY NOT NULL,
	[intTaxAuthorityId] INT NOT NULL, 
	[intEntityId] INT NOT NULL,
	[intEntityLocationId] INT NOT NULL,
    [intCountyLocationId] INT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTaxAuthorityCountyLocation] PRIMARY KEY ([intTaxAuthorityCountyLocationId]), 
    CONSTRAINT [AK_tblTFTaxAuthorityCountyLocation] UNIQUE ([intTaxAuthorityId], [intEntityId], [intEntityLocationId], [intCountyLocationId]), 
	CONSTRAINT [FK_tblTFTaxAuthorityCountyLocation_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [tblTFTaxAuthority]([intTaxAuthorityId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblTFTaxAuthorityCountyLocation_tblARCustomer] FOREIGN KEY ([intEntityId]) REFERENCES [tblARCustomer]([intEntityId]), 
	CONSTRAINT [FK_tblTFTaxAuthorityCountyLocation_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]), 
    CONSTRAINT [FK_tblTFTaxAuthorityCountyLocation_tblTFCountyLocation] FOREIGN KEY ([intCountyLocationId]) REFERENCES [tblTFCountyLocation]([intCountyLocationId])
)
