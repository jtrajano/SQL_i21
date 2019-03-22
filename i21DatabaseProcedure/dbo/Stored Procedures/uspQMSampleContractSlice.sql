CREATE PROCEDURE uspQMSampleContractSlice @intContractHeaderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intSampleStatusId INT

	SELECT @intSampleStatusId = intSampleStatusId
	FROM tblQMSampleStatus
	WHERE LOWER(strStatus) = 'rejected'

	-- Slice Rejected sequence samples
	EXEC uspQMSampleContractSliceByStatus @intContractHeaderId
		,@intSampleStatusId
		,1

	-- Slice Approved sequence samples
	EXEC uspQMSampleContractSliceByStatus @intContractHeaderId
		,@intSampleStatusId
		,0
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
