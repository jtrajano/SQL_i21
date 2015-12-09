CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @ysnPost AS BIT
		DECLARE @ysnRecap AS BIT
		DECLARE @strTransactionId AS NVARCHAR(40)
		DECLARE @intEntityId AS INT 
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50004
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intEntityId
	END 
END 