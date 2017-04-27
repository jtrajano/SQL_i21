CREATE PROCEDURE [dbo].[uspMFCreateShift] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLocationId INT
		,@intUserId INT
		,@intTransactionCount INT
		,@dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intUserId INT
			)

	DECLARE @intShiftId INT
		,@strShiftName NVARCHAR(50)
		,@dtmShiftStartTime DATETIME
		,@dtmShiftEndTime DATETIME
		,@intDuration INT
		,@intStartOffset INT
		,@intEndOffset INT
		,@intShiftSequence INT
		,@intNextShiftId INT
		,@strNextShiftName NVARCHAR(50)
		,@dtmNextShiftStartTime DATETIME
		,@dtmNextShiftEndTime DATETIME
		,@intNextDuration INT
		,@intNextStartOffset INT
		,@intNextEndOffset INT
		,@intNextShiftSequence INT

	IF EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
					strShiftName NVARCHAR(50)
					,strRowState NVARCHAR(50)
					) x
			WHERE x.strRowState = 'ADDED'
				AND EXISTS (
					SELECT *
					FROM tblMFShift S
					WHERE S.intLocationId = @intLocationId
						AND S.strShiftName = x.strShiftName Collate Latin1_General_CI_AS
					)
			)
	BEGIN
		RAISERROR (
				'Shift name should be unique.'
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
					intShiftId INT
					,strShiftName NVARCHAR(50)
					,strRowState NVARCHAR(50)
					) x
			WHERE x.strRowState = 'MODIFIED'
				AND EXISTS (
					SELECT *
					FROM tblMFShift S
					WHERE S.intLocationId = @intLocationId
						AND S.strShiftName = x.strShiftName Collate Latin1_General_CI_AS
						AND S.intShiftId <> x.intShiftId
					)
			)
	BEGIN
		RAISERROR (
				'Shift name should be unique.'
				,11
				,1
				)
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	INSERT INTO dbo.tblMFShift (
		strShiftName
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intDuration
		,intStartOffset
		,intEndOffset
		,intShiftSequence
		,intLocationId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	SELECT strShiftName
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intDuration
		,intStartOffset
		,intEndOffset
		,intShiftSequence
		,@intLocationId
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,1
	FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
			strShiftName NVARCHAR(50)
			,dtmShiftStartTime DATETIME
			,dtmShiftEndTime DATETIME
			,intDuration INT
			,intStartOffset INT
			,intEndOffset INT
			,intShiftSequence INT
			,strRowState NVARCHAR(50)
			) x
	WHERE x.strRowState = 'ADDED'

	UPDATE tblMFShift
	SET strShiftName = x.strShiftName
		,dtmShiftStartTime = x.dtmShiftStartTime
		,dtmShiftEndTime = x.dtmShiftEndTime
		,intDuration = x.intDuration
		,intStartOffset = x.intStartOffset
		,intEndOffset = x.intEndOffset
		,intShiftSequence = x.intShiftSequence
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GetDate()
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
			intShiftId INT
			,strShiftName NVARCHAR(50)
			,dtmShiftStartTime DATETIME
			,dtmShiftEndTime DATETIME
			,intDuration INT
			,intStartOffset INT
			,intEndOffset INT
			,intShiftSequence INT
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intShiftId = tblMFShift.intShiftId
		AND x.strRowState = 'MODIFIED'

	DELETE
	FROM dbo.tblMFShiftDetail
	WHERE EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/ShiftDetails/ShiftDetail', 2) WITH (
					intShiftDetailId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intShiftDetailId = tblMFShiftDetail.intShiftDetailId
				AND x.strRowState = 'DELETE'
			)

	IF EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
					intShiftId INT
					,strRowState NVARCHAR(50)
					) x
			JOIN tblMFWorkOrderInputLot W ON W.intShiftId = x.intShiftId
			WHERE x.strRowState = 'DELETE'
			)
	BEGIN
		SELECT @strShiftName = strShiftName
		FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
				intShiftId INT
				,strShiftName NVARCHAR(50)
				,strRowState NVARCHAR(50)
				) x
		JOIN tblMFWorkOrderInputLot W ON W.intShiftId = x.intShiftId
		WHERE x.strRowState = 'DELETE'

		RAISERROR (
				'Transaction exists for the shift ''%s'', shift cannot be deleted.'
				,11
				,1
				,@strShiftName
				)
	END

	IF EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
					intShiftId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.strRowState = 'DELETE'
				AND EXISTS (
					SELECT *
					FROM dbo.tblMFWorkOrder W
					WHERE W.intPlannedShiftId = x.intShiftId
					)
			)
	BEGIN
		SELECT @strShiftName = strShiftName
		FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
				intShiftId INT
				,strShiftName NVARCHAR(50)
				,strRowState NVARCHAR(50)
				) x
		WHERE x.strRowState = 'DELETE'
			AND EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				WHERE W.intPlannedShiftId = x.intShiftId
				)

		RAISERROR (
				'Transaction exists for the shift ''%s'', shift cannot be deleted.'
				,11
				,1
				,@strShiftName
				)
	END

	DELETE
	FROM dbo.tblMFShift
	WHERE EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
					intShiftId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intShiftId = tblMFShift.intShiftId
				AND x.strRowState = 'DELETE'
			)

	SELECT @intShiftSequence = MIN(intShiftSequence)
	FROM tblMFShift

	WHILE (@intShiftSequence > 0)
	BEGIN
		SELECT @intShiftId = NULL
			,@strShiftName = NULL
			,@dtmShiftStartTime = NULL
			,@dtmShiftEndTime = NULL
			,@intDuration = NULL
			,@intStartOffset = NULL
			,@intEndOffset = NULL

		SELECT @intShiftId = intShiftId
			,@strShiftName = strShiftName
			,@dtmShiftStartTime = dtmShiftStartTime
			,@dtmShiftEndTime = dtmShiftEndTime
			,@intDuration = intDuration
			,@intStartOffset = intStartOffset
			,@intEndOffset = intEndOffset
		FROM dbo.tblMFShift
		WHERE intShiftSequence = @intShiftSequence

		SELECT @intNextShiftId = NULL
			,@strNextShiftName = NULL
			,@dtmNextShiftStartTime = NULL
			,@dtmNextShiftEndTime = NULL
			,@intNextDuration = NULL
			,@intNextStartOffset = NULL
			,@intNextEndOffset = NULL

		SELECT @intNextShiftId = intShiftId
			,@strNextShiftName = strShiftName
			,@dtmNextShiftStartTime = dtmShiftStartTime
			,@dtmNextShiftEndTime = dtmShiftEndTime
			,@intNextDuration = intDuration
			,@intNextStartOffset = intStartOffset
			,@intNextEndOffset = intEndOffset
		FROM dbo.tblMFShift
		WHERE intShiftSequence = @intShiftSequence + 1

		IF @dtmNextShiftStartTime IS NOT NULL
		BEGIN
			IF @dtmShiftEndTime + @intEndOffset > @dtmNextShiftStartTime + @intNextStartOffset
			BEGIN
				RAISERROR (
						'This shift configuration is overlapping with existing shifts, cannot be allowed.'
						,11
						,1
						)

				RETURN
			END
		END

		SELECT @intShiftSequence = MIN(intShiftSequence)
		FROM tblMFShift
		WHERE intShiftSequence > @intShiftSequence
	END

	INSERT INTO dbo.tblMFShiftDetail (
		intShiftId
		,intShiftBreakTypeId
		,dtmShiftBreakTypeStartTime
		,dtmShiftBreakTypeEndTime
		,intShiftBreakTypeDuration
		,intSequence
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	SELECT S.intShiftId
		,x.intShiftBreakTypeId
		,x.dtmShiftBreakTypeStartTime
		,x.dtmShiftBreakTypeEndTime
		,x.intShiftBreakTypeDuration
		,x.intSequence
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,1
	FROM OPENXML(@idoc, 'root/ShiftDetails/ShiftDetail', 2) WITH (
			strShiftName NVARCHAR(50)
			,intShiftBreakTypeId INT
			,dtmShiftBreakTypeStartTime DATETIME
			,dtmShiftBreakTypeEndTime DATETIME
			,intShiftBreakTypeDuration INT
			,intSequence INT
			,strRowState NVARCHAR(50)
			) x
	JOIN dbo.tblMFShift S ON S.strShiftName = x.strShiftName Collate Latin1_General_CI_AS
	WHERE x.strRowState = 'ADDED'

	UPDATE tblMFShiftDetail
	SET intShiftId = S.intShiftId
		,intShiftBreakTypeId = x.intShiftBreakTypeId
		,dtmShiftBreakTypeStartTime = x.dtmShiftBreakTypeStartTime
		,dtmShiftBreakTypeEndTime = x.dtmShiftBreakTypeEndTime
		,intShiftBreakTypeDuration = x.intShiftBreakTypeDuration
		,intSequence = x.intSequence
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GetDate()
		,intConcurrencyId = Isnull(tblMFShiftDetail.intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/ShiftDetails/ShiftDetail', 2) WITH (
			intShiftDetailId INT
			,strShiftName NVARCHAR(50)
			,intShiftBreakTypeId INT
			,dtmShiftBreakTypeStartTime DATETIME
			,dtmShiftBreakTypeEndTime DATETIME
			,intShiftBreakTypeDuration INT
			,intSequence INT
			,strRowState NVARCHAR(50)
			) x
	JOIN dbo.tblMFShift S ON S.strShiftName = x.strShiftName Collate Latin1_General_CI_AS
	WHERE x.intShiftDetailId = tblMFShiftDetail.intShiftDetailId
		AND x.strRowState = 'MODIFIED'

	DECLARE @tblMFShiftDetail TABLE (
		intShiftDetailId INT
		,intSequence INT
		)

	INSERT INTO @tblMFShiftDetail (
		intShiftDetailId
		,intSequence
		)
	SELECT intShiftDetailId
		,ROW_NUMBER() OVER (
			PARTITION BY intShiftId ORDER BY dtmShiftBreakTypeStartTime
			)
	FROM tblMFShiftDetail

	UPDATE SD
	SET intSequence = S.intSequence
	FROM @tblMFShiftDetail S
	JOIN tblMFShiftDetail SD ON SD.intShiftDetailId = S.intShiftDetailId

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


