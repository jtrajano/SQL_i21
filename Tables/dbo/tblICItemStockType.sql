/*
## Overview
This table holds stock information like quantity on hand and etc. 

## Important Notes:

## Source Code:
*/
CREATE TABLE [dbo].[tblICItemStockType]
(
	[intItemStockTypeId] INT IDENTITY (1, 1) NOT NULL, 
	[strName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
	CONSTRAINT [PK_tblICItemStockType] PRIMARY KEY CLUSTERED ([intItemStockTypeId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICItemStockType_intItemStockTypeId]
	ON [dbo].[tblICItemStockType]([intItemStockTypeId] ASC)
GO