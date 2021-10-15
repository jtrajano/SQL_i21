CREATE PROCEDURE [dbo].[uspICLinkInventoryAdjustmentTransaction]
	@intAdjustmentId int,
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
		intSrcId = AdjustmentDetailSource.intSourceId, 
		strSrcTransactionNo = COALESCE(AdjustmentDetailSource.strSourceTransactionNo, 'Missing Transaction No'), 
		strSrcModuleName =  'None', 
		strSrcTransactionType = 'None',
		intDestId = AdjustmentDetailSource.intInventoryAdjustmentId,
		strDestTransactionNo = COALESCE(Adjustment.strAdjustmentNo, 'Missing Transaction No'),
		'Inventory',
		'Inventory Adjustment'
    FROM dbo.tblICInventoryAdjustment Adjustment
	INNER JOIN dbo.vyuICGetAdjustmentDetailSource AdjustmentDetailSource
	ON Adjustment.intInventoryAdjustmentId = AdjustmentDetailSource.intInventoryAdjustmentId
	WHERE AdjustmentDetailSource.intSourceId IS NOT NULL
	AND Adjustment.intInventoryAdjustmentId = @intAdjustmentId

	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	GOTO Link_Exit
END

IF @ysnIsCreate = 0
BEGIN

	DECLARE @strAdjustmentNumber AS VARCHAR(50) 

	SELECT @strAdjustmentNumber = strAdjustmentNo FROM tblICInventoryAdjustment WHERE intInventoryAdjustmentId = @intAdjustmentId;

	EXEC dbo.uspICDeleteTransactionLinks 
		@intAdjustmentId, 
		@strAdjustmentNumber, 
		'Inventory Adjustment',
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