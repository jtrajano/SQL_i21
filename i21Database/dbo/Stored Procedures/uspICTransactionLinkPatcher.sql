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

DECLARE @transactionCursor CURSOR

--Wipe all data 
IF @ysnWillWipe = 1

BEGIN

	--Wipe all Inventory Transaction Links
	TRUNCATE TABLE dbo.tblICTransactionLinks
	DELETE FROM dbo.tblICTransactionLinks WHERE strSrcModuleName LIKE '%Inventory%' OR strDestModuleName LIKE '%Inventory%'

	--Inventory Reciept Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT
		intDestId = ReceiptItemSource.intInventoryReceiptId,
		strDestTransactionNo = Receipt.strReceiptNumber,
		intSrcId = ReceiptItemSource.intOrderId, 
		strSrcTransactionNo = COALESCE(ReceiptItemSource.strOrderNumber, ReceiptItemSource.strSourceNumber), 
		strSrcModuleName = ReceiptItemSource.strSourceType, 
		strSrcTransactionType = ReceiptItemSource.strSourceType
    FROM dbo.tblICInventoryReceipt Receipt
	INNER JOIN dbo.vyuICGetReceiptItemSource ReceiptItemSource
	ON Receipt.intInventoryReceiptId = ReceiptItemSource.intInventoryReceiptId
	WHERE ReceiptItemSource.intOrderId IS NOT NULL

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Receipt'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Transfer Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT
		intDestId = TransferDetailSource.intInventoryTransferId,
		strDestTransactionNo = Transfer.strTransferNo,
		intSrcId = TransferDetailSource.intSourceId, 
		strSrcTransactionNo = TransferDetailSource.strSourceTransactionNo, 
		strSrcModuleName = TransferDetailSource.strSourceModule, 
		strSrcTransactionType = TransferDetailSource.strSourceScreen
    FROM dbo.tblICInventoryTransfer Transfer
	INNER JOIN dbo.vyuICGetTransferDetailSource TransferDetailSource
	ON Transfer.intInventoryTransferId = TransferDetailSource.intInventoryTransferId
	WHERE TransferDetailSource.intSourceId IS NOT NULL

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Transfer'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Shipment Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT
		intDestId = Shipment.intInventoryShipmentId,
		strDestTransactionNo = Shipment.strShipmentNumber,
		intSrcId = ShipmentItemSource.intOrderId, 
		strSrcTransactionNo = ShipmentItemSource.strOrderNumber, 
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
    FROM dbo.tblICInventoryShipment Shipment
	INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
	ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
	INNER JOIN dbo.vyuICGetShipmentItemSource ShipmentItemSource
	ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemSource.intInventoryShipmentItemId
	WHERE ShipmentItemSource.intOrderId IS NOT NULL

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Shipment'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Adjustment Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT
		intDestId = AdjustmentDetailSource.intInventoryAdjustmentId,
		strDestTransactionNo = Adjustment.strAdjustmentNo,
		intSrcId = AdjustmentDetailSource.intSourceId, 
		strSrcTransactionNo = AdjustmentDetailSource.strSourceTransactionNo, 
		strSrcModuleName =  'None', 
		strSrcTransactionType = 'None'
    FROM dbo.tblICInventoryAdjustment Adjustment
	INNER JOIN dbo.vyuICGetAdjustmentDetailSource AdjustmentDetailSource
	ON Adjustment.intInventoryAdjustmentId = AdjustmentDetailSource.intInventoryAdjustmentId
	WHERE AdjustmentDetailSource.intSourceId IS NOT NULL

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Adjustment'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Receipt Voucher Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT
		intDestId = ReceiptItemVoucherDestination.intDestinationId,
		strDestTransactionNo = ReceiptItemVoucherDestination.strDestinationNo,
		intSrcId = Receipt.intInventoryReceiptId, 
		strSrcTransactionNo = Receipt.strReceiptNumber, 
		strSrcModuleName =  'Inventory', 
		strSrcTransactionType = 'Inventory Receipt'
    FROM dbo.tblICInventoryReceipt Receipt
	INNER JOIN dbo.vyuICGetReceiptItemVoucherDestination ReceiptItemVoucherDestination
	ON Receipt.intInventoryReceiptId = ReceiptItemVoucherDestination.intInventoryReceiptId
	WHERE ReceiptItemVoucherDestination.intDestinationId IS NOT NULL

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, COALESCE(@strDestTransactionNo, 'Missing Transaction No'), 'Purchasing', 'Voucher'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	GOTO Patch_Exit
END

--Will not wipe data
IF @ysnWillWipe = 0

BEGIN

	--Inventory Reciept Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT * 
	FROM 
	(
		SELECT intDestId = ReceiptItemSource.intInventoryReceiptId,
			strDestTransactionNo = Receipt.strReceiptNumber,
			intSrcId = ReceiptItemSource.intOrderId, 
			strSrcTransactionNo = COALESCE(ReceiptItemSource.strOrderNumber, ReceiptItemSource.strSourceNumber), 
			strSrcModuleName = ReceiptItemSource.strSourceType, 
			strSrcTransactionType = ReceiptItemSource.strSourceType
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

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Receipt'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Transfer Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT * 
	FROM 
	(
		SELECT
			intDestId = TransferDetailSource.intInventoryTransferId,
			strDestTransactionNo = Transfer.strTransferNo,
			intSrcId = TransferDetailSource.intSourceId, 
			strSrcTransactionNo = TransferDetailSource.strSourceTransactionNo, 
			strSrcModuleName = TransferDetailSource.strSourceModule, 
			strSrcTransactionType = TransferDetailSource.strSourceScreen
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

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Receipt'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Shipment Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT * 
	FROM 
	(
		SELECT
			intDestId = Shipment.intInventoryShipmentId,
			strDestTransactionNo = Shipment.strShipmentNumber,
			intSrcId = ShipmentItemSource.intOrderId, 
			strSrcTransactionNo = ShipmentItemSource.strOrderNumber, 
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

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Receipt'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Adjustment Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT * 
	FROM 
	(
		SELECT
			intDestId = AdjustmentDetailSource.intInventoryAdjustmentId,
			strDestTransactionNo = Adjustment.strAdjustmentNo,
			intSrcId = AdjustmentDetailSource.intSourceId, 
			strSrcTransactionNo = AdjustmentDetailSource.strSourceTransactionNo, 
			strSrcModuleName =  'None', 
			strSrcTransactionType = 'None'
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

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Receipt'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	--Inventory Receipt Voucher Patch

	--Set Transaction Cursor
	SET @transactionCursor = CURSOR FOR 
	SELECT * 
	FROM 
	(
		SELECT
			intDestId = ReceiptItemVoucherDestination.intDestinationId,
			strDestTransactionNo = ReceiptItemVoucherDestination.strDestinationNo,
			intSrcId = Receipt.intInventoryReceiptId, 
			strSrcTransactionNo = Receipt.strReceiptNumber, 
			strSrcModuleName =  'Inventory', 
			strSrcTransactionType = 'Inventory Receipt'
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

	--Open Transaction Cursor
	OPEN @transactionCursor

	--Fetch Data from Cursor
	FETCH NEXT FROM @transactionCursor INTO 
	@intDestId, @strDestTransactionNo, 
	@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType

	--Begin Inventory Receipt Cursor Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Insert Cursor Data to Transaction Link variable
		INSERT INTO @TransactionLink (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		VALUES (
			'Create',
			@intSrcId, COALESCE(@strSrcTransactionNo, 'Missing Transaction No'), @strSrcModuleName, @strSrcTransactionType,
			@intDestId, @strDestTransactionNo, 'Inventory', 'Inventory Receipt'
		)

		--Execute Add Transaction Link SP
		EXEC dbo.uspICAddTransactionLinks @TransactionLink

		FETCH NEXT FROM @transactionCursor INTO 
		@intDestId, @strDestTransactionNo, 
		@intSrcId, @strSrcTransactionNo, @strSrcModuleName, @strSrcTransactionType
	END

	--Close and Deallocate Cursor
	CLOSE @transactionCursor
	DEALLOCATE @transactionCursor

	GOTO Patch_Exit
END
END TRY

BEGIN CATCH

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