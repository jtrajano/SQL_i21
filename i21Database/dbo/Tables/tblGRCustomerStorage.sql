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
    [intDiscountScheduleId] INT NULL, 
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
	[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,  
    [intCompanyLocationSubLocationId] INT NULL, 
    [intStorageLocationId] INT NULL,
	[intUnitMeasureId] [int] NULL,
	[intDeliverySheetId] INT NULL,
	[intItemUOMId] [int] NULL, 
    [ysnTransferStorage] BIT NOT NULL DEFAULT 0,
    [dblGrossQuantity] NUMERIC(18,6) NULL,
    [intShipFromLocationId] INT NULL,
    [intShipFromEntityId] INT NULL,
    [dblBasis] DECIMAL(18, 6) NOT NULL DEFAULT 0,
    [dblSettlementPrice] DECIMAL(18, 6) NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblGRCustomerStorage_intCustomerStorageId] PRIMARY KEY ([intCustomerStorageId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [dbo].[tblICCommodity] ([intCommodityId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblGRStorageScheduleRule_intStorageScheduleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [dbo].[tblGRStorageScheduleRule] ([intStorageScheduleRuleId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblGRStorageType_intStorageTypeId] FOREIGN KEY ([intStorageTypeId]) REFERENCES [dbo].[tblGRStorageType] ([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblSCDeliverySheet_intDeliverySheetId] FOREIGN KEY ([intDeliverySheetId]) REFERENCES [dbo].[tblSCDeliverySheet] ([intDeliverySheetId]),
	CONSTRAINT [FK_tblGRCustomerStorage_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblGRCustomerStorage_intTicketId] ON [dbo].[tblGRCustomerStorage]([intTicketId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblGRCustomerStorage_intDeliverySheetId] ON [dbo].[tblGRCustomerStorage]([intDeliverySheetId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblGRCustomerStorage_intItemId]
	ON [dbo].[tblGRCustomerStorage] ([intItemId])
	INCLUDE ([intEntityId],[intCommodityId],[intStorageScheduleId],[intStorageTypeId],[intCompanyLocationId],[dtmDeliveryDate],[strDPARecieptNumber],[dtmLastStorageAccrueDate],[dblStorageDue],[dblDiscountsDue],[strCustomerReference],[strStorageType],[strStorageTicketNumber],[intDeliverySheetId])
GO


