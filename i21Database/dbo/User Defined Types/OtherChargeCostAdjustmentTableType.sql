﻿/*
	This is a user-defined table type to list the other charges that will have cost adjustment. 
*/
CREATE TYPE [dbo].[OtherChargeCostAdjustmentTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
	,[intInventoryReceiptChargeId] INT NOT NULL				
	,[dblNewValue] NUMERIC(38, 20) NULL
	,[dtmDate] DATETIME 
	,[intTransactionId] INT
	,[intTransactionDetailId] INT
	,[strTransactionId] INT 
)
