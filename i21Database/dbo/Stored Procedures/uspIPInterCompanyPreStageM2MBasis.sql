CREATE PROCEDURE uspIPInterCompanyPreStageM2MBasis @intM2MBasisId INT
	,@strRowState NVARCHAR(50) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKM2MBasisPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intM2MBasisId = @intM2MBasisId

	INSERT INTO tblRKM2MBasisPreStage (
		intM2MBasisId
		,strRowState
		,strFeedStatus
		,strMessage
		)
	SELECT @intM2MBasisId
		,@strRowState
		,''
		,''
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
