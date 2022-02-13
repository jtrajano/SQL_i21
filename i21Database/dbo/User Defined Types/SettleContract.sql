CREATE TYPE [dbo].[SettleContract] AS TABLE 
(
    [intContractDetailId] INT NULL,
	[dblUnits] DECIMAL(24, 10) NULL,
	[dblPrice] DECIMAL(24, 10) NULL
)