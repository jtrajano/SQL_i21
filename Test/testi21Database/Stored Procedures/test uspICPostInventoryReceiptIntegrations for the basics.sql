﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceiptIntegrations for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE	@ysnPost BIT = NULL 
				,@intTransactionId INT = NULL 
				,@intEntityId INT  = NULL
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.ExpectNoException; 
	END 
		
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceiptIntegrations 
				@ysnPost
				,@intTransactionId
				,@intEntityId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END