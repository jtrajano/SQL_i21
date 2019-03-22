CREATE PROCEDURE [dbo].[uspSMStartingNumberResetDate]
	 @Id	INT
AS	
BEGIN
	UPDATE tblSMStartingNumber SET dtmResetDate = SYSDATETIME() WHERE intStartingNumberId = @Id
END