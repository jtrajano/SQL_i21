CREATE PROCEDURE [dbo].[uspSMDocumentMessage]
	@strRecordNo						NVARCHAR(200)
	,@strTransaction					NVARCHAR(100)
	,@strType							NVARCHAR(200)
	,@strSourceRecordNo					NVARCHAR(200)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @intTransactionId INT = NULL 
		,@intScreenId INT = NULL
		,@intDocumentMaintenanceId INT = NULL
		,@intSourceDocumentMaintenanceId INT = NULL

	SELECT @intTransactionId = T.intTransactionId FROM tblSMScreen S JOIN tblSMTransaction T ON T.intScreenId = S.intScreenId WHERE S.strNamespace = @strType AND T.strRecordNo = @strSourceRecordNo

	SELECT @intScreenId = intScreenId FROM tblSMScreen WHERE strNamespace = @strType

	IF (@intTransactionId = NULL)
		BEGIN   
					
		IF(@intScreenId = NULL)
			BEGIN
				RAISERROR('Invalid Screen name space!',16,1);
			END
			
		ELSE
			BEGIN	
					
				INSERT INTO tblSMTransaction (intScreenId, strRecordNo, intConcurrencyId) VALUES(@intScreenId,@strRecordNo, 1)

				SELECT @intTransactionId = Scope_Identity()

				INSERT INTO tblSMDocumentMessage (intTransactionId, intDocumentMaintenanceId, dtmDateModified, intConcurrencyId) VALUES(@intTransactionId, @intDocumentMaintenanceId, GETUTCDATE(), 1)

			END
		END
	ELSE
		BEGIN

		SELECT @intSourceDocumentMaintenanceId = intDocumentMaintenanceId FROM tblSMDocumentMessage WHERE intTransactionId = @intTransactionId

		IF(@intScreenId = NULL)
			BEGIN
				RAISERROR('Invalid Screen name space!',16,1);
			END
		ELSE
			BEGIN
				IF(@strRecordNo != @strSourceRecordNo)
					BEGIN
						
						SELECT @intDocumentMaintenanceId = intDocumentMaintenanceId FROM vyuSMDocumentMaintenanceMessage WHERE intDocumentMaintenanceId = @intSourceDocumentMaintenanceId AND strOptionName = @strTransaction
						
						INSERT INTO tblSMTransaction (intScreenId, strRecordNo, intConcurrencyId) VALUES(@intScreenId,@strRecordNo, 1)

						SELECT @intTransactionId = Scope_Identity()

						INSERT INTO tblSMDocumentMessage (intTransactionId, intDocumentMaintenanceId, dtmDateModified, intConcurrencyId) VALUES(@intTransactionId, @intDocumentMaintenanceId, GETUTCDATE(), 1)
					END
				ELSE
					BEGIN
						UPDATE tblSMDocumentMessage SET intDocumentMaintenanceId = @intSourceDocumentMaintenanceId, dtmDateModified = GETUTCDATE() WHERE intTransactionId = @intTransactionId	
					END
			END	
		END
	
END 

