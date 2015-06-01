CREATE PROCEDURE testi21Database.[test fnGetTotalStockValueFromTransactionBatch for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @intTransactionId AS INT	
			,@strBatchId AS NVARCHAR(20)	
			,@expected AS NUMERIC(18,6) = 0
			,@result AS NUMERIC(18,6)
	-- Act
	SELECT @result = dbo.fnGetTotalStockValueFromTransactionBatch(@intTransactionId, @strBatchId)

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 