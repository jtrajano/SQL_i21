CREATE TABLE [dbo].[tblICCategoryTax]
(
	[intCategoryTaxId] INT NOT NULL IDENTITY, 
    [intCategoryId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
    [ysnActive] BIT NULL DEFAULT ((1)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    [dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL,
    CONSTRAINT [PK_tblICCategoryTax] PRIMARY KEY ([intCategoryTaxId]), 
    CONSTRAINT [AK_tblICCategoryTax] UNIQUE ([intCategoryId], [intTaxClassId]), 
    CONSTRAINT [FK_tblICCategoryTax_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICCategoryTax_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES [tblSMTaxClass]([intTaxClassId])
)
