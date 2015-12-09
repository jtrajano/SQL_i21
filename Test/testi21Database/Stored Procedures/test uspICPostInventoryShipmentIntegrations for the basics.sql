CREATE PROCEDURE [testi21Database].[test uspICPostInventoryShipmentIntegrations for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE	@ysnPost BIT = NULL 
				,@intTransactionId INT = NULL 
				,@intEntityUserSecurityId  INT  = NULL 
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.ExpectNoException; 
	END 
		
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryShipmentIntegrations 
				@ysnPost
				,@intTransactionId
				,@intEntityUserSecurityId
	END 
END