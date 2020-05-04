CREATE PROCEDURE [dbo].[uspQMSampleTransferStgXML] @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	UPDATE ST1
	SET ST1.strFeedStatus = 'HOLD'
	FROM tblQMSampleStage ST
	JOIN tblQMSampleStage ST1 ON ST1.intSampleId = ST.intSampleId
		AND ISNULL(ST1.strFeedStatus, '') = ''
		AND ST1.intMultiCompanyId = @intToCompanyId
	WHERE ISNULL(ST.strFeedStatus, '') = 'Awt Ack'
		AND UPPER(ST.strRowState) = 'ADDED'

	UPDATE ST1
	SET ST1.strFeedStatus = NULL
	FROM tblQMSampleStage ST
	JOIN tblQMSampleStage ST1 ON ST1.intSampleId = ST.intSampleId
		AND ISNULL(ST1.strFeedStatus, '') = 'HOLD'
		AND ST1.intMultiCompanyId = @intToCompanyId
	WHERE ISNULL(ST.strFeedStatus, '') = 'Ack Rcvd'
		AND UPPER(ST.strRowState) = 'ADDED'

	SELECT *
	FROM tblQMSampleStage WITH (NOLOCK)
	WHERE intMultiCompanyId = @intToCompanyId
		AND ISNULL(strFeedStatus, '') = ''

	UPDATE tblQMSampleStage
	SET strFeedStatus = 'Awt Ack'
	WHERE intMultiCompanyId = @intToCompanyId
		AND ISNULL(strFeedStatus, '') = ''
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
