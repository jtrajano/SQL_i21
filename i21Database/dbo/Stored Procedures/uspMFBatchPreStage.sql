CREATE PROCEDURE uspMFBatchPreStage (
	@intBatchId INT
	,@intUserId INT
	,@intOriginalItemId INT
	,@intItemId INT
	)
AS
BEGIN
	INSERT INTO tblMFBatchPreStage (
		intBatchId
		,intOriginalItemId
		,intItemId
		,intUserId
		)
	SELECT @intBatchId
		,@intOriginalItemId
		,@intItemId
		,@intUserId
END
