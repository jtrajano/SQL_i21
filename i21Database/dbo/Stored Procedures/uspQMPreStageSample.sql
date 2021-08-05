CREATE PROCEDURE uspQMPreStageSample @intSampleId INT
	,@strRowState NVARCHAR(50) = NULL
	,@strSampleNumber NVARCHAR(30) = NULL
	,@intSampleTypeId INT = NULL
	,@intItemId INT = NULL
	,@intCountryID INT = NULL
	,@intCompanyLocationSubLocationId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	IF EXISTS (
			SELECT 1
			FROM tblIPMultiCompany
			)
	BEGIN
		RETURN
	END

	INSERT INTO tblQMSamplePreStage (
		intSampleId
		,strRowState
		,strSampleNumber
		,intRecordStatus
		,intSampleTypeId
		,intItemId
		,intCountryID
		,intCompanyLocationSubLocationId
		)
	SELECT @intSampleId
		,ISNULL(@strRowState, '')
		,@strSampleNumber
		,0
		,@intSampleTypeId
		,@intItemId
		,@intCountryID
		,@intCompanyLocationSubLocationId
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
