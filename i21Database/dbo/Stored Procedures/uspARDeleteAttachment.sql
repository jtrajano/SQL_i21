CREATE PROCEDURE [dbo].[uspARDeleteAttachment]
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	
	DECLARE @intAttachmentRetention INT = 0

	SELECT TOP 1 @intAttachmentRetention = ISNULL(intAttachmentRetention, 0)
	FROM tblARCompanyPreference

	IF @intAttachmentRetention > 0 
	BEGIN
		DECLARE @AttachmentIds Id

		INSERT INTO @AttachmentIds
		SELECT		SMA.intAttachmentId
		FROM		tblSMAttachment AS SMA
		INNER JOIN	dbo.tblSMTransaction AS SMT
		ON			SMA.intTransactionId = SMT.intTransactionId
		INNER JOIN	dbo.tblSMScreen AS SMS
		ON			SMT.intScreenId = SMS.intScreenId
		INNER JOIN	dbo.tblEMEntityType AS ENET
		ON			SMA.strRecordNo = ENET.intEntityId
		INNER JOIN	tblSMUpload SMU
		ON			SMA.intAttachmentId = SMU.intAttachmentId
		WHERE		SMS.strNamespace = 'EntityManagement.view.Entity'
		AND			ENET.strType = 'Customer'

		DELETE FROM SMA
		FROM		tblSMAttachment SMA
		INNER JOIN	tblSMUpload SMU
		ON			SMA.intAttachmentId = SMU.intAttachmentId
		WHERE		SMA.intAttachmentId IN (SELECT intId FROM @AttachmentIds)
		AND			dtmDateUploaded < DATEADD(YEAR, @intAttachmentRetention * -1, DATEADD(DAY, 0, GETDATE()))
		AND			dtmDateUploaded IS NOT NULL
	END

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									

	RAISERROR(@ErrorMerssage, 11, 1)

	RETURN 0
END CATCH

RETURN 1

END