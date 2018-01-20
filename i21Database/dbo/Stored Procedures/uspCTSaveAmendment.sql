CREATE PROCEDURE [dbo].[uspCTSaveAmendment]

AS

BEGIN TRY
	
	DECLARE @ErrMsg				NVARCHAR(MAX),
			@strAmendmentFields	NVARCHAR(MAX)

	SELECT  @strAmendmentFields= STUFF((
										SELECT DISTINCT ', ' + LTRIM(RTRIM(strDataIndex))
										FROM tblCTAmendmentApproval WHERE ISNULL(ysnAmendment,0) =1
										FOR XML PATH('')
										), 1, 2, '')

	UPDATE tblCTCompanyPreference SET  strAmendmentFields =  RTRIM(LTRIM(@strAmendmentFields))

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
