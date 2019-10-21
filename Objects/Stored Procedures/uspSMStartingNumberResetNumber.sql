CREATE PROCEDURE [dbo].[uspSMStartingNumberResetNumber]
AS
BEGIN

	UPDATE b SET b.intNumber = 1
	FROM tblSMStartingNumber a
	INNER JOIN tblSMStartingNumberLocation b ON a.intStartingNumberId = b.intStartingNumberId
	WHERE CAST(dtmResetDate AS DATE) <> CAST(SYSDATETIME() AS DATE) AND ysnResetNumber = 1

	UPDATE tblSMStartingNumber SET intNumber = 1, dtmResetDate = SYSDATETIME()
	WHERE CAST(dtmResetDate AS DATE) <> CAST(SYSDATETIME() AS DATE) AND ysnResetNumber = 1

END