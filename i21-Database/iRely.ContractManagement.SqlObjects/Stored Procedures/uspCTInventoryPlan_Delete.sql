CREATE PROCEDURE [dbo].[uspCTInventoryPlan_Delete] @intInvPlngReportMasterID INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblCTInvPlngReportAttributeValue
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	DELETE
	FROM tblCTInvPlngReportMaterial
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	DELETE
	FROM tblCTInvPlngReportMaster
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
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
