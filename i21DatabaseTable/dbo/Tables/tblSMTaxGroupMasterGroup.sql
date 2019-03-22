CREATE TABLE [dbo].[tblSMTaxGroupMasterGroup]
(
	[intTaxGroupMasterGroupId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intTaxGroupMasterId] INT NOT NULL, 
    [intTaxGroupId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxGroupMasterGroup_tblSMTaxGroupMaster] FOREIGN KEY (intTaxGroupMasterId) REFERENCES tblSMTaxGroupMaster(intTaxGroupMasterId) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMTaxGroupMasterGroup_tblSMTaxGroup] FOREIGN KEY (intTaxGroupId) REFERENCES tblSMTaxGroup(intTaxGroupId)
)
