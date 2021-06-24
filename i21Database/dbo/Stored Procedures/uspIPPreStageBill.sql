CREATE PROCEDURE uspIPPreStageBill (
	@strBillId NVARCHAR(MAX)
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE 
	FROM tblAPBillPreStage
	WHERE intBillId IN (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strBillId, ','))
		AND strRowState = @strRowState
		AND ISNULL(intStatusId, 1) = 1

	INSERT INTO dbo.tblAPBillPreStage (
		intBillId
		,strRowState
		,intUserId
		)
	SELECT Item Collate Latin1_General_CI_AS
		,@strRowState
		,@intUserId
	FROM [dbo].[fnSplitString](@strBillId, ',')
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
