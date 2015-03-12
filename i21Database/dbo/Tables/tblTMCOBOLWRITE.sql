CREATE TABLE [dbo].[tblTMCOBOLWRITE] (
    [CustomerNumber]             CHAR (10)       CONSTRAINT [DEF_tblTMCOBOLWRITE_CustomerNumber] DEFAULT ((0)) NOT NULL,
    [SiteNumber]                 CHAR (4)        CONSTRAINT [DEF_tblTMCOBOLWRITE_SiteNumber] DEFAULT ((0)) NOT NULL,
    [MeterReading]               DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_MeterReading] DEFAULT ((0)) NULL,
    [InvoiceNumber]              CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceNumber] DEFAULT ((0)) NOT NULL,
    [BulkPlantNumber]            CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLWRITE_BulkPlantNumber] DEFAULT ((0)) NOT NULL,
    [InvoiceDate]                CHAR (8)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceDate] DEFAULT ((0)) NULL,
    [ItemNumber]                 CHAR (13)       CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemNumber] DEFAULT ((0)) NULL,
    [ItemAvailableForTM]         CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemAvailableForTM] DEFAULT ((0)) NULL,
    [ReversePreviousDelivery]    CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_ReversePreviousDelivery] DEFAULT ((0)) NULL,
    [PerformerID]                CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLWRITE_PerformerID] DEFAULT ((0)) NULL,
    [InvoiceLineNumber]          DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceLineNumber] DEFAULT ((0)) NOT NULL,
    [ExtendedAmount]             DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_ExtendedAmount] DEFAULT ((0)) NULL,
    [QuantityDelivered]          DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_QuantityDelivered] DEFAULT ((0)) NULL,
    [ActualPercentAfterDelivery] DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLWRITE_ActualPercentAfterDelivery] DEFAULT ((0)) NULL,
    [InvoiceType]                CHAR (1)        CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceType] DEFAULT ((0)) NULL,
    [SalesPersonID]              CHAR (3)        CONSTRAINT [DEF_tblTMCOBOLWRITE_SalesPersonID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMCOBOLWRITE] PRIMARY KEY CLUSTERED ([BulkPlantNumber] ASC, [CustomerNumber] ASC, [InvoiceLineNumber] ASC, [InvoiceNumber] ASC, [SiteNumber] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'CustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'SiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'MeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'InvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bulk Plant Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'BulkPlantNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'InvoiceDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'ItemNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Available for TM Option (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'ItemAvailableForTM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reverse Previous Delivery Option (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'ReversePreviousDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Performer ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'PerformerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Line Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'InvoiceLineNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extended Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'ExtendedAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity Delivered',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'QuantityDelivered'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Actual Percent After Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'ActualPercentAfterDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'InvoiceType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Person ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLWRITE',
    @level2type = N'COLUMN',
    @level2name = N'SalesPersonID'