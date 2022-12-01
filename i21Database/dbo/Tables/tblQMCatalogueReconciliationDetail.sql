CREATE TABLE [dbo].[tblQMCatalogueReconciliationDetail]
(
	[intCatalogueReconciliationDetailId]    INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] 			            INT NULL DEFAULT ((1)),
    [intCatalogueReconciliationId] 	        INT NOT NULL,
	[intBillDetailId]				        INT NOT NULL,
    [intSampleId]                           INT NULL,
	[strSupplierPreInvoiceNumber]		    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dtmSupplierPreInvoiceDate] 			DATETIME NULL,
	[dblBasePrice] 			                NUMERIC(18,6)   NULL DEFAULT 0,
    [dblPreInvoicePrice]                    NUMERIC(18,6)   NULL DEFAULT 0,
    [dblQuantity]                           NUMERIC(18,6)   NULL DEFAULT 0,
    [dblPreInvoiceQuantity]                 NUMERIC(18,6)   NULL DEFAULT 0,
    [strGarden]								NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strPreInvoiceGarden]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strGrade]                              NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strPreInvoiceGrade]                    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strChopNo]                             NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strPreInvoiceChopNo]                   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblQMCatalogueReconciliationDetail_intCatalogueReconciliationDetailId] PRIMARY KEY CLUSTERED ([intCatalogueReconciliationDetailId] ASC),	
	CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblQMCatalogueReconciliationDetail_intCatalogueReconciliationId] FOREIGN KEY ([intCatalogueReconciliationId]) REFERENCES [dbo].[tblQMCatalogueReconciliation] ([intCatalogueReconciliationId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblAPBillDetail_intBillDetailId] FOREIGN KEY ([intBillDetailId]) REFERENCES [dbo].[tblAPBillDetail] ([intBillDetailId]),
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblQMSample_intSampleId] FOREIGN KEY ([intSampleId]) REFERENCES [dbo].[tblQMSample] ([intSampleId])
);
GO
CREATE INDEX [idx_tblQMCatalogueReconciliationDetail_intBillDetailId] ON [dbo].[tblQMCatalogueReconciliationDetail] (intBillDetailId)
GO
CREATE INDEX [idx_tblQMCatalogueReconciliationDetail_intSampleId] ON [dbo].[tblQMCatalogueReconciliationDetail] (intSampleId)
GO