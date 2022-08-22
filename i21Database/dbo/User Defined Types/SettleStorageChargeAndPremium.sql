CREATE TYPE [dbo].[SettleStorageChargeAndPremium] AS TABLE
(
	[intParentSettleStorageId]     INT NULL
    ,[intCustomerStorageId] 		INT
    ,[intChargeAndPremiumDetailId]	INT
    ,[dblRate]						DECIMAL(18,6)
    ,[dblUnits]						DECIMAL(38, 20)
    ,[dblCost]						DECIMAL(38, 20)
	,[ysnOverride]					BIT DEFAULT((0))
)