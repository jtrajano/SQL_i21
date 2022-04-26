/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
CREATE TABLE [dbo].[tblICInventoryTradeFinanceLot]
(
	[intInventoryTradeFinanceLotId] [int] IDENTITY NOT NULL,
	[intInventoryTradeFinanceId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[intLotId] [int] NOT NULL,
	[strWarrantNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	[intWarrantStatus] INT NULL,

	CONSTRAINT [PK_tblICInventoryTradeFinanceLot] PRIMARY KEY ([intInventoryTradeFinanceLotId]), 
	CONSTRAINT [FK_tblICInventoryTradeFinanceLot_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblICInventoryTradeFinanceLot_intLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot] ([intLotId]),
)
GO