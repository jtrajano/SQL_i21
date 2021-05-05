﻿CREATE PROCEDURE [dbo].[uspICLinkInventoryReceiptTransaction]
	@intReceiptId int,
	@ysnIsCreate bit = true
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

--Begin Transaction
BEGIN TRAN InventoryTransactionLink
SAVE TRAN InventoryTransactionLink

--Start Try Statement
BEGIN TRY

--User Define Type Variable
DECLARE @TransactionLink udtICTransactionLinks

IF @ysnIsCreate = 1
BEGIN

	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT
		'Create',
		intSrcId = ReceiptItemSource.intOrderId, 
		strSrcTransactionNo = COALESCE(ReceiptItemSource.strOrderNumber, ReceiptItemSource.strSourceNumber, 'Missing Transaction No'), 
		strSrcModuleName = ReceiptItemSource.strSourceType, 
		strSrcTransactionType = ReceiptItemSource.strSourceType,
		intDestId = ReceiptItemSource.intInventoryReceiptId,
		strDestTransactionNo = COALESCE(Receipt.strReceiptNumber, 'Missing Transaction No'),
		'Inventory',
		'Inventory Receipt'
    FROM dbo.tblICInventoryReceipt Receipt
	INNER JOIN dbo.vyuICGetReceiptItemSource ReceiptItemSource
	ON Receipt.intInventoryReceiptId = ReceiptItemSource.intInventoryReceiptId
	WHERE ReceiptItemSource.intOrderId IS NOT NULL 
	AND Receipt.intInventoryReceiptId = @intReceiptId

	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	GOTO Link_Exit
END

IF @ysnIsCreate = 0
BEGIN

	DECLARE @strReceiptNumber AS VARCHAR(50) 

	SELECT @strReceiptNumber = strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intReceiptId;

	EXEC dbo.uspICDeleteTransactionLinks @intReceiptId, @strReceiptNumber

	GOTO Link_Exit
END

END TRY

--Catch Errors and Rollback
BEGIN CATCH

	--Rollback Exit
	GOTO Link_Rollback_Exit

END CATCH

--Rollback Transaction
Link_Rollback_Exit:
BEGIN 
	ROLLBACK TRAN InventoryTransactionLink
END

Link_Exit:
BEGIN
	COMMIT TRAN InventoryTransactionLink
END