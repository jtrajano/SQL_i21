CREATE PROCEDURE uspMFAddOrderNewLot @intOrderHeaderId INT
	,@intLotId INT
	,@intUserId INT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intOrderDetailId INT

	SELECT @intOrderDetailId = intOrderDetailId
	FROM tblMFOrderDetail OD
	JOIN tblICLot L ON L.intItemId = OD.intItemId
	WHERE L.intLotId = @intLotId
		AND OD.intOrderHeaderId = @intOrderHeaderId

	BEGIN TRAN

	INSERT INTO tblMFOrderManifest (
		intConcurrencyId
		,intOrderDetailId
		,intOrderHeaderId
		,intLotId
		,strManifestItemNote
		,intLastUpdateId
		,dtmLastUpdateOn
		)
	VALUES (
		1
		,@intOrderDetailId
		,@intOrderHeaderId
		,@intLotId
		,'Manually Added'
		,@intUserId
		,GETDATE()
		)

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
