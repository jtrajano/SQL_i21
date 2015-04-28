﻿CREATE TABLE [dbo].[tblSOSalesOrderDetailTax]
(
	[intSalesOrderDetailTaxId] INT NOT NULL IDENTITY, 
    [intSalesOrderDetailId] INT NOT NULL, 
    [intTaxGroupMasterId] INT NOT NULL, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
	[strTaxableByOtherTaxes] NVARCHAR(MAX) NULL, 
    [strCalculationMethod] NVARCHAR(15) NULL, 
    [numRate] NUMERIC(18, 6) NULL, 
    [intSalesTaxAccountId] INT NULL, 
    [dblTax] NUMERIC(18, 6) NULL, 
    [dblAdjustedTax] NUMERIC(18, 6) NULL, 
	[ysnSeparateOnInvoice] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT CONSTRAINT [DF_tblSOSalesOrderDetailTax_intConcurrencyId] DEFAULT ((0)) NOT NULL,	
    CONSTRAINT [PK_tblSOSalesOrderDetailTax_intSalesOrderDetailTaxId] PRIMARY KEY CLUSTERED ([intSalesOrderDetailTaxId] ASC),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSOSalesOrderDetail_intSalesOrderDetailId] FOREIGN KEY ([intSalesOrderDetailId]) REFERENCES [dbo].[tblSOSalesOrderDetail] ([intSalesOrderDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSMTaxGroupMaster_intTaxGroupMasterId] FOREIGN KEY ([intTaxGroupMasterId]) REFERENCES [dbo].[tblSMTaxGroupMaster] ([intTaxGroupMasterId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblSMTaxClass_intTaxClassId] FOREIGN KEY ([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId]),
	CONSTRAINT [FK_tblSOSalesOrderDetailTax_tblGLAccount_intSalesTaxAccountId] FOREIGN KEY ([intSalesTaxAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
