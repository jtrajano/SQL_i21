CREATE PROCEDURE [dbo].[uspICTransactionLinkPatcher]
	@ysnWillWipe bit = false
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

--Begin Transaction
BEGIN TRAN TransactionLinkPatch
SAVE TRAN TransactionLinkPatch

BEGIN TRY

--User Define Type Variable
DECLARE @TransactionLink udtICTransactionLinks

--Source Transaction Variables
DECLARE @intSrcId AS INT 
DECLARE @strSrcTransactionNo AS NVARCHAR(100)
DECLARE @strSrcModuleName AS NVARCHAR(100)
DECLARE @strSrcTransactionType AS NVARCHAR(100)

--Destination Transaction Variables
DECLARE @intDestId AS INT
DECLARE @strDestTransactionNo AS NVARCHAR(100)

--Wipe all data 
IF @ysnWillWipe = 1

BEGIN

	--Wipe all Inventory Transaction Links
	--TRUNCATE TABLE dbo.tblICTransactionLinks
	DELETE FROM dbo.tblICTransactionLinks WHERE strSrcModuleName LIKE '%Inventory%' OR strDestModuleName LIKE '%Inventory%'
	DELETE FROM dbo.tblICTransactionNodes WHERE strModuleName LIKE '%Inventory%'

	--Inventory Reciept Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Receipt Data to Transaction Link variable		
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

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Transfer Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Transfer Data to Transaction Link variable		
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

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Shipment Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Shipment Data to Transaction Link variable		
	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT
		'Create',
		intSrcId = ShipmentItemSource.intOrderId, 
		strSrcTransactionNo = COALESCE(ShipmentItemSource.strOrderNumber, 'Missing Transaction No'), 
		strSrcModuleName = 
		CASE 
			WHEN Shipment.intOrderType = 0 THEN 'None'
			WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
			WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
			WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
			WHEN Shipment.intOrderType = 4 THEN 'Direct'
			WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
			WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
		END COLLATE Latin1_General_CI_AS
		, 
		strSrcTransactionType = 
		CASE 
			WHEN Shipment.intOrderType = 0 THEN 'None'
			WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
			WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
			WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
			WHEN Shipment.intOrderType = 4 THEN 'Direct'
			WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
			WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
		END COLLATE Latin1_General_CI_AS
		,
		intDestId = Shipment.intInventoryShipmentId,
		strDestTransactionNo = COALESCE(Shipment.strShipmentNumber, 'Missing Transaction No'),
		'Inventory',
		'Inventory Shipment'
    FROM dbo.tblICInventoryShipment Shipment
	INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
	ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
	INNER JOIN dbo.vyuICGetShipmentItemSource ShipmentItemSource
	ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemSource.intInventoryShipmentItemId
	WHERE ShipmentItemSource.intOrderId IS NOT NULL

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Adjustment Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Adjustment Data to Transaction Link variable		
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

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Receipt Voucher Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Receipt Voucher Data to Transaction Link variable		
	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT
		'Create',
		Receipt.intInventoryReceiptId, 
		COALESCE(Receipt.strReceiptNumber, 'Missing Transaction No'), 
		'Inventory', 
		'Inventory Receipt',
		ReceiptItemVoucherDestination.intDestinationId,
		COALESCE(ReceiptItemVoucherDestination.strDestinationNo, 'Missing Transaction No'),
		'Purchasing',
		'Voucher'
    FROM dbo.tblICInventoryReceipt Receipt
	INNER JOIN dbo.vyuICGetReceiptItemVoucherDestination ReceiptItemVoucherDestination
	ON Receipt.intInventoryReceiptId = ReceiptItemVoucherDestination.intInventoryReceiptId
	WHERE ReceiptItemVoucherDestination.intDestinationId IS NOT NULL

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Successful Exit
	GOTO Patch_Exit
END

--Will not wipe data
IF @ysnWillWipe = 0

BEGIN

	--Inventory Reciept Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Receipt Data to Transaction Link variable		
	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 
		Records.strOperation, -- Operation
		Records.intSrcId, Records.strSrcTransactionNo, Records.strSrcModuleName, Records.strSrcTransactionType, -- Source Transaction
		Records.intDestId, Records.strDestTransactionNo, Records.strDestModuleName, Records.strDestTransactionType	-- Destination Transaction 
	FROM 
	(
		SELECT
		strOperation = 'Create',
		intSrcId = ReceiptItemSource.intOrderId, 
		strSrcTransactionNo = COALESCE(ReceiptItemSource.strOrderNumber, ReceiptItemSource.strSourceNumber, 'Missing Transaction No'), 
		strSrcModuleName = ReceiptItemSource.strSourceType, 
		strSrcTransactionType = ReceiptItemSource.strSourceType,
		intDestId = ReceiptItemSource.intInventoryReceiptId,
		strDestTransactionNo = COALESCE(Receipt.strReceiptNumber, 'Missing Transaction No'),
		strDestModuleName = 'Inventory',
		strDestTransactionType = 'Inventory Receipt'
		FROM dbo.tblICInventoryReceipt Receipt
		INNER JOIN dbo.vyuICGetReceiptItemSource ReceiptItemSource
		ON Receipt.intInventoryReceiptId = ReceiptItemSource.intInventoryReceiptId
		WHERE ReceiptItemSource.intOrderId IS NOT NULL

	) Records
	LEFT JOIN tblICTransactionLinks Links
	ON 
		Links.intDestId = Records.intDestId AND
		Links.strDestTransactionNo = COALESCE(Records.strDestTransactionNo, 'Missing Transaction No') AND
		Links.intSrcId = Records.intSrcId AND
		Links.strSrcTransactionNo = COALESCE(Records.strSrcTransactionNo, 'Missing Transaction No')
	WHERE 
		Links.intDestId IS NULL AND
		(Links.strDestTransactionNo IS NULL OR Links.strDestTransactionNo LIKE '%Missing Transaction No%') AND
		Links.intSrcId IS NULL AND
		(Links.strSrcTransactionNo IS NULL OR Links.strSrcTransactionNo LIKE '%Missing Transaction No%')

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Transfer Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Transfer Data to Transaction Link variable		
	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 
		Records.strOperation, -- Operation
		Records.intSrcId, Records.strSrcTransactionNo, Records.strSrcModuleName, Records.strSrcTransactionType, -- Source Transaction
		Records.intDestId, Records.strDestTransactionNo, Records.strDestModuleName, Records.strDestTransactionType	-- Destination Transaction  
	FROM 
	(
		SELECT
			strOperation = 'Create',
			intSrcId = TransferDetailSource.intSourceId, 
			strSrcTransactionNo = COALESCE(TransferDetailSource.strSourceTransactionNo, 'Missing Transaction No'), 
			strSrcModuleName = TransferDetailSource.strSourceModule, 
			strSrcTransactionType = TransferDetailSource.strSourceScreen,
			intDestId = TransferDetailSource.intInventoryTransferId,
			strDestTransactionNo = COALESCE(Transfer.strTransferNo, 'Missing Transaction No'),
			strDestModuleName = 'Inventory',
			strDestTransactionType = 'Inventory Transfer'
		FROM dbo.tblICInventoryTransfer Transfer
		INNER JOIN dbo.vyuICGetTransferDetailSource TransferDetailSource
		ON Transfer.intInventoryTransferId = TransferDetailSource.intInventoryTransferId
		WHERE TransferDetailSource.intSourceId IS NOT NULL

	) Records
	LEFT JOIN tblICTransactionLinks Links
	ON 
		Links.intDestId = Records.intDestId AND
		Links.strDestTransactionNo = COALESCE(Records.strDestTransactionNo, 'Missing Transaction No') AND
		Links.intSrcId = Records.intSrcId AND
		Links.strSrcTransactionNo = COALESCE(Records.strSrcTransactionNo, 'Missing Transaction No')
	WHERE 
		Links.intDestId IS NULL AND
		(Links.strDestTransactionNo IS NULL OR Links.strDestTransactionNo LIKE '%Missing Transaction No%') AND
		Links.intSrcId IS NULL AND
		(Links.strSrcTransactionNo IS NULL OR Links.strSrcTransactionNo LIKE '%Missing Transaction No%')

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Shipment Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Shipment Data to Transaction Link variable		
	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT
		Records.strOperation, -- Operation
		Records.intSrcId, Records.strSrcTransactionNo, Records.strSrcModuleName, Records.strSrcTransactionType, -- Source Transaction
		Records.intDestId, Records.strDestTransactionNo, Records.strDestModuleName, Records.strDestTransactionType	-- Destination Transaction 
	FROM 
	(
		SELECT
			strOperation = 'Create',
			intSrcId = ShipmentItemSource.intOrderId, 
			strSrcTransactionNo = COALESCE(ShipmentItemSource.strOrderNumber, 'Missing Transaction No'), 
			strSrcModuleName = 
			CASE 
				WHEN Shipment.intOrderType = 0 THEN 'None'
				WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
				WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
				WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
				WHEN Shipment.intOrderType = 4 THEN 'Direct'
				WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
				WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
			END COLLATE Latin1_General_CI_AS
			, 
			strSrcTransactionType = 
			CASE 
				WHEN Shipment.intOrderType = 0 THEN 'None'
				WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
				WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
				WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
				WHEN Shipment.intOrderType = 4 THEN 'Direct'
				WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
				WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
			END COLLATE Latin1_General_CI_AS
			,
			intDestId = Shipment.intInventoryShipmentId,
			strDestTransactionNo = COALESCE(Shipment.strShipmentNumber, 'Missing Transaction No'),
			strDestModuleName = 'Inventory',
			strDestTransactionType = 'Inventory Shipment'
		FROM dbo.tblICInventoryShipment Shipment
		INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
		ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		INNER JOIN dbo.vyuICGetShipmentItemSource ShipmentItemSource
		ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemSource.intInventoryShipmentItemId
		WHERE ShipmentItemSource.intOrderId IS NOT NULL

	) Records
	LEFT JOIN tblICTransactionLinks Links
	ON 
		Links.intDestId = Records.intDestId AND
		Links.strDestTransactionNo = COALESCE(Records.strDestTransactionNo, 'Missing Transaction No') AND
		Links.intSrcId = Records.intSrcId AND
		Links.strSrcTransactionNo = COALESCE(Records.strSrcTransactionNo, 'Missing Transaction No')
	WHERE 
		Links.intDestId IS NULL AND
		(Links.strDestTransactionNo IS NULL OR Links.strDestTransactionNo LIKE '%Missing Transaction No%') AND
		Links.intSrcId IS NULL AND
		(Links.strSrcTransactionNo IS NULL OR Links.strSrcTransactionNo LIKE '%Missing Transaction No%')

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Adjustment Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Adjustment Data to Transaction Link variable		
	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT
		Records.strOperation, -- Operation
		Records.intSrcId, Records.strSrcTransactionNo, Records.strSrcModuleName, Records.strSrcTransactionType, -- Source Transaction
		Records.intDestId, Records.strDestTransactionNo, Records.strDestModuleName, Records.strDestTransactionType	-- Destination Transaction 
	FROM 
	(
		SELECT
			strOperation = 'Create',
			intSrcId = AdjustmentDetailSource.intSourceId, 
			strSrcTransactionNo = COALESCE(AdjustmentDetailSource.strSourceTransactionNo, 'Missing Transaction No'), 
			strSrcModuleName =  'None', 
			strSrcTransactionType = 'None',
			intDestId = AdjustmentDetailSource.intInventoryAdjustmentId,
			strDestTransactionNo = COALESCE(Adjustment.strAdjustmentNo, 'Missing Transaction No'),
			strDestModuleName = 'Inventory',
			strDestTransactionType = 'Inventory Adjustment'
		FROM dbo.tblICInventoryAdjustment Adjustment
		INNER JOIN dbo.vyuICGetAdjustmentDetailSource AdjustmentDetailSource
		ON Adjustment.intInventoryAdjustmentId = AdjustmentDetailSource.intInventoryAdjustmentId
		WHERE AdjustmentDetailSource.intSourceId IS NOT NULL

	) Records
	LEFT JOIN tblICTransactionLinks Links
	ON 
		Links.intDestId = Records.intDestId AND
		Links.strDestTransactionNo = COALESCE(Records.strDestTransactionNo, 'Missing Transaction No') AND
		Links.intSrcId = Records.intSrcId AND
		Links.strSrcTransactionNo = COALESCE(Records.strSrcTransactionNo, 'Missing Transaction No')
	WHERE 
		Links.intDestId IS NULL AND
		(Links.strDestTransactionNo IS NULL OR Links.strDestTransactionNo LIKE '%Missing Transaction No%') AND
		Links.intSrcId IS NULL AND
		(Links.strSrcTransactionNo IS NULL OR Links.strSrcTransactionNo LIKE '%Missing Transaction No%')

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Inventory Receipt Voucher Patch

	DELETE FROM @TransactionLink
	--Insert Inventory Receipt Voucher Data to Transaction Link variable		
	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT 
		Records.strOperation, -- Operation
		Records.intSrcId, Records.strSrcTransactionNo, Records.strSrcModuleName, Records.strSrcTransactionType, -- Source Transaction
		Records.intDestId, Records.strDestTransactionNo, Records.strDestModuleName, Records.strDestTransactionType	-- Destination Transaction  
	FROM 
	(
		SELECT
			strOperation = 'Create',
			intSrcId = Receipt.intInventoryReceiptId, 
			strSrcTransactionNo = COALESCE(Receipt.strReceiptNumber, 'Missing Transaction No'), 
			strSrcModuleName = 'Inventory', 
			strSrcTransactionType = 'Inventory Receipt',
			intDestId = ReceiptItemVoucherDestination.intDestinationId,
			strDestTransactionNo = COALESCE(ReceiptItemVoucherDestination.strDestinationNo, 'Missing Transaction No'),
			strDestModuleName = 'Purchasing',
			strDestTransactionType = 'Voucher'
		FROM dbo.tblICInventoryReceipt Receipt
		INNER JOIN dbo.vyuICGetReceiptItemVoucherDestination ReceiptItemVoucherDestination
		ON Receipt.intInventoryReceiptId = ReceiptItemVoucherDestination.intInventoryReceiptId
		WHERE ReceiptItemVoucherDestination.intDestinationId IS NOT NULL

	) Records
	LEFT JOIN tblICTransactionLinks Links
	ON 
		Links.intDestId = Records.intDestId AND
		Links.strDestTransactionNo = COALESCE(Records.strDestTransactionNo, 'Missing Transaction No') AND
		Links.intSrcId = Records.intSrcId AND
		Links.strSrcTransactionNo = COALESCE(Records.strSrcTransactionNo, 'Missing Transaction No')
	WHERE 
		Links.intDestId IS NULL AND
		(Links.strDestTransactionNo IS NULL OR Links.strDestTransactionNo LIKE '%Missing Transaction No%') AND
		Links.intSrcId IS NULL AND
		(Links.strSrcTransactionNo IS NULL OR Links.strSrcTransactionNo LIKE '%Missing Transaction No%')

	--Execute Add Transaction Link SP
	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	--Successful Exit
	GOTO Patch_Exit
END
END TRY

BEGIN CATCH

	--Rollback Exit
	GOTO Patch_Rollback_Exit

END CATCH

--Rollback Transaction
Patch_Rollback_Exit:
BEGIN 
	ROLLBACK TRAN TransactionLinkPatch
END

Patch_Exit:
BEGIN
	COMMIT TRAN TransactionLinkPatch
END