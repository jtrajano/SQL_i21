CREATE TABLE [dbo].[tblTMDeliveryHistoryDetail] (
    [intDeliveryHistoryDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber]           NVARCHAR (8)    COLLATE Latin1_General_CI_AS NULL,
    [dblQuantityDelivered]       NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [strItemNumber]              NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [intDeliveryHistoryID]       INT             NOT NULL,
    [intConcurrencyId]           INT             DEFAULT 1 NOT NULL,
    [dblPercentAfterDelivery]    DECIMAL (18, 6) DEFAULT 0 NOT NULL,
    [dblExtendedAmount]       NUMERIC (18, 6) NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblTMDeliveryHistoryDetail] PRIMARY KEY CLUSTERED ([intDeliveryHistoryDetailID] ASC),
    CONSTRAINT [FK_tblTMDeliveryHistoryDetail_tblTMDeliveryHistory] FOREIGN KEY ([intDeliveryHistoryID]) REFERENCES [dbo].[tblTMDeliveryHistory] ([intDeliveryHistoryID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryHistoryDetailID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice No.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'strInvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity Delivered',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantityDelivered'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item No.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'strItemNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery History Master Record ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryHistoryID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent After Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblPercentAfterDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extended Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryHistoryDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblExtendedAmount'