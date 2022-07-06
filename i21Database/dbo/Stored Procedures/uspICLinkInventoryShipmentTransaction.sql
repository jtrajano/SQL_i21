CREATE PROCEDURE [dbo].[uspICLinkInventoryShipmentTransaction]
	@intShipmentId int,
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
	SELECT DISTINCT * 
	FROM
	(
		SELECT
			strOperation = 'Create',
			intSrcId = 
			CASE 
				WHEN Shipment.intSourceType = 0
					THEN ISNULL(ShipmentItemSource.intOrderId, 0)
				WHEN Shipment.intSourceType = 1
					THEN CASE
						WHEN Shipment.intOrderType = 4 
							THEN CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN ShipmentItemSource.intSourceId
								ELSE 0
							END
						ELSE CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN ShipmentItemSource.intSourceId
								WHEN ShipmentItemSource.intOrderId IS NOT NULL AND ShipmentItemSource.strOrderNumber IS NOT NULL
									THEN ShipmentItemSource.intSourceId
								ELSE 0
							END
					END
				ELSE 0
			END
			,
			strSrcTransactionNo = 
			CASE 
				WHEN Shipment.intSourceType = 0
					THEN ISNULL(ShipmentItemSource.strOrderNumber, 'Missing Transaction No')
				WHEN Shipment.intSourceType = 1
					THEN CASE
						WHEN Shipment.intOrderType = 4 
							THEN CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN ShipmentItemSource.strSourceNumber
								ELSE 'Missing Transaction No'
							END
						ELSE CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN ShipmentItemSource.strSourceNumber
								WHEN ShipmentItemSource.intOrderId IS NOT NULL AND ShipmentItemSource.strOrderNumber IS NOT NULL
									THEN ShipmentItemSource.strOrderNumber
								ELSE 'Missing Transaction No'
							END
					END
				ELSE 'Missing Transaction No'
			END COLLATE Latin1_General_CI_AS
			,
			strSrcModuleName = 
			CASE 
				WHEN Shipment.intSourceType = 0
					THEN CASE
						WHEN Shipment.intOrderType = 0 THEN 'None'
						WHEN Shipment.intOrderType = 1 THEN 'Contract Management'
						WHEN Shipment.intOrderType = 2 THEN 'Sales (A/R)'
						WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
						WHEN Shipment.intOrderType = 4 THEN 'Direct'
						WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
						WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
					END
				WHEN Shipment.intSourceType = 1
					THEN CASE
						WHEN Shipment.intOrderType = 0 THEN 'None'
						WHEN Shipment.intOrderType = 1
							THEN CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN 'Ticket Management'
								WHEN ShipmentItemSource.intOrderId IS NOT NULL AND ShipmentItemSource.strOrderNumber IS NOT NULL
									THEN 'Contract Management'
							END
						WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
						WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
						WHEN Shipment.intOrderType = 4 
							THEN CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN 'Ticket Management'
							END
						WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
						WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
					END
			END COLLATE Latin1_General_CI_AS
			,
			strSrcTransactionType = 
			CASE WHEN Shipment.intSourceType = 0
					THEN CASE
						WHEN Shipment.intOrderType = 0 THEN 'None'
						WHEN Shipment.intOrderType = 1 THEN 'Contract'
						WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
						WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
						WHEN Shipment.intOrderType = 4 THEN 'Direct'
						WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
						WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
					END
				WHEN Shipment.intSourceType = 1
					THEN CASE
						WHEN Shipment.intOrderType = 0 THEN 'None'
						WHEN Shipment.intOrderType = 1
							THEN CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN 'Scale Ticket'
								WHEN ShipmentItemSource.intOrderId IS NOT NULL AND ShipmentItemSource.strOrderNumber IS NOT NULL
									THEN 'Contract'
							END
						WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
						WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
						WHEN Shipment.intOrderType = 4 
							THEN CASE 
								WHEN ShipmentItemSource.intSourceId IS NOT NULL AND ShipmentItemSource.strSourceNumber IS NOT NULL
									THEN 'Scale Ticket'
							END
						WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
						WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
					END
			END COLLATE Latin1_General_CI_AS
			,
			intDestId = Shipment.intInventoryShipmentId,
			strDestTransactionNo = COALESCE(Shipment.strShipmentNumber, 'Missing Transaction No'),
			strDestModuleName = 'Inventory',
			strDestTransactionType ='Inventory Shipment'
		FROM dbo.tblICInventoryShipment Shipment
		INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
		ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		INNER JOIN dbo.vyuICGetShipmentItemSource ShipmentItemSource
		ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemSource.intInventoryShipmentItemId
		AND Shipment.intInventoryShipmentId = @intShipmentId
	) AS ShipmentLinks
	WHERE intSrcId <> 0

	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	GOTO Link_Exit
END

IF @ysnIsCreate = 0
BEGIN

	DECLARE @strShipmentNumber AS VARCHAR(50) 

	SELECT @strShipmentNumber = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId;

	EXEC dbo.uspICDeleteTransactionLinks 
		@intShipmentId, 
		@strShipmentNumber, 
		'Inventory Shipment',
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