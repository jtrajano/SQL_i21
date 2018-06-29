CREATE TRIGGER trgARSalesOrderNumber
ON dbo.tblSOSalesOrder
AFTER INSERT
AS

DECLARE @inserted TABLE(intSalesOrderId INT, strTransactionType NVARCHAR(10), intCompanyLocationId INT)
DECLARE @count INT = 0
DECLARE @intSalesOrderId INT
DECLARE @intCompanyLocationId INT
DECLARE @SalesOrderNumber NVARCHAR(50)
DECLARE @strTransactionType NVARCHAR(25)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = 0

INSERT INTO @inserted
SELECT intSalesOrderId, strTransactionType, intCompanyLocationId FROM INSERTED ORDER BY intSalesOrderId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intSalesOrderId = intSalesOrderId, @strTransactionType = strTransactionType, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM tblSMStartingNumber 
	WHERE strTransactionType = CASE WHEN @strTransactionType = 'Order' THEN 'Sales Order' 
									WHEN @strTransactionType = 'Quote' THEN 'Quote' END

	IF(@intStartingNumberId <> 0)
		EXEC uspSMGetStartingNumber @intStartingNumberId, @SalesOrderNumber OUT, @intCompanyLocationId
	
	IF(@SalesOrderNumber IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblSOSalesOrder WHERE strSalesOrderNumber = @SalesOrderNumber)
			BEGIN
				SET @SalesOrderNumber = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strSalesOrderNumber, 4, 10))) FROM tblSOSalesOrder WHERE strTransactionType = @strTransactionType
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
				EXEC uspSMGetStartingNumber @intStartingNumberId, @SalesOrderNumber OUT, @intCompanyLocationId
			END
		
		UPDATE tblSOSalesOrder
			SET tblSOSalesOrder.strSalesOrderNumber = @SalesOrderNumber
		FROM tblSOSalesOrder A
		WHERE A.intSalesOrderId = @intSalesOrderId
	END

	DELETE FROM @inserted
	WHERE intSalesOrderId = @intSalesOrderId

END