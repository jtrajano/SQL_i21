CREATE TYPE [dbo].[SettleStorageTicket] AS TABLE 
(
    [intCustomerStorageId] INT,
    [intChargeAndPremiumId] INT,
	[dblUnits] DECIMAL(24, 10)
)