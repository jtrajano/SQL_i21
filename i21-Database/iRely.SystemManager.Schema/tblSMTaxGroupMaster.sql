CREATE TABLE [dbo].[tblSMTaxGroupMaster]
(
	[intTaxGroupMasterId] INT NOT NULL PRIMARY KEY IDENTITY,
	[strTaxGroupMaster] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnSeparateOnInvoice] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [AK_tblSMTaxGroupMaster_strTaxGroupMaster] UNIQUE ([strTaxGroupMaster])
)
