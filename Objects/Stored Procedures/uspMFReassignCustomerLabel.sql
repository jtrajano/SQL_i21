CREATE PROCEDURE uspMFReassignCustomerLabel (@intInventoryShipmentId INT)
AS
DECLARE @intInventoryShipmentItemId INT
	,@intLotId INT
	,@dblQuantity NUMERIC(38, 20)
	,@dblQuantityShipped NUMERIC(38, 20)
	,@intOrderHeaderId INT
	,@strShipmentNumber NVARCHAR(50)
	,@intCaseLabelCount INT
	,@intItemId INT
	,@intOrderDetailId INT
	,@intInventoryShipmentItemLotId INT
	,@intOrderManifestId INT
	,@intUserId INT
	,@intShort INT
	,@intOrderManifestLabelId INT
	,@intEntityCustomerId INT
	,@intCustomerLabelTypeId INT
DECLARE @tblOrderManifestLabel TABLE (intOrderManifestLabelId INT)
DECLARE @tblInventoryShipmentItem TABLE (
	intInventoryShipmentItemId INT
	,intItemId INT
	)
DECLARE @tblInventoryShipmentItemLot TABLE (
	intInventoryShipmentItemLotId INT
	,intLotId INT
	,dblQuantityShipped NUMERIC(38, 20)
	)

IF EXISTS (
		SELECT 1
		FROM tblSMUserSecurity
		WHERE strUserName = 'irelyadmin'
		)
	SELECT TOP 1 @intUserId = intEntityId
	FROM tblSMUserSecurity
	WHERE strUserName = 'irelyadmin'
ELSE
	SELECT TOP 1 @intUserId = intEntityId
	FROM tblSMUserSecurity

INSERT INTO @tblInventoryShipmentItem (
	intInventoryShipmentItemId
	,intItemId
	)
SELECT intInventoryShipmentItemId
	,intItemId
FROM tblICInventoryShipmentItem
WHERE intInventoryShipmentId = @intInventoryShipmentId

SELECT @strShipmentNumber = strShipmentNumber
	,@intEntityCustomerId = intEntityCustomerId
FROM tblICInventoryShipment
WHERE intInventoryShipmentId = @intInventoryShipmentId

SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
FROM tblMFItemOwner
WHERE intOwnerId = @intEntityCustomerId

SELECT @intOrderHeaderId = intOrderHeaderId
FROM tblMFOrderHeader
WHERE strReferenceNo = @strShipmentNumber

SELECT @intInventoryShipmentItemId = MIN(intInventoryShipmentItemId)
FROM @tblInventoryShipmentItem

WHILE @intInventoryShipmentItemId IS NOT NULL
BEGIN
	SELECT @intItemId = intItemId
	FROM @tblInventoryShipmentItem
	WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId

	DELETE
	FROM @tblInventoryShipmentItemLot

	INSERT INTO @tblInventoryShipmentItemLot (
		intInventoryShipmentItemLotId
		,intLotId
		,dblQuantityShipped
		)
	SELECT intInventoryShipmentItemLotId
		,intLotId
		,dblQuantityShipped
	FROM tblICInventoryShipmentItemLot
	WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId

	SELECT @intOrderDetailId = NULL

	SELECT @intOrderDetailId = intOrderDetailId
	FROM tblMFOrderDetail
	WHERE intOrderHeaderId = @intOrderHeaderId
		AND intItemId = @intItemId

	DELETE
	FROM @tblOrderManifestLabel

	INSERT INTO @tblOrderManifestLabel
	SELECT OML.intOrderManifestLabelId
	FROM tblMFOrderManifest OM
	JOIN tblMFOrderManifestLabel OML ON OM.intOrderManifestId = OML.intOrderManifestId
	WHERE intOrderHeaderId = @intOrderHeaderId
		AND OM.intOrderDetailId = @intOrderDetailId
		AND OML.ysnDeleted = 0

	IF NOT EXISTS (
			SELECT *
			FROM @tblOrderManifestLabel
			)
	BEGIN
		SELECT @intInventoryShipmentItemId = MIN(intInventoryShipmentItemId)
		FROM @tblInventoryShipmentItem
		WHERE intInventoryShipmentItemId > @intInventoryShipmentItemId

		CONTINUE
	END

	SELECT @intInventoryShipmentItemLotId = MIN(intInventoryShipmentItemLotId)
	FROM @tblInventoryShipmentItemLot

	WHILE @intInventoryShipmentItemLotId IS NOT NULL
	BEGIN
		SELECT @intLotId = NULL
			,@dblQuantityShipped = NULL

		SELECT @intLotId = intLotId
			,@dblQuantityShipped = dblQuantityShipped
		FROM @tblInventoryShipmentItemLot
		WHERE intInventoryShipmentItemLotId = @intInventoryShipmentItemLotId

		SELECT @intCaseLabelCount = 0

		SELECT @intCaseLabelCount = Count(*)
		FROM tblMFOrderManifest OM
		JOIN tblMFOrderManifestLabel OML ON OM.intOrderManifestId = OML.intOrderManifestId
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intLotId = @intLotId
			AND OML.ysnDeleted = 0

		IF (
				@dblQuantityShipped = @intCaseLabelCount
				AND @intCustomerLabelTypeId = 2
				)
			OR (
				@intCaseLabelCount > 0
				AND @intCustomerLabelTypeId <> 2
				)
		BEGIN
			SELECT @intInventoryShipmentItemLotId = MIN(intInventoryShipmentItemLotId)
			FROM @tblInventoryShipmentItemLot
			WHERE intInventoryShipmentItemLotId > @intInventoryShipmentItemLotId

			CONTINUE
		END
		ELSE
		BEGIN
			IF @intCaseLabelCount > 0
			BEGIN
				SELECT @intOrderManifestId = OM.intOrderManifestId
				FROM tblMFOrderManifest OM
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intOrderDetailId = @intOrderDetailId
					AND intLotId = @intLotId
			END
			ELSE
			BEGIN
				INSERT INTO tblMFOrderManifest (
					intConcurrencyId
					,intOrderDetailId
					,intOrderHeaderId
					,intLotId
					,strManifestItemNote
					,intLastUpdateId
					,dtmLastUpdateOn
					)
				SELECT 1
					,@intOrderDetailId
					,@intOrderHeaderId
					,@intLotId
					,''
					,@intUserId
					,GETDATE()

				SELECT @intOrderManifestId = SCOPE_IDENTITY()
			END

			SELECT @intShort = 0

			SELECT @intShort = CASE 
					WHEN @intCustomerLabelTypeId = 2
						THEN @dblQuantityShipped
					ELSE 1
					END

			WHILE @intShort > 0
			BEGIN
				SELECT @intOrderManifestLabelId = NULL

				SELECT TOP 1 @intOrderManifestLabelId = intOrderManifestLabelId
				FROM @tblOrderManifestLabel

				IF @intOrderManifestLabelId IS NOT NULL
				BEGIN
					UPDATE tblMFOrderManifestLabel
					SET intOrderManifestId = @intOrderManifestId
					WHERE intOrderManifestLabelId = @intOrderManifestLabelId

					DELETE
					FROM @tblOrderManifestLabel
					WHERE intOrderManifestLabelId = @intOrderManifestLabelId
				END

				SELECT @intShort = @intShort - 1
			END
		END

		SELECT @intInventoryShipmentItemLotId = MIN(intInventoryShipmentItemLotId)
		FROM @tblInventoryShipmentItemLot
		WHERE intInventoryShipmentItemLotId > @intInventoryShipmentItemLotId
	END

	SELECT @intInventoryShipmentItemId = MIN(intInventoryShipmentItemId)
	FROM @tblInventoryShipmentItem
	WHERE intInventoryShipmentItemId > @intInventoryShipmentItemId
END
