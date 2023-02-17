/*
	This is a user-defined table type to list the other charges that will have cost adjustment. 
*/
CREATE TYPE [dbo].[OtherChargeCostAdjustmentTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
	,[intInventoryReceiptChargeId] INT NOT NULL				
	,[dblNewValue] NUMERIC(38, 20) NULL
	,[dblNewForexValue] NUMERIC(38, 20) NULL
	,[dtmDate] DATETIME 
	,[intTransactionId] INT
	,[intTransactionDetailId] INT
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL		
	,[intCurrencyId] INT NULL -- The currency id used in a transaction. 
	,[intForexRateTypeId] INT NULL
	,[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1
)
