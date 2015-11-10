CREATE TABLE [dbo].[tblICCategoryTax]
(
	[intCategoryTaxId] INT NOT NULL IDENTITY, 
    [intCategoryId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
	[ysnActive] BIT NULL DEFAULT ((1)),
	[intSort] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCategoryTax] PRIMARY KEY ([intCategoryTaxId]), 
    CONSTRAINT [FK_tblICCategoryTax_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE, 
    CONSTRAINT [AK_tblICCategoryTax] UNIQUE ([intCategoryId], [intTaxClassId]), 
    CONSTRAINT [FK_tblICCategoryTax_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES [tblSMTaxClass]([intTaxClassId])
)
