CREATE PROCEDURE uspMFGetLotTextInReport
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT strLotTextInReport
		,CASE 
			WHEN strLotTextInReport = 'Pallet #'
				THEN 'Lot #'
			ELSE 'P-Lot #'
			END AS strParentLotTextInReport
	FROM tblMFCompanyPreference
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFGetLotTextInReport - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
