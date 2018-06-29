CREATE PROCEDURE [dbo].[uspWHPickFlexibilityValidation] 
				@strTaskNo NVARCHAR(32), 
				@strContainerNo NVARCHAR(32), 
				@dblTaskQty DECIMAL(24, 10), 
				@strSKUNo NVARCHAR(32), 
				@intUserId NVARCHAR(100), 
				@intAddressId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intContainerId INT
	DECLARE @intOrderHeaderId INT
	DECLARE @intTaskId INT
	DECLARE @intSKUId INT
	DECLARE @dblSKUQty DECIMAL(24, 10)
	DECLARE @intNewTaskTypeId INT
	DECLARE @intAssigneeId INT
	DECLARE @dblOrderLineItemQty DECIMAL(24, 10)
	DECLARE @dblOrderAllotedQty DECIMAL(24, 10)
	DECLARE @dblOrderPickedQty DECIMAL(24, 10)
	DECLARE @intItemId INT
	DECLARE @intStagingLocationId INT
	DECLARE @intContainerLocationId INT
	DECLARE @intTaskTypeId INT
	DECLARE @strLotCode NVARCHAR(32)
	DECLARE @intOrderTypeId INT
	DECLARE @intSKUStatusId INT

	SET @strErrMsg = ''
	SET @intOrderHeaderId = 0

	DECLARE @ysnIsSKUNoEmpty BIT

	SELECT @ysnIsSKUNoEmpty = 0

	IF @strSKUNo <> ''
	BEGIN
		SELECT @dblSKUQty = dblQty, @intSKUId = intSKUId, @intItemId = intItemId, @strLotCode = strLotCode, @intSKUStatusId = intSKUStatusId
		FROM tblWHSKU
		WHERE strSKUNo = @strSKUNo
	END
	ELSE
	BEGIN
		SELECT @ysnIsSKUNoEmpty = 1

		SELECT @dblSKUQty = dblQty, @intSKUId = intSKUId, @intItemId = intItemId, @strLotCode = strLotCode, @intSKUStatusId = intSKUStatusId, @strSKUNo = strSKUNo
		FROM tblWHSKU s
		JOIN tblWHContainerc ON c.intContainerId = S.intContainerId
		WHERE c.strContainerNo = @strContainerNo
	END

	SELECT @intOrderHeaderId = intOrderHeaderId, @intStagingLocationId = intStagingLocationId, @intOrderTypeId = intOrderTypeId
	FROM tblWHOrderHeader
	WHERE strBOLNo = @strTaskNo

	SELECT @intContainerId = intContainerId
	FROM tblWHContainer
	WHERE strContainerNo = @strContainerNo

	SELECT @intTaskId = intTaskId, @intTaskTypeId = intTaskTypeId
	FROM tblWHTask
	WHERE strTaskNo = @strTaskNo
		AND intFromContainerId = @intContainerId

	DECLARE @strOrderType NVARCHAR(50)

	SELECT @strOrderType = OT.strInternalCode
	FROM dbo.tblWHOrderType OT
	WHERE intOrderTypeId = @intOrderTypeId

	IF (
			SELECT COUNT(*)
			FROM tblWHOrderLineItem
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intItemId = @intItemId
			) > 1
	BEGIN
		SELECT @dblOrderPickedQty = SUM(t.dblQty)
		FROM tblWHTask t
		JOIN tblWHOrderHeader oh ON oh.strBOLNo = t.strTaskNo
		JOIN tblWHSKU s ON s.intSKUId = t.intSKUId
		JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
		JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId
		JOIN tblICStorageUnitType ut ON ut.intStorageUnitTypeId = u.intStorageUnitTypeId
		WHERE t.strTaskNo = @strTaskNo
			AND s.intItemId = @intItemId
			AND (
				ut.strStorageUnitType IN ('WH_Transport')
				OR t.intTaskTypeId = 3
				)
			AND s.strLotCode = @strLotCode
	END
	ELSE
	BEGIN
		SELECT @dblOrderPickedQty = SUM(t.dblQty)
		FROM tblWHTask t
		JOIN tblWHOrderHeader oh ON oh.strBOLNo = t.strTaskNo
		JOIN tblWHSKU s ON s.intSKUId = t.intSKUId
		JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
		JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId
		WHERE t.strTaskNo = @strTaskNo
			AND s.intItemId = @intItemId
			AND (
				u.intStorageUnitTypeId IN (1000010)
				OR t.intTaskTypeId = 3
				)
	END

	SELECT @intContainerLocationId = intStorageLocationId
	FROM tblWHContainer
	WHERE strContainerNo = @strContainerNo

	IF ISNULL(@strContainerNo, '') = ''
	BEGIN
		RAISERROR ('PLEASE SELECT A VALID CONTAINER.', 16, 1)
	END

	IF @intContainerLocationId = @intStagingLocationId
	BEGIN
		RAISERROR ('The container you are trying to stage is already staged. Please select another container.', 16, 1)
	END

	IF @strOrderType = 'PS'
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM tblWHOrderLineItem
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intItemId = (
						SELECT intItemId
						FROM tblWHSKU
						WHERE strSKUNo = @strSKUNo
						)
					AND ISNULL(strLotAlias, '') = (
						CASE 
							WHEN ISNULL(strLotAlias, '') <> ''
								THEN @strLotCode
							ELSE ISNULL(strLotAlias, '')
							END
						)
				)
		BEGIN
			RAISERROR ('PLEASE SCAN A CONTAINER OF THE REQUIRED LOT ALIAS.', 16, 1)
		END
	END

	IF @strOrderType IN (
			'PS'
			,'SO'
			)
	BEGIN
		DECLARE @strInternalCode NVARCHAR(50)

		SELECT @strInternalCode = strInternalCode
		FROM tblWHSKUStatus
		WHERE intSKUStatusId = @intSKUStatusId

		IF @strInternalCode = 'RESTRICTED'
			RAISERROR ('PALLET IS ON HOLD.', 16, 1)
	END

	IF @strOrderType <> 'SO'
	BEGIN
		SELECT @dblOrderLineItemQty = dblQty
		FROM tblWHOrderLineItem
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intItemId = (
				SELECT intItemId
				FROM tblWHSKU
				WHERE strSKUNo = @strSKUNo
				)
			AND ISNULL(strLotAlias, '') = (
				CASE 
					WHEN ISNULL(strLotAlias, '') <> ''
						THEN @strLotCode
					ELSE ISNULL(strLotAlias, '')
					END
				)
	END
	ELSE
	BEGIN
		SELECT @dblOrderLineItemQty = dblQty
		FROM tblWHOrderLineItem
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intItemId = (
				SELECT intItemId
				FROM tblWHSKU
				WHERE strSKUNo = @strSKUNo
				)
	END

	IF EXISTS (
			SELECT *
			FROM tblWHSKU
			WHERE strSKUNo = @strSKUNo
			)
	BEGIN
		IF @dblTaskQty > @dblSKUQty
		BEGIN
			RAISERROR ('Quantity you have entered is more than the available quantity.', 16, 1)
		END
	END

	IF @intTaskTypeId = 13
	BEGIN
		SET @dblTaskQty = @dblSKUQty - @dblTaskQty
	END

	IF @strOrderType <> 'PS'
		AND @ysnIsSKUNoEmpty = 0
	BEGIN
		IF ISNULL(@dblOrderPickedQty, 0) + ISNULL(@dblTaskQty, 0) > ISNULL(@dblOrderLineItemQty, 0)
		BEGIN
			RAISERROR ('Entered qty will cause in a overshipment of this material. Please re-enter the qty.', 16, 1)
		END
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblWHSKU S
			JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
			WHERE C.strContainerNo = @strContainerNo
				AND ysnIsSanitized = 1
			)
		AND @strOrderType = 'SS'
	BEGIN
		DECLARE @strUserName NVARCHAR(50)

		SELECT @strUserName = strUserName
		FROM tblSMUserSecurity
		WHERE [intEntityId] = @intUserId

		--EXECUTE [dbo].[GetErrorMessage] 900209, NULL, @strUserName, @strErrMsg OUTPUT    
		RAISERROR ('The scanned container is already sanitized. Please select a pre-sanitized container.', 16, 1)
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH