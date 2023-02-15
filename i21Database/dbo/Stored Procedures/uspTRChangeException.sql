CREATE PROCEDURE [dbo].[uspTRChangeException]
	@strIds NVARCHAR(MAX),
	@intUserId INT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	SELECT *
	INTO #tmpIds
	FROM dbo.fnSplitStringWithTrim(@strIds, ',')
		
	BEGIN TRY
		UPDATE tblTRImportDtnDetail
		SET ysnException = CASE WHEN ISNULL(ysnException, 0) = 0 THEN 1 ELSE 0 END
		WHERE intImportDtnDetailId IN (SELECT Item FROM #tmpIds)

		DROP TABLE #tmpIds
	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		)
	END CATCH

END