CREATE PROCEDURE uspQMSetSampleLotStatus @strXml NVARCHAR(MAX)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intSampleId INT
	DECLARE @intProductTypeId INT
	DECLARE @intProductValueId INT
	DECLARE @intLotStatusId INT
	DECLARE @intCurrentLotStatusId INT

	SELECT @intSampleId = intSampleId
		,@intProductTypeId = intProductTypeId
		,@intProductValueId = intProductValueId
		,@intLotStatusId = intLotStatusId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleId INT
			,intProductTypeId INT
			,intProductValueId INT
			,intLotStatusId INT
			)

	IF @intProductTypeId = 6 -- Lot
	BEGIN
		SELECT @intCurrentLotStatusId = intLotStatusId
		FROM tblICLot
		WHERE intLotId = @intProductValueId
	END

	IF @intProductTypeId = 11 -- Parent Lot
	BEGIN
		SELECT @intCurrentLotStatusId = intLotStatusId
		FROM tblICLot
		WHERE intParentLotId = @intProductValueId
	END

	BEGIN TRAN

	IF @intCurrentLotStatusId <> @intLotStatusId
	BEGIN
		UPDATE tblQMSample
		SET intLotStatusId = @intCurrentLotStatusId
		WHERE intSampleId = @intSampleId
	END

	EXEC sp_xml_removedocument @idoc

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
