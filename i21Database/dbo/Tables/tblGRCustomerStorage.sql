CREATE TABLE [dbo].[tblGRCustomerStorage]
(
	[intCustomerStorageId] INT NOT NULL  IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intEntityId] INT NULL, 
	[intCommodityId] INT NOT NULL, 
    [intStorageScheduleId] INT NULL, 
    [intStorageTypeId] INT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
    [intTicketId] INT NULL, 
    [intDiscountScheduleId] INT NOT NULL, 
    [dblTotalPriceShrink] NUMERIC(18, 6) NULL, 
    [dblTotalWeightShrink] NUMERIC(18, 6) NULL, 
    [dblOriginalBalance] NUMERIC(18, 6) NOT NULL, 
    [dblOpenBalance] NUMERIC(18, 6) NOT NULL, 
    [dtmDeliveryDate] DATETIME NULL, 
    [dtmZeroBalanceDate] DATETIME NULL, 
    [strDPARecieptNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [dtmLastStorageAccrueDate] DATETIME NULL, 
    [dblStorageDue] NUMERIC(18, 6) NULL, 
    [dblStoragePaid] NUMERIC(18, 6) NULL, 
    [dblInsuranceRate] NUMERIC(18, 6) NULL, 
    [strOriginState] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strInsuranceState] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [dblFeesDue] NUMERIC(18, 6) NULL, 
    [dblFeesPaid] NUMERIC(18, 6) NULL, 
    [dblFreightDueRate] NUMERIC(18, 6) NULL, 
    [ysnPrinted] BIT NULL, 
    [dblCurrencyRate] NUMERIC(18, 8) NULL, 
    [strDiscountComment] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [dblDiscountsDue] NUMERIC(18, 6) NULL, 
    [dblDiscountsPaid] NUMERIC(18, 6) NULL, 
    [strCustomerReference] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strStorageType] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
    [intCurrencyId] INT NULL,
	[intStorageTicketNumber] INT NULL, 
    CONSTRAINT [PK_tblGRCustomerStorage_intCustomerStorageId] PRIMARY KEY ([intCustomerStorageId]),
	CONSTRAINT [UK_tblGRCustomerStorage_intEntityId_intStorageTicket_intStorageTypeId_intCommodityId_intCompanyLocationId_intStorageScheduleId] UNIQUE ([intEntityId],[intStorageTicketNumber],[intStorageTypeId],[intCommodityId],[intCompanyLocationId],[intStorageScheduleId]), 
	CONSTRAINT [FK_tblGRCustomerStorage_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [dbo].[tblICCommodity] ([intCommodityId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblGRStorageScheduleRule_intStorageScheduleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [dbo].[tblGRStorageScheduleRule] ([intStorageScheduleRuleId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblGRStorageType_intStorageTypeId] FOREIGN KEY ([intStorageTypeId]) REFERENCES [dbo].[tblGRStorageType] ([intStorageScheduleTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerStorageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Schedule Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'intStorageScheduleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'intStorageTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = 'intCompanyLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = 'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Schedule Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = 'intDiscountScheduleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Shrink',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblTotalPriceShrink'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Shrink',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblTotalWeightShrink'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Original Balance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblOriginalBalance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Open Balance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblOpenBalance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zero Balance Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dtmZeroBalanceDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dtmDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'strDPARecieptNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Accure Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastStorageAccrueDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Due',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblStorageDue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Paid',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblStoragePaid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Insurance Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblInsuranceRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Origin State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'strOriginState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Insurance State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'strInsuranceState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fees Due',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblFeesDue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fees Paid',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblFeesPaid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Due',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightDueRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Printed Yes/No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Currency Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'dblCurrencyRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Type Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRCustomerStorage',
    @level2type = N'COLUMN',
    @level2name = N'strStorageType'