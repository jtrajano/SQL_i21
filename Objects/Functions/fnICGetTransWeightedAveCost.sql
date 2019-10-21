CREATE FUNCTION [dbo].[fnICGetTransWeightedAveCost] (
	@strTransactionId AS NVARCHAR(50) 
	,@intTransactionId INT
	,@intTransactionDetail INT
	,@CheckPositive BIT = 1
)
RETURNS NUMERIC(38,20)
AS
BEGIN 	
	DECLARE @returnBalance AS NUMERIC(38,20)

	SELECT	@returnBalance = 
				dbo.fnDivide(
					SUM(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0)) 
					,SUM(t.dblQty)
				)
	FROM	tblICInventoryTransaction t 
	WHERE	t.strTransactionId = @strTransactionId
			AND t.intTransactionId = @intTransactionId
			AND t.intTransactionDetailId = @intTransactionDetail			
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND ((ISNULL(t.dblQty, 0) >= 0  AND @CheckPositive = 1) OR @CheckPositive = 0)
	HAVING SUM(t.dblQty) <> 0 

	RETURN ISNULL(@returnBalance, 0)
END 