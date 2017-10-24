﻿/*
	Retrieve total stock value from a batch of records in tblICInventoryTransaction table. 
*/

CREATE FUNCTION [dbo].[fnMFGetTotalStockValueFromTransactionBatch]
(
	@intTransactionId AS INT	
	,@strBatchId AS NVARCHAR(40)
)
RETURNS NUMERIC(18, 6)
AS 
BEGIN 
	DECLARE @Value AS NUMERIC(18,6)

	-- Get the total value of items from a batch of inventory transaction
	SELECT	@Value = SUM(
					CAST(
						dbo.fnMultiply(A.dblQty, A.dblCost) + ISNULL(A.dblValue, 0) 
						AS NUMERIC(18, 6)
					) 
			) 
	FROM	[dbo].[tblICInventoryTransaction] A
	WHERE	A.intTransactionId = @intTransactionId
			AND A.strBatchId = @strBatchId

	RETURN ISNULL(@Value, 0)
END
