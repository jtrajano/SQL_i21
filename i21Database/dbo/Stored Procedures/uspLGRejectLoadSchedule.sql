CREATE PROCEDURE [dbo].[uspLGRejectLoadSchedule]
	@intLoadId INT,
	@ysnReject BIT, /* 1 = Reject, 0 = Unreject */
	@intRejectLocationId INT,
	@intEntityUserSecurityId INT
AS
BEGIN
	DECLARE @strLoadNumber NVARCHAR(50)
		,@InTransit_Inbound InTransitTableType
		,@strErrMsg NVARCHAR(MAX)

	/* Validate Parameters */
	IF (@ysnReject IS NULL) RETURN;

	IF NOT EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId)
	BEGIN
		RAISERROR('Load/Shipment Schedule does not exists.', 11, 1);
		RETURN;
	END

	/* Get Load Shipment Details */
	SELECT @strLoadNumber = strLoadNumber FROM tblLGLoad WHERE intLoadId = @intLoadId

	/* Validate Reject/Unreject */
	IF @ysnReject = 1 AND EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND intShipmentStatus = 12)
	BEGIN
		RAISERROR('Load/Shipment Schedule is already Rejected.', 11, 1);
		RETURN;
	END
	IF @ysnReject = 0 AND EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND intShipmentStatus = 6)
	BEGIN
		RAISERROR('Load/Shipment Schedule is already Unrejected.', 11, 1);
		RETURN;
	END

	/* Begin Reject Process */
	IF (@ysnReject = 1)
	BEGIN
		--Set Shipment Status to "Rejected"
		UPDATE tblLGLoad SET intShipmentStatus = 12 WHERE intLoadId = @intLoadId

		--S.Company Location moves to P.Company Location and becomes the source location for the transfer
		UPDATE tblLGLoadDetail 
			SET intPCompanyLocationId = intSCompanyLocationId
				,intPSubLocationId = intSSubLocationId 
				,intPStorageLocationId = intSStorageLocationId
		WHERE intLoadId = @intLoadId

		--S.Company Location is reset for user entry (destination location)
		UPDATE tblLGLoadDetail
			SET intSCompanyLocationId = @intRejectLocationId
				,intSSubLocationId = NULL 
				,intSStorageLocationId = NULL
				,dblDeliveredQuantity = 0
				,dblDeliveredGross = 0
				,dblDeliveredTare = 0
				,dblDeliveredNet = 0
		WHERE intLoadId = @intLoadId

		EXEC dbo.uspSMAuditLog @keyValue = @intLoadId 
			,@screenName = 'Logistics.view.ShipmentSchedule'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Rejected'
			,@changeDescription = ''
			,@fromValue = ''
			,@toValue = ''
	END
	/* Begin Unreject Process */
	ELSE IF (@ysnReject = 0)
	BEGIN
		--Set Shipment Status to "Rejected"
		UPDATE tblLGLoad SET intShipmentStatus = 6 WHERE intLoadId = @intLoadId

		--P.Company Location moves back to S.Company Location, Delivered Quantities are restored
		UPDATE tblLGLoadDetail 
			SET intSCompanyLocationId = intPCompanyLocationId
				,intSSubLocationId = intPSubLocationId 
				,intSStorageLocationId = intPStorageLocationId
				,dblDeliveredQuantity = dblQuantity
				,dblDeliveredGross = dblGross
				,dblDeliveredTare = dblTare
				,dblDeliveredNet = dblNet
		WHERE intLoadId = @intLoadId

		--P.Company Location is reset
		UPDATE tblLGLoadDetail
			SET intPCompanyLocationId = NULL
				,intPSubLocationId = NULL 
				,intPStorageLocationId = NULL
		WHERE intLoadId = @intLoadId

		EXEC dbo.uspSMAuditLog @keyValue = @intLoadId 
			,@screenName = 'Logistics.view.ShipmentSchedule'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Unrejected'
			,@changeDescription = ''
			,@fromValue = ''
			,@toValue = ''
	END

	INSERT INTO @InTransit_Inbound (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dblQty]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intFOBPointId]
	)
	SELECT	[intItemId]				= d.intItemId
			,[intItemLocationId]	= itemLocation.intItemLocationId
			,[intItemUOMId]			= d.intItemUOMId
			,[intLotId]				= l.intLotId
			,[intSubLocationId]		= ISNULL(wh.intSubLocationId, d.intSSubLocationId)
			,[intStorageLocationId]	= ISNULL(wh.intStorageLocationId, d.intSStorageLocationId)
			,[dblQty]				= ISNULL(l.dblLotQuantity, d.dblQuantity) * CASE WHEN @ysnReject = 1 THEN 1 ELSE -1 END 
			,[intTransactionId]		= h.intLoadId
			,[strTransactionId]		= h.strLoadNumber
			,[intTransactionTypeId] = 12 
			,[intFOBPointId]		= 2
	FROM dbo.tblLGLoad h
		INNER JOIN dbo.tblLGLoadDetail d ON h.intLoadId = d.intLoadId
		INNER JOIN dbo.tblLGLoadDetailLot l ON l.intLoadDetailId = d.intLoadDetailId
		OUTER APPLY (
			SELECT TOP 1 clsl.intCompanyLocationId, lw.intSubLocationId, lw.intStorageLocationId FROM tblLGLoadWarehouse lw 
			INNER JOIN tblSMCompanyLocationSubLocation clsl ON lw.intSubLocationId = clsl.intCompanyLocationSubLocationId
			WHERE lw.intLoadId = h.intLoadId) wh
		INNER JOIN dbo.tblICItem Item ON Item.intItemId = d.intItemId
		INNER JOIN dbo.tblICItemLocation itemLocation 
			ON itemLocation.intItemId = d.intItemId
			AND itemLocation.intLocationId = @intRejectLocationId
	WHERE h.intLoadId = @intLoadId
		AND Item.strType <> 'Comment'

	EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransit_Inbound
END
GO