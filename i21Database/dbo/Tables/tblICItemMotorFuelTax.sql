CREATE TABLE [dbo].[tblICItemMotorFuelTax]
(
	[intItemMotorFuelTaxId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intTaxAuthorityId] INT NOT NULL, 
    [intProductCodeId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemMotorFuelTax] PRIMARY KEY ([intItemMotorFuelTaxId]), 
    CONSTRAINT [FK_tblICItemMotorFuelTax_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICItemMotorFuelTax_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [tblTFTaxAuthority]([intTaxAuthorityId]), 
    CONSTRAINT [FK_tblICItemMotorFuelTax_tblTFProductCode] FOREIGN KEY ([intProductCodeId]) REFERENCES [tblTFProductCode]([intProductCodeId])
)
