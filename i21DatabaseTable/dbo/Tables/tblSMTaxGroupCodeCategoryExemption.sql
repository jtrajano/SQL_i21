CREATE TABLE [dbo].[tblSMTaxGroupCodeCategoryExemption]
(
	[intTaxGroupCodeCategoryExemptionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intTaxGroupCodeId] INT NOT NULL,  
	[intCategoryId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxGroupCodeCategoryExemption_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupCodeId]) REFERENCES [tblSMTaxGroupCode]([intTaxGroupCodeId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMTaxGroupCodeCategoryExemption_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId])
)
