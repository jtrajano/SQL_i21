CREATE TABLE [dbo].[tblTROverrideTaxGroupDetail]
(
	[intOverrideTaxGroupDetailId] INT NOT NULL IDENTITY,
    [intOverrideTaxGroupId] INT NOT NULL,
    [intSupplierId] INT NULL,
    [intSupplyPointId] INT NULL,
    [intCustomerId] INT NULL,
    [intCustomerShipToId] INT NULL,
    [intBulkLocationId] INT NULL,
    [intShipViaId] INT NULL,
	[intReceiptTaxGroupId] INT NULL,
    [intDistributionTaxGroupId] INT NULL,
	[strReceiptState] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strDistributionState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTROverrideTaxGroupDetail_intOverrideTaxGroupDetailId] PRIMARY KEY CLUSTERED ([intOverrideTaxGroupDetailId] ASC),
	CONSTRAINT [FK_tblTROverrideTaxGroupDetail_tblTROverrideTaxGroup_intOverrideTaxGroupId] FOREIGN KEY ([intOverrideTaxGroupId]) REFERENCES [dbo].[tblTROverrideTaxGroup] ([intOverrideTaxGroupId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTROverrideTaxGroupDetail_tblAPVendor_intSupplierId] FOREIGN KEY ([intSupplierId]) REFERENCES [tblAPVendor]([intEntityId]), 
    CONSTRAINT [FK_tblTROverrideTaxGroupDetail_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [tblTRSupplyPoint](intSupplyPointId),
    CONSTRAINT [FK_tblTROverrideTaxGroupDetail_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer](intEntityId),
    CONSTRAINT [FK_tblTROverrideTaxGroupDetail_tblEMEntityLocation_intCustomerShipToId] FOREIGN KEY ([intCustomerShipToId]) REFERENCES [tblEMEntityLocation](intEntityLocationId),
	CONSTRAINT [FK_tblTROverrideTaxGroupDetail_tblSMCompanyLocation_intBulkLocationId] FOREIGN KEY ([intBulkLocationId]) REFERENCES [tblSMCompanyLocation](intCompanyLocationId),
	CONSTRAINT [FK_tblTROverrideTaxGroupDetail_tblSMShipVia_intShipViaId] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia](intEntityId)
)
