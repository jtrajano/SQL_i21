CREATE PROCEDURE [dbo].[uspCTSaveAmendment]
 @intUserId INT
AS

BEGIN TRY
	
	DECLARE @ErrMsg				NVARCHAR(MAX),
			@strAmendmentFields	NVARCHAR(MAX)

	SELECT  @strAmendmentFields= STUFF((
										SELECT DISTINCT ',' + LTRIM(RTRIM(strDataIndex))
										FROM tblCTAmendmentApproval WHERE ISNULL(ysnAmendment,0) =1
										FOR XML PATH('')
										), 1, 1, '')

	UPDATE tblCTCompanyPreference SET  strAmendmentFields =  RTRIM(LTRIM(@strAmendmentFields))
	
	UPDATE tblCTAmendmentApprovalLog SET intLastModifiedById = @intUserId WHERE intLastModifiedById IS NULL

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
