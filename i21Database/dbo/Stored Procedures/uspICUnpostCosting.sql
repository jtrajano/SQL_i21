/*
	Used to reverse the stocks from a posted transaction.
*/

CREATE PROCEDURE [dbo].[uspICUnpostCosting]
	@ItemsToUnpost AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


