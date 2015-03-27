CREATE PROCEDURE testi21Database.[test fnGetTotalStockValueFromTransactionBatch for getting the actual total from the table]
AS 
BEGIN
	EXEC testi21Database.[Fake data for inventory transaction table]

	-- Arrange
	DECLARE @intTransactionId AS INT = 1
			,@strBatchId AS NVARCHAR(20) = 'BATCH-YYYY1'	
			,@expected AS NUMERIC(18,6) 
			,@result AS NUMERIC(18,6)

	SET @expected  = (1 * 100.00) + (2 * 100.00) + (2 * 100.00)

	-- Act
	SELECT @result = dbo.fnGetTotalStockValueFromTransactionBatch(@intTransactionId, @strBatchId)

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 
