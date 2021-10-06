CREATE PROCEDURE [dbo].[uspICLinkInventoryReceiptTransaction]
	@intReceiptId int,
	@ysnIsCreate bit = true
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON

--Begin Transaction
BEGIN TRAN InventoryTransactionLink
SAVE TRAN InventoryTransactionLink

--Start Try Statement
BEGIN TRY

IF (dbo.fnSMCheckIfLicensed('Transaction Traceability') = 1)
BEGIN

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
		intSrcId = Source.intSourceTransactionId, 
		strSrcTransactionNo = COALESCE(Source.strSourceTransactionNumber, 'Missing Transaction No'), 
		strSrcModuleName = Source.strSourceModule, 
		strSrcTransactionType = Source.strSourceScreen,
		intDestId = Source.intReceiptId,
		strDestTransactionNo = COALESCE(Source.strReceiptNumber, 'Missing Transaction No'),
		'Inventory',
		'Inventory Receipt'
    FROM vyuICGetReceiptDetailSource Source
	WHERE Source.intReceiptId = @intReceiptId

	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	GOTO Link_Exit
END

IF @ysnIsCreate = 0
BEGIN

	DECLARE @strReceiptNumber AS VARCHAR(50) 

	SELECT @strReceiptNumber = strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intReceiptId;

	EXEC dbo.uspICDeleteTransactionLinks 
		@intReceiptId, 
		@strReceiptNumber, 
		'Inventory Receipt',
		'Inventory'

	GOTO Link_Exit
END

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