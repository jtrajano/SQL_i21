CREATE PROCEDURE [dbo].[uspLGProcessLogisticsXML] 
	@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblLGIntrCompLogistics
	WHERE intMultiCompanyId = @intToCompanyId
		AND strFeedStatus IS NULL

	UPDATE tblLGIntrCompLogistics
	SET strFeedStatus = 'Awt Ack'
	WHERE intMultiCompanyId = @intToCompanyId
		AND strFeedStatus IS NULL

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
