﻿CREATE FUNCTION [dbo].[fnGetItemTotalValueFromTransactions]
(
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE @totalItemValuation AS NUMERIC(38,20)

	-- Get the total transaction value of an item per location. 
	SELECT	@totalItemValuation = 
				SUM (
					dbo.fnMultiply(A.dblQty, A.dblCost) 
					+ ISNULL(A.dblValue, 0)
				) 
	FROM	[dbo].[tblICInventoryTransaction] A
	WHERE	A.intItemId = @intItemId
			AND A.intItemLocationId = @intItemLocationId

	RETURN ISNULL(@totalItemValuation, 0)
END
GO