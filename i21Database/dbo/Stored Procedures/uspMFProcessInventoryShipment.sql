﻿CREATE PROCEDURE [dbo].[uspMFProcessInventoryShipment] 
(
	@intSalesOrderId   INT
  , @intUserId		   INT
  , @strShipmentNumber NVARCHAR(50) OUTPUT
)
AS
BEGIN TRY
	DECLARE @intTransactionCount	INT
		  , @intInventoryShipmentId INT
		  , @strErrorMessage		NVARCHAR(MAX)
		  , @intSalesOrderDetailId	INT = NULL
		  , @dblQuantity			NUMERIC(18, 6) = 0
		  , @ShipmentStagingTable ShipmentStagingTable
		  , @OtherCharges ShipmentChargeStagingTable

	IF NOT EXISTS (SELECT * FROM dbo.tblMFSODetail WHERE intSalesOrderId = @intSalesOrderId AND ysnProcessed = 0)
	BEGIN
		RAISERROR ('There is no record to process for the selected SO.', 16, 1)
		RETURN
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @intInventoryShipmentId = NULL

	SELECT @strErrorMessage = ''

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult'))
	BEGIN
		CREATE TABLE #tmpAddItemShipmentResult (intSourceId				INT
											  , intInventoryShipmentId  INT)
	END

	INSERT INTO @ShipmentStagingTable (
		intOrderType
		,intSourceType
		,intEntityCustomerId
		,dtmShipDate
		,intShipFromLocationId
		,intShipToLocationId
		,intFreightTermId
		,strSourceScreenName
		,strBOLNumber
		,strReferenceNumber
		,intItemId
		,intOwnershipType
		,dblQuantity
		,intItemUOMId
		,intOrderId
		,intLineNo
		,intWeightUOMId
		,dblUnitPrice
		,intCurrencyId
		,intForexRateTypeId
		,dblForexRate
		,dtmRequestedArrivalDate
		,intShipViaId
		)
	SELECT DISTINCT intOrderType = 2 --Sales Order
		,intSourceType = 0
		,intEntityCustomerId = EL.intEntityId
		,dtmShipDate = S.dtmDate
		,intShipFromLocationId = IL.intLocationId
		,intShipToLocationId = EL.intEntityLocationId
		,intFreightTermId = S.intFreightTermId
		,strSourceScreenName = 'Scanner'
		,strBOLNumber = S.strBOLNumber
		,strReferenceNumber = S.strPONumber
		,intItemId = I.intItemId
		,intOwnershipType = 1
		,dblQuantity = D.dblQuantity
		,intItemUOMId = IU.intItemUOMId
		,intOrderId = S.intSalesOrderId
		,intLineNo = D.intSalesOrderDetailId
		,intWeightUOMId = NULL
		,dblUnitPrice = SD.dblUnitPrice
		,intCurrencyId = S.intCurrencyId
		,intForexRateTypeId = NULL
		,dblForexRate = NULL
		,dtmRequestedArrivalDate = S.dtmDate
		,intShipViaId = S.intShipViaId
	FROM tblMFSODetail D
	JOIN dbo.tblSOSalesOrderDetail SD ON SD.intSalesOrderDetailId = D.intSalesOrderDetailId
	JOIN dbo.tblSOSalesOrder S ON S.intSalesOrderId = SD.intSalesOrderId
	JOIN tblICItem I ON I.intItemId = D.intItemId
	JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
		AND IL.intLocationId = S.intCompanyLocationId
	JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = S.intShipToLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = D.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE D.intSalesOrderId = @intSalesOrderId
		AND SD.dblQtyOrdered != SD.dblQtyShipped
		AND I.strType IN (
			'Inventory'
			,'Non-Inventory'
			,'Finished Good'
			,'Raw Material'
			)
	ORDER BY I.intItemId

	IF EXISTS (SELECT * FROM @ShipmentStagingTable)
	BEGIN
		EXEC dbo.uspICAddItemShipment @Items = @ShipmentStagingTable
			,@Charges = @OtherCharges
			,@intUserId = @intUserId;

		SELECT TOP 1 @intInventoryShipmentId = intInventoryShipmentId
		FROM #tmpAddItemShipmentResult

		SELECT @strShipmentNumber = strShipmentNumber 
		FROM tblICInventoryShipment
		WHERE intInventoryShipmentId = @intInventoryShipmentId

		UPDATE tblMFSODetail
		SET ysnProcessed = 1
		WHERE intSalesOrderId = @intSalesOrderId

		DECLARE loopMFSalesOrderDetail CURSOR LOCAL FAST_FORWARD FOR 
		SELECT intSalesOrderDetailId
			 , dblQuantity 
		FROM tblMFSODetail
		WHERE ISNULL(dblQuantity, 0) <> 0 AND intSalesOrderId = @intSalesOrderId

		OPEN loopMFSalesOrderDetail;
		
		-- Initial fetch attempt
		FETCH NEXT FROM loopMFSalesOrderDetail INTO @intSalesOrderDetailId
																, @dblQuantity;

		-----------------------------------------------------------------------------------------------------------------------------
		-- Start of the loop for the integration sp. 
		-----------------------------------------------------------------------------------------------------------------------------
		WHILE @@FETCH_STATUS = 0
		BEGIN 		
			EXEC [dbo].[uspSOUpdateOrderShipmentStatus]
				  @intTransactionId			= NULL
				, @strTransactionType		= 'Inventory'
				, @ysnForDelete				= 0
				, @intSalesOrderDetailId	= @intSalesOrderDetailId
				, @dblQuantity				= @dblQuantity
				, @intItemUOMId				= NULL 

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopMFSalesOrderDetail INTO @intSalesOrderDetailId
													  , @dblQuantity
		END;

		DELETE
		FROM #tmpAddItemShipmentResult
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrorMessage = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrorMessage
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH