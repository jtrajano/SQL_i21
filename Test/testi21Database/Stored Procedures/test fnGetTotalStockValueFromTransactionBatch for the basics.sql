CREATE PROCEDURE testi21Database.[test fnGetTotalStockValueFromTransactionBatch for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @intTransactionId AS INT	
			,@strBatchId AS NVARCHAR(20)	
			,@Expected AS NUMERIC(18,6) = 0
			,@result AS NUMERIC(18,6)
	-- Act
	SELECT @result = dbo.fnGetTotalStockValueFromTransactionBatch(@intTransactionId, @strBatchId)

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @Expected, @result;
END