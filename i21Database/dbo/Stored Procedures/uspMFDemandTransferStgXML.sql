CREATE PROCEDURE [dbo].[uspMFDemandTransferStgXML]
AS
BEGIN
	SET NOCOUNT ON

	SELECT *
	FROM tblMFDemandStage
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblMFDemandStage
	SET strFeedStatus = 'Awt Ack'
	WHERE ISNULL(strFeedStatus, '') = ''
END

