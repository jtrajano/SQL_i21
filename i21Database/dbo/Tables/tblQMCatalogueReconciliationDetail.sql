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
    [intGardenMarkId]						INT NULL,
    [intPreInvoiceGardenMarkId]				INT NULL,
    [intGradeId]                            INT NULL,
    [intPreInvoiceGradeId]                  INT NULL,
    [strChopNo]                             NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strPreInvoiceChopNo]                   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [ysnMismatched]                         BIT NULL DEFAULT 0,
	CONSTRAINT [PK_tblQMCatalogueReconciliationDetail_intCatalogueReconciliationDetailId] PRIMARY KEY CLUSTERED ([intCatalogueReconciliationDetailId] ASC),	
	CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblQMCatalogueReconciliationDetail_intCatalogueReconciliationId] FOREIGN KEY ([intCatalogueReconciliationId]) REFERENCES [dbo].[tblQMCatalogueReconciliation] ([intCatalogueReconciliationId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblAPBillDetail_intBillDetailId] FOREIGN KEY ([intBillDetailId]) REFERENCES [dbo].[tblAPBillDetail] ([intBillDetailId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblQMSample_intSampleId] FOREIGN KEY ([intSampleId]) REFERENCES [dbo].[tblQMSample] ([intSampleId]),
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblQMGardenMark_intGardenMarkId] FOREIGN KEY ([intGardenMarkId]) REFERENCES [dbo].[tblQMGardenMark] ([intGardenMarkId]),
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblQMGardenMark_intPreInvoiceGardenMarkId] FOREIGN KEY ([intPreInvoiceGardenMarkId]) REFERENCES [dbo].[tblQMGardenMark] ([intGardenMarkId]),
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblICCommodityAttribute_intGradeId] FOREIGN KEY ([intGradeId]) REFERENCES [dbo].[tblICCommodityAttribute] ([intCommodityAttributeId]),
    CONSTRAINT [FK_tblQMCatalogueReconciliationDetail_tblICCommodityAttribute_intPreInvoiceGradeId] FOREIGN KEY ([intPreInvoiceGradeId]) REFERENCES [dbo].[tblICCommodityAttribute] ([intCommodityAttributeId])
);
GO
CREATE INDEX [idx_tblQMCatalogueReconciliationDetail_intBillDetailId] ON [dbo].[tblQMCatalogueReconciliationDetail] (intBillDetailId)
GO
CREATE INDEX [idx_tblQMCatalogueReconciliationDetail_intSampleId] ON [dbo].[tblQMCatalogueReconciliationDetail] (intSampleId)
GO