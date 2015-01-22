CREATE TABLE [dbo].[tblSMTaxGroupComponent]
(
	[intTaxGroupComponentId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxComponentId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxGroupComponent_tblSMTaxGroup] FOREIGN KEY (intTaxGroupId) REFERENCES tblSMTaxGroup(intTaxGroupId),
    CONSTRAINT [FK_tblSMTaxGroupComponent_tblSMTaxComponent] FOREIGN KEY (intTaxComponentId) REFERENCES tblSMTaxComponent(intTaxComponentId)
)
