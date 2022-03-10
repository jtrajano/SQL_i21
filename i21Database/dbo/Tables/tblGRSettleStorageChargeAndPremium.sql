CREATE TABLE [dbo].[tblGRSettleStorageChargeAndPremium]
(
	[intSettleStorageChargeAndPremiumId] INT NOT NULL IDENTITY
    ,[intParentSettleStorageId]     INT NULL
    ,[intCustomerStorageId] 		INT NOT NULL
    ,[intChargeAndPremiumDetailId]	INT NOT NULL
    ,[dblRate]						DECIMAL(18,6)
    ,[dblUnits]						DECIMAL(38, 20) NULL
    ,[dblCost]						DECIMAL(38, 20) NULL
	,[ysnOverride]					BIT DEFAULT((0))
	,[intConcurrencyId] INT NULL DEFAULT ((1))
	,CONSTRAINT [PK_tblGRSettleStorageChargeAndPremium_intSettleStorageChargeAndPremiumId] PRIMARY KEY ([intSettleStorageChargeAndPremiumId]),
    CONSTRAINT [FK_tblGRSettleStorageChargeAndPremium_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [tblGRCustomerStorage]([intCustomerStorageId]),
	CONSTRAINT [PK_tblGRSettleStorageChargeAndPremium_intChargeAndPremiumDetailId] FOREIGN KEY ([intChargeAndPremiumDetailId]) REFERENCES [tblGRChargeAndPremiumDetail]([intChargeAndPremiumDetailId]),
	CONSTRAINT [FK_tblGRSettleStorageChargeAndPremium_tblGRSettleStorage_intParentSettleStorageId] FOREIGN KEY ([intParentSettleStorageId]) REFERENCES [tblGRSettleStorage]([intSettleStorageId]) ON DELETE CASCADE
)
