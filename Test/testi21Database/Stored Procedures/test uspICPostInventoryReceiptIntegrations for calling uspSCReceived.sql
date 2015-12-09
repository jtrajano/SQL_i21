﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceiptIntegrations for calling uspSCReceived]
AS
BEGIN
	-- Setup the fake data
	BEGIN 
		-- Declare the constants 
		DECLARE	-- Receipt Types
				@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
				,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
				,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
				,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'
				-- Source Types
				,@SOURCE_TYPE_NONE AS INT = 0
				,@SOURCE_TYPE_SCALE AS INT = 1
				,@SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
				,@SOURCE_TYPE_TRANSPORT AS INT = 3

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;

		-- Setup the fake receipt data. 
		INSERT INTO tblICInventoryReceipt (
				strReceiptType
				,intSourceType
				,strReceiptNumber
		)
		SELECT	strReceiptType = @RECEIPT_TYPE_PURCHASE_CONTRACT
				,intSourceType = @SOURCE_TYPE_SCALE
				,strReceiptNumber = 'INVRCT-1XXXX1'

		-- Add a spy for uspSCReceived
		EXEC tSQLt.SpyProcedure 'dbo.uspSCReceived';		
	END

	-- Arrange 
	BEGIN 
		DECLARE	@ysnPost BIT = 1 
				,@intTransactionId INT = 1
				,@intEntityId INT  = 1
	END 
		
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceiptIntegrations 
				@ysnPost
				,@intTransactionId
				,@intEntityId
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.AssertObjectExists 'uspSCReceived_SpyProcedureLog'
		
		DECLARE @expectedCount AS INT = 1 
				,@actualCount AS INT

		SELECT @actualCount = COUNT(*) FROM uspSCReceived_SpyProcedureLog

		EXEC tSQLt.AssertEquals @expectedCount, @actualCount
	END 


	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END