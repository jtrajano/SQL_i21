CREATE PROCEDURE [dbo].[uspICLogItemStockPath]
	@intInventoryTransactionId_Ancestor AS INT
	,@intInventoryTransactionId_Descendant AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Validate if there is cyclic ancestor and descendant relationship. 

-- Call uspICCreateStockPathNode
-- 