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
		DELETE FROM SMA
		FROM tblSMAttachment SMA
		INNER JOIN tblSMUpload SMU
		ON SMA.intAttachmentId = SMU.intAttachmentId
		WHERE SMA.strScreen IN ('AccountsReceivable.view.ReceivePaymentsDetail', 'AccountsReceivable.view.Invoice', 'AccountsReceivable.view.SalesOrder')
		AND (DATEDIFF(MONTH, dtmDateUploaded, GETDATE()) / 12) > @intAttachmentRetention
		AND dtmDateUploaded IS NOT NULL
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