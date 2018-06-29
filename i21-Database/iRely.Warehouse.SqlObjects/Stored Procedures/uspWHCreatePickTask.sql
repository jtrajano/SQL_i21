CREATE PROCEDURE [dbo].[uspWHCreatePickTask]
		@intOrderHeaderId INT, 
		@intSKUId INT, 
		@strUserName NVARCHAR(32), 
		@intAssigneeId INT = 0, 
		@dtmReleaseDate NVARCHAR(32) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTaskId INT
	DECLARE @intAddressId INT
	DECLARE @strTaskNo NVARCHAR(64)
	DECLARE @intToStorageLocationId INT
	DECLARE @intCount INT
	DECLARE @intFromStorageLocationId INT
	DECLARE @intFromContainerId INT
	DECLARE @dblQty NUMERIC(18, 6)
	DECLARE @intUserSecurityId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intDirectionId INT
	DECLARE @intStatusId INT
	DECLARE @intItemId INT
	
	SET @strErrMsg = ''

	SELECT @intAddressId = intShipFromAddressId, 
		   @strTaskNo = strBOLNo, 
		   @intToStorageLocationId = intStagingLocationId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intUserSecurityId = [intEntityId] --this is a hiccup
	FROM tblSMUserSecurity
	WHERE strUserName = @strUserName

	SELECT @intFromStorageLocationId = c.intStorageLocationId, @intFromContainerId = s.intContainerId, @dblQty = dblQty - ISNULL((
				SELECT SUM(ISNULL(dblQty, 0))
				FROM tblWHTask
				WHERE intSKUId = s.intSKUId AND intTaskStateId IN (1,2,3) AND intTaskTypeId IN (2,7,13)
				), 0),
				@intItemId = s.intItemId
	FROM tblWHSKU s
	INNER JOIN tblWHContainer c ON s.intContainerId = c.intContainerId
	WHERE intSKUId = @intSKUId
		--exclude lots already on outbound orders that are not closed or cancelled          
		AND NOT EXISTS (
			SELECT *
			FROM tblWHOrderManifest m
			INNER JOIN tblWHOrderLineItem li2 ON li2.intOrderLineItemId = m.intOrderLineItemId
			INNER JOIN tblWHOrderHeader h2 ON h2.intOrderHeaderId = li2.intOrderHeaderId
				-- outbound          
				AND h2.intOrderDirectionId = 2
				--open orders          
				AND h2.intOrderStatusId IN (
					1
					,16
					,32
					,64
					)
			WHERE m.intSKUId = s.intSKUId
			)

	INSERT INTO tblWHTask (intConcurrencyId, strTaskNo, intTaskTypeId, intTaskStateId, intAssigneeId, intAddressId, intOrderHeaderId, intTaskPriorityId, dtmReleaseDate, intFromStorageLocationId, intToStorageLocationId, intFromContainerId, intItemId, intSKUId, dblQty, dblPickQty, intCreatedUserId, dtmCreated, intLastModifiedUserId, dtmLastModified)
	VALUES (0,
		@strTaskNo, 2, CASE 
			WHEN @intAssigneeId > 0
				THEN 2
			ELSE 1
			END, @intAssigneeId, @intAddressId, @intOrderHeaderId, 2, ISNULL(@dtmReleaseDate, GETDATE()), @intFromStorageLocationId, @intToStorageLocationId, @intFromContainerId, @intItemId, @intSKUId, @dblQty, @dblQty, @intUserSecurityId, GETDATE(), @intUserSecurityId, GETDATE()
		)

	SET @intTaskId = SCOPE_IDENTITY()

	--BugID:1872        
	SELECT @intDirectionId = intOrderDirectionId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	IF @intDirectionId = 2
	BEGIN
		IF (
				SELECT count(*)
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId IN (
						2
						,7
						,13
						)
				) --PICK,SPLIT,PUT_BACK                                            
			= (
				SELECT count(*)
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
				)
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblWHOrderStatus
			WHERE strOrderStatus = 'RELEASED'

			UPDATE tblWHOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF (
				SELECT count(*)
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId = 3
				) --LOAD                                                  
			= (
				SELECT count(*)
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
				)
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblWHOrderStatus
			WHERE strOrderStatus = 'STAGED'

			UPDATE tblWHOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF (
				SELECT count(*)
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId = 4
				) --SHIP                                                  
			= (
				SELECT count(*)
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
				)
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblWHOrderStatus
			WHERE strOrderStatus = 'LOADED'

			UPDATE tblWHOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF EXISTS (
				SELECT *
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId IN (
						2
						,7
						,13
						)
				) --'PICK','SPLIT','PUT_BACK'                                                 
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblWHOrderStatus
			WHERE strOrderStatus = 'PICKING'

			UPDATE tblWHOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF EXISTS (
				SELECT *
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId IN (3)
				) --LOAD                                        
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblWHOrderStatus
			WHERE strOrderStatus = 'LOADING'

			UPDATE tblWHOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
	END

	SELECT @intTaskId

	DELETE
	FROM tblWHTask
	WHERE dblQty <= 0
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHCreatePickTask: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH