CREATE PROCEDURE [dbo].[uspIPWeightClaimTransferStgXML]
AS
BEGIN
	SET NOCOUNT ON

	SELECT *
	FROM tblLGWeightClaimStage
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblLGWeightClaimStage
	SET strFeedStatus = 'Awt Ack'
	WHERE ISNULL(strFeedStatus, '') = ''
END

