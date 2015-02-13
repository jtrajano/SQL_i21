CREATE TABLE [dbo].[tblSMTaxGroupCode]
(
	[intTaxGroupCodeId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxGroupCode_tblSMTaxGroup] FOREIGN KEY (intTaxGroupId) REFERENCES tblSMTaxGroup(intTaxGroupId), 
    CONSTRAINT [FK_tblSMTaxGroupCode_tblSMTaxCode] FOREIGN KEY (intTaxCodeId) REFERENCES tblSMTaxCode(intTaxCodeId)
)
