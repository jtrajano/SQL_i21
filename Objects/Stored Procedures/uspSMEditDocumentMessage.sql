CREATE PROCEDURE [dbo].[uspSMEditDocumentMessage]
	@DocumentMaintenanceMessageId			INT,
	@NewMessage								NVARCHAR(MAX)
AS
	
	IF EXISTS(SELECT TOP 1 1 FROM tblSMDocumentMaintenanceMessage WHERE intDocumentMaintenanceMessageId = @DocumentMaintenanceMessageId)
	BEGIN

		DECLARE @CurrentMessage NVARCHAR(MAX)
		DECLARE @NewBLBMessage VARBINARY(MAX)
		
		SET @NewBLBMessage = CONVERT(varbinary(MAX), cast(@NewMessage as VARCHAR(max)))

		SELECT @CurrentMessage = CAST(CAST(blbMessage AS VARCHAR(MAX)) AS NVARCHAR(MAX)) 
			FROM tblSMDocumentMaintenanceMessage 
				WHERE intDocumentMaintenanceMessageId = @DocumentMaintenanceMessageId

		UPDATE tblSMDocumentMaintenanceMessage 
				SET strMessage = @NewMessage,
					blbMessage = @NewBLBMessage,
					strMessageOld = @CurrentMessage
			WHERE intDocumentMaintenanceMessageId = @DocumentMaintenanceMessageId

	END

RETURN 0
