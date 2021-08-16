﻿CREATE PROCEDURE uspMFProcessWorkOrder (
	@intProducedItemId INT
	,@intUserId INT
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @dtmProductionDate DATETIME
		,@strProduceXml NVARCHAR(MAX) = ''
		,@strConsumeXml NVARCHAR(MAX) = ''
		,@dblProducedQuantity NUMERIC(18, 6)
		,@intProducedItemUOMId INT
		,@intItemFactoryId INT
		,@intManufacturingCellId INT
		,@intTransferToStorageLocationId INT
		,@intDetailId INT
		,@intConsumedItemId INT
		,@dblConsumedQuantity NUMERIC(18, 6)
		,@intConsumedItemUOMId INT
		,@intStorageLocationId INT
		,@intLotId INT
		,@strLotNumber NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@intSubLocationId INT

	SELECT @dtmProductionDate = GETDATE()

	SELECT @intProducedItemId = intItemId
		,@dblProducedQuantity = dblQuantity
		,@intProducedItemUOMId = intItemUOMId
		,@intTransferToStorageLocationId = intStorageLocationId
	FROM tblMFWODetail
	WHERE intItemId = @intProducedItemId
		AND ysnProcessed = 0
		AND intTransactionTypeId = 9

	SELECT @intItemFactoryId = intItemFactoryId
	FROM tblICItemFactory
	WHERE intItemId = @intProducedItemId

	SELECT @intManufacturingCellId = intManufacturingCellId
	FROM tblICItemFactoryManufacturingCell
	WHERE intItemFactoryId = @intItemFactoryId

	SELECT @strProduceXml = '<root>'

	SELECT @strProduceXml = @strProduceXml + '<intWorkOrderId>0</intWorkOrderId>'

	SELECT @strProduceXml = @strProduceXml + '<intItemId>' + convert(VARCHAR, @intProducedItemId) + '</intItemId>'

	SELECT @strProduceXml = @strProduceXml + '<intItemUOMId>' + convert(VARCHAR, @intProducedItemUOMId) + '</intItemUOMId>'

	SELECT @strProduceXml = @strProduceXml + '<dblQtyToProduce>' + convert(VARCHAR, @dblProducedQuantity) + '</dblQtyToProduce>'

	SELECT @strProduceXml = @strProduceXml + '<dblIssuedQuantity>0</dblIssuedQuantity>'

	SELECT @strProduceXml = @strProduceXml + '<intItemIssuedUOMId>0</intItemIssuedUOMId>'

	SELECT @strProduceXml = @strProduceXml + '<dblWeightPerUnit>0</dblWeightPerUnit>'

	SELECT @strProduceXml = @strProduceXml + '<intManufacturingCellId>' + convert(VARCHAR, @intManufacturingCellId) + '</intManufacturingCellId>'

	SELECT @strProduceXml = @strProduceXml + '<dblPlannedQuantity>' + convert(VARCHAR, 10) + '</dblPlannedQuantity>'

	SELECT @strProduceXml = @strProduceXml + '<intLocationId>' + convert(VARCHAR, @intLocationId) + '</intLocationId>'

	SELECT @strProduceXml = @strProduceXml + '<intStorageLocationId>' + convert(VARCHAR, @intTransferToStorageLocationId) + '</intStorageLocationId>'

	SELECT @strProduceXml = @strProduceXml + '<intUserId>' + convert(VARCHAR, @intUserId) + '</intUserId>'

	SELECT @strProduceXml = @strProduceXml + '<dtmProductionDate>' + convert(VARCHAR, @dtmProductionDate) + '</dtmProductionDate>'

	SELECT @intDetailId = MIN(intDetailId)
	FROM tblMFWODetail
	WHERE intItemId = @intProducedItemId
		AND ysnProcessed = 0
		AND intTransactionTypeId = 8

	WHILE @intDetailId IS NOT NULL
	BEGIN
		SELECT @intConsumedItemId = NULL
			,@dblConsumedQuantity = NULL
			,@intConsumedItemUOMId = NULL
			,@intStorageLocationId = NULL
			,@intSubLocationId = NULL

		SELECT @intConsumedItemId = intItemId
			,@dblConsumedQuantity = dblQuantity
			,@intConsumedItemUOMId = intItemUOMId
			,@intStorageLocationId = intStorageLocationId
			,@intSubLocationId = intSubLocationId
		FROM tblMFWODetail
		WHERE intDetailId = @intDetailId

		SELECT @strConsumeXml = @strConsumeXml + '<lot>'

		SELECT @strConsumeXml = @strConsumeXml + '<intWorkOrderId>0</intWorkOrderId>'

		SELECT @strConsumeXml = @strConsumeXml + '<intWorkOrderConsumedLotId>0</intWorkOrderConsumedLotId>'

		SELECT @strConsumeXml = @strConsumeXml + '<intLotId>0</intLotId>'

		SELECT @strConsumeXml = @strConsumeXml + '<intItemId>' + convert(VARCHAR, @intConsumedItemId) + '</intItemId>'

		SELECT @strConsumeXml = @strConsumeXml + '<dblQty>' + convert(VARCHAR, @dblConsumedQuantity) + '</dblQty>'

		SELECT @strConsumeXml = @strConsumeXml + '<intItemUOMId>' + convert(VARCHAR, @intConsumedItemUOMId) + '</intItemUOMId>'

		SELECT @strConsumeXml = @strConsumeXml + '<dblIssuedQuantity>' + convert(VARCHAR, @dblConsumedQuantity) + '</dblIssuedQuantity>'

		SELECT @strConsumeXml = @strConsumeXml + '<intItemIssuedUOMId>' + convert(VARCHAR, @intConsumedItemUOMId) + '</intItemIssuedUOMId>'

		SELECT @strConsumeXml = @strConsumeXml + '<intSubLocationId>' + convert(VARCHAR, @intSubLocationId) + '</intSubLocationId>'

		SELECT @strConsumeXml = @strConsumeXml + '<intStorageLocationId>' + convert(VARCHAR, @intStorageLocationId) + '</intStorageLocationId>'

		SELECT @strConsumeXml = @strConsumeXml + '</lot>'

		SELECT @intDetailId = MIN(intDetailId)
		FROM tblMFWODetail
		WHERE intItemId = @intProducedItemId
			AND ysnProcessed = 0
			AND intTransactionTypeId = 8
			AND intDetailId > @intDetailId
	END

	SELECT @strProduceXml = @strProduceXml + '</root>'

	EXEC [dbo].[uspMFCompleteBlendSheet] @strXml = @strProduceXml
		,@intLotId = @intLotId OUT
		,@strLotNumber = @strLotNumber OUT
		,@intLoadDistributionDetailId = NULL
		,@ysnRecap = 0
		,@strBatchId = @strBatchId OUT
		,@ysnAutoBlend = 0
END