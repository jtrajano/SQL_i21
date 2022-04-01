CREATE PROCEDURE [dbo].[uspLGRejectLoadSchedule]
	@intLoadId INT,
	@ysnReject BIT, /* 1 = Reject, 0 = Unreject */
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
			SET intSCompanyLocationId = NULL
				,intSSubLocationId = NULL 
				,intSStorageLocationId = NULL
				,dblDeliveredQuantity = 0
				,dblDeliveredGross = 0
				,dblDeliveredTare = 0
				,dblDeliveredNet = 0
		WHERE intLoadId = @intLoadId

	END
	/* Begin Unreject Process */
	ELSE IF (@ysnReject = 0)
	BEGIN
		--Set Shipment Status to "Rejected"
		UPDATE tblLGLoad SET intShipmentStatus = 6 WHERE intLoadId = @intLoadId

		--S.Company Location moves to P.Company Location and becomes the source location for the transfer
		UPDATE tblLGLoadDetail 
			SET intSCompanyLocationId = intPCompanyLocationId
				,intSSubLocationId = intPSubLocationId 
				,intSStorageLocationId = intPStorageLocationId
				,dblDeliveredQuantity = dblQuantity
				,dblDeliveredGross = dblGross
				,dblDeliveredTare = dblTare
				,dblDeliveredNet = dblNet
		WHERE intLoadId = @intLoadId

		--P.Company Location is reset for user entry (destination location)
		UPDATE tblLGLoadDetail
			SET intPCompanyLocationId = NULL
				,intPSubLocationId = NULL 
				,intPStorageLocationId = NULL
		WHERE intLoadId = @intLoadId
	END
END
GO