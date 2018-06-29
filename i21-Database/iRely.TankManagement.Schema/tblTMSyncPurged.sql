CREATE TABLE [dbo].[tblTMSyncPurged] (
    [intSyncPurged]                 INT             IDENTITY (1, 1) NOT NULL,
    [strCustomerNumber]             NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT (('0')) NOT NULL,
    [strCustomerName]               NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteNumber]                 NVARCHAR (4)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NOT NULL,
    [strSiteAddress]                NCHAR (500)     COLLATE Latin1_General_CI_AS NULL,
    [dblMeterReading]               DECIMAL (18, 6) CONSTRAINT [DF_Table_1_MeterReading] DEFAULT ((0)) NULL,
    [strInvoiceNumber]              NVARCHAR (8)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NOT NULL,
    [strBulkPlantNumber]            NVARCHAR (3)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NOT NULL,
    [dtmInvoiceDate]                DATETIME        CONSTRAINT [DF_Table_1_InvoiceDate_1] DEFAULT ((0)) NULL,
    [strItemNumber]                 NVARCHAR (13)   COLLATE Latin1_General_CI_AS DEFAULT (('0')) NULL,
    [strItemAvailableForTM]         NVARCHAR (1)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NULL,
    [strReversePreviousDelivery]    NVARCHAR (1)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NULL,
    [strPerformerID]                NVARCHAR (3)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NULL,
    [intInvoiceLineNumber]          INT             DEFAULT 0 NOT NULL,
    [dblExtendedAmount]             DECIMAL (18, 6) DEFAULT 0 NULL,
    [dblQuantityDelivered]          DECIMAL (18, 6) DEFAULT 0 NULL,
    [dblActualPercentAfterDelivery] DECIMAL (18, 6) DEFAULT 0 NULL,
    [strInvoiceType]                NVARCHAR (1)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NULL,
    [strSalesPersonID]              NVARCHAR (3)    COLLATE Latin1_General_CI_AS DEFAULT (('0')) NULL,
    [strReason]                     NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intUserID]                     INT             NOT NULL,
    [dtmPurgeDate]                  DATETIME        NOT NULL,
    [intConcurrencyId]              INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMSyncPurged] PRIMARY KEY CLUSTERED ([intSyncPurged] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'intSyncPurged'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strSiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strSiteAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'dblMeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strInvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bulk Plant Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strBulkPlantNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'dtmInvoiceDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strItemNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Available for TM Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strItemAvailableForTM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reverse Previous Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strReversePreviousDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Performer ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strPerformerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Line Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'intInvoiceLineNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extended Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'dblExtendedAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity Delivered',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantityDelivered'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Actual Percent After Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'dblActualPercentAfterDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strInvoiceType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Person ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strSalesPersonID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fail Reason',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'strReason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purged Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'dtmPurgeDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncPurged',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'