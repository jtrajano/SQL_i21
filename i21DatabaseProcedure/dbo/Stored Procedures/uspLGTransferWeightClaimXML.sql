CREATE PROCEDURE [dbo].[uspLGTransferWeightClaimXML] 
	@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblLGIntrCompWeightClaimsStg
	WHERE intMultiCompanyId = @intToCompanyId
		AND strFeedStatus IS NULL

	UPDATE tblLGIntrCompWeightClaimsStg
	SET strFeedStatus = 'Awt Ack'
	WHERE intMultiCompanyId = @intToCompanyId
		AND strFeedStatus IS NULL

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
