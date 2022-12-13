CREATE PROCEDURE uspMFRecallPreStage (
	@intWorkOrderId INT
	,@intUserId INT
	)
AS
BEGIN
	DECLARE @intStatusId INT

	SELECT @intStatusId = intStatusId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intStatusId IN (
			13
			,21
			)
	BEGIN
		RAISERROR (
				'Recall is not allowed because the selected blend sheet is completed fully or partially.'
				,16
				,1
				)
	END

	INSERT INTO tblMFRecallPreStage (
		intWorkOrderId
		,intUserId
		)
	SELECT @intWorkOrderId
		,@intUserId
END