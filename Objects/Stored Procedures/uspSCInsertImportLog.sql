CREATE PROCEDURE [dbo].[uspSCInsertImportLog]
	@intTransactionId INT = NULL,
	@strTransactionNumber NVARCHAR(MAX),
	@strTransactionType NVARCHAR(MAX),
	@strLogMessage NVARCHAR(MAX),
	@Id INT OUTPUT
AS
BEGIN
	IF @intTransactionId = 0
		SET @intTransactionId = NULL
	INSERT INTO tblSCImportLogFile (intTransactionId, strTransactionNumber, strTransactionType, strLogMessage)
	VALUES (@intTransactionId, @strTransactionNumber, @strTransactionType, @strLogMessage)

	SET @Id = SCOPE_IDENTITY();
END