CREATE PROCEDURE [dbo].[uspICLinkInventoryTransferTransaction]
	@intTransferId int,
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
		intSrcId = TransferDetailSource.intSourceId, 
		strSrcTransactionNo = COALESCE(TransferDetailSource.strSourceTransactionNo, 'Missing Transaction No'), 
		strSrcModuleName = TransferDetailSource.strSourceModule, 
		strSrcTransactionType = TransferDetailSource.strSourceScreen,
		intDestId = TransferDetailSource.intInventoryTransferId,
		strDestTransactionNo = COALESCE(Transfer.strTransferNo, 'Missing Transaction No'),
		'Inventory',
		'Inventory Transfer'
    FROM dbo.tblICInventoryTransfer Transfer
	INNER JOIN dbo.vyuICGetTransferDetailSource TransferDetailSource
	ON Transfer.intInventoryTransferId = TransferDetailSource.intInventoryTransferId
	WHERE TransferDetailSource.intSourceId IS NOT NULL
	AND Transfer.intInventoryTransferId = @intTransferId

	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	GOTO Link_Exit
END

IF @ysnIsCreate = 0
BEGIN

	DECLARE @strTransferNo AS VARCHAR(50) 

	SELECT @strTransferNo = strTransferNo FROM tblICInventoryTransfer WHERE intInventoryTransferId = @intTransferId;

	EXEC dbo.uspICDeleteTransactionLinks 
		@intTransferId, 
		@strTransferNo, 
		'Inventory Transfer',
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