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

	IF EXISTS (
			SELECT *
			FROM (
				SELECT strShiftName
					,ROW_NUMBER() OVER (
						PARTITION BY strShiftName ORDER BY strShiftName
						) AS intRowNumber
				FROM OPENXML(@idoc, 'root/Shifts/Shift', 2) WITH (
						strShiftName NVARCHAR(50)
						,strRowState NVARCHAR(50)
						) x
				WHERE x.strRowState = 'ADDED'
				) AS DT
			WHERE DT.intRowNumber > 1
			)
	BEGIN
		RAISERROR (
				51154
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
	FROM OPENXML(@idoc, 'root/Shifts/ShiftDetail', 2) WITH (
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
		,intConcurrencyId = Isnull(tblMFShiftDetail.intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/Shifts/ShiftDetail', 2) WITH (
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

	DELETE
	FROM dbo.tblMFShiftDetail
	WHERE EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/Shifts/ShiftDetail', 2) WITH (
					intShiftDetailId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intShiftDetailId = tblMFShiftDetail.intShiftDetailId
				AND x.strRowState = 'DELETE'
			)

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


