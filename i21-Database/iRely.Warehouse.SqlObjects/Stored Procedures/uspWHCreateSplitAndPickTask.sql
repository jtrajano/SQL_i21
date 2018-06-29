CREATE PROCEDURE [dbo].[uspWHCreateSplitAndPickTask]
					@intOrderHeaderId INT, 
					@intSKUId INT, 
					@strUserName NVARCHAR(32), 
					@dblSplitAndPickQty DECIMAL(24, 10), 
					@intTaskTypeId INT, 
					@intAssigneeId INT = 0, 
					@dtmReleaseDate NVARCHAR(32) = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @intTaskId INT
	DECLARE @intAddressId INT
	DECLARE @strTaskNo NVARCHAR(64)
	DECLARE @ToStorageLocationId INT
	DECLARE @FromStorageLocationId INT
	DECLARE @FromContainerId INT
	DECLARE @dblSKUQty AS NUMERIC(18, 6)
	DECLARE @intUserSecurityId INT
	--BugID:1872
	DECLARE @intDirectionId INT
	DECLARE @intItemId INT
	DECLARE @intStatusId INT
	DECLARE @intExistingSKUTaskQty AS NUMERIC(18, 6)
	DECLARE @intExistingTaskId AS NUMERIC(18, 6)

	SELECT @intAddressId = intShipFromAddressId, 
	       @strTaskNo = strBOLNo, 
	       @ToStorageLocationId = intStagingLocationId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intUserSecurityId = [intEntityId] --this is a hiccup
	FROM tblSMUserSecurity
	WHERE strUserName = @strUserName

	SELECT @FromStorageLocationId = c.intStorageLocationId, 
		   @FromContainerId = s.intContainerId, 
		   @dblSKUQty = s.dblQty,
		   @intItemId = s.intItemId
	FROM tblWHSKU s
	INNER JOIN tblWHContainer c ON s.intContainerId = c.intContainerId
	WHERE intSKUId = @intSKUId

	INSERT INTO tblWHTask (intConcurrencyId, strTaskNo, intTaskTypeId, intTaskStateId, intAssigneeId, intOrderHeaderId, intAddressId, intTaskPriorityId, dtmReleaseDate, intItemId, intSKUId, intFromContainerId, intFromStorageLocationId, intToStorageLocationId, dblQty, intCreatedUserId, dtmCreated, intLastModifiedUserId, dtmLastModified)
	VALUES (
		0, @strTaskNo, @intTaskTypeId, CASE 
			WHEN @intAssigneeId > 0
				THEN 2
			ELSE 1
			END, @intAssigneeId, @intOrderHeaderId, @intAddressId, 2, ISNULL(@dtmReleaseDate, GETDATE()), @intItemId, @intSKUId, @FromContainerId, @FromStorageLocationId, @ToStorageLocationId, @dblSplitAndPickQty, @intUserSecurityId, GETDATE(), @intUserSecurityId, GETDATE()
		)

	SET @intTaskId = SCOPE_IDENTITY()

	UPDATE t 
			SET dblPickQty = 
			CASE WHEN strTaskType = 'Put Back'
			THEN s.dblQty - t.dblQty
			ELSE t.dblQty END
	FROM tblWHTask t
	JOIN tblWHSKU s ON s.intSKUId = t.intSKUId
	JOIN tblWHTaskType tt ON tt.intTaskTypeId = t.intTaskTypeId
	WHERE intTaskId = @intTaskId

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
END
GO