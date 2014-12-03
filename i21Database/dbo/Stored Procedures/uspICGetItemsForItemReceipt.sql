CREATE PROCEDURE [dbo].[uspICGetItemsForItemReceipt]
	@intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



-- TODO by Lawrence
-- CREATE THE Header record for the item receipt. 


-- TODO by Lawrence 
-- Select the items from the source transaction 
--SELECT			intItemId
		--,intLocationId
		--,dtmDate
		--,dblUnitQty
		--,dblUOMQty
		--,dblCost
		--,dblSalesPrice
		--,intCurrencyId
		--,dblExchangeRate
		--,intTransactionId
		--,strTransactionId
		--,intTransactionTypeId
		--,intLotId
--FROM Source