﻿CREATE TABLE [dbo].[tblGRSettleStorage]
(
	[intSettleStorageId] INT NOT NULL  IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intEntityId] INT NULL,
	[intCompanyLocationId] INT NULL, 
	[intItemId] INT NULL,
	[dblSpotUnits] NUMERIC(18, 6) NULL,
	[dblFuturesPrice] NUMERIC(18, 6) NULL,     
	[dblFuturesBasis] NUMERIC(18, 6) NULL,
	[dblCashPrice] NUMERIC(18, 6) NULL,
	[strStorageAdjustment] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	[dtmCalculateStorageThrough] DATETIME NULL,
	[dblAdjustPerUnit] NUMERIC(18, 6) NULL,
	[dblStorageDue] NUMERIC(18, 6) NULL,
	[strStorageTicket] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	[dblSelectedUnits] NUMERIC(18, 6) NULL,
	[dblUnpaidUnits] NUMERIC(18, 6) NULL,
	[dblSettleUnits] NUMERIC(18, 6) NULL,
	[dblDiscountsDue] NUMERIC(18, 6) NULL,
	[dblNetSettlement] NUMERIC(18, 6) NULL,
	[ysnPosted] [bit] NULL DEFAULT ((0)),
	[intCommodityId] INT NULL,
	[intCommodityStockUomId] INT NULL,
	[intCreatedUserId] INT NULL,
	[intBillId] INT NULL,
	[dtmCreated] DATETIME NULL,
	[intParentSettleStorageId] INT NULL,
	[intItemUOMId] INT NULL,
    CONSTRAINT [PK_tblGRSettleStorage_intCustomerStorageId] PRIMARY KEY ([intSettleStorageId]),
	CONSTRAINT [FK_tblGRSettleStorage_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),	
	CONSTRAINT [FK_tblGRSettleStorage_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblGRSettleStorage_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]),
	CONSTRAINT [FK_tblGRSettleStorage_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)

CREATE NONCLUSTERED INDEX IX_tblGRSettleStorage_intParentSettleStorageId
ON tblGRSettleStorage (intParentSettleStorageId ASC)