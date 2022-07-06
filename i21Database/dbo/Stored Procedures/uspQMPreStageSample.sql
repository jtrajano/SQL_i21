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
		,@intSamplePreStageId INT

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

	SELECT @intSamplePreStageId = SCOPE_IDENTITY()

	UPDATE SPS
	SET SPS.intContractDetailId = S.intContractDetailId
		,SPS.intEntityId = S.intEntityId
		,SPS.intCreatedUserId = S.intCreatedUserId
		,SPS.strContainerNumber = S.strContainerNumber
		,SPS.strMarks = S.strMarks
		,SPS.strLotNumber = S.strLotNumber
		,SPS.dblRepresentingQty = S.dblRepresentingQty
		,SPS.dtmSampleReceivedDate = S.dtmSampleReceivedDate
		,SPS.dtmCreated = S.dtmCreated
	FROM dbo.tblQMSamplePreStage SPS
	JOIN dbo.tblQMSample S ON S.intSampleId = SPS.intSampleId
		AND intSamplePreStageId = @intSamplePreStageId
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
