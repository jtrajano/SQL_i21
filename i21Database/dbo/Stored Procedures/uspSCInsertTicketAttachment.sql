CREATE PROCEDURE [dbo].[uspSCInsertTicketAttachment]
	@intTicketId INT
	,@strFileName NVARCHAR(MAX) 
	,@strFileExtension NVARCHAR(10)
	,@strPath NVARCHAR(MAX)
	,@intUserId INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF


	DECLARE @intScreenId INT
	DECLARE @intTransactionId INT
	DECLARE @intAttachmentId INT
	DECLARE @errorMessage NVARCHAR(MAX)

	SELECT TOP 1
		@intScreenId = intScreenId
	FROM tblSMScreen
	WHERE strScreenName = 'Scale'	
		AND strNamespace = 'Grain.view.Scale'

	IF(ISNULL(@intScreenId,0) <> 0)
	BEGIN
		SELECT TOP 1 
			@intTransactionId = intTransactionId
		FROM tblSMTransaction
		WHERE intScreenId = @intScreenId
			AND intRecordId = @intTicketId

		IF(ISNULL(@intTransactionId,0) =  0)
		BEGIN
			INSERT INTO tblSMTransaction(
				intScreenId
				,strTransactionNo
				,intEntityId
				,dtmDate
				,intRecordId
			)
			SELECT 
				intScreenId = @intScreenId
				,strTransactionNo = strTicketNumber
				,intEntityId = intEntityId
				,dtmDate = ISNULL(dtmImportedDate,GETDATE())
				,intRecordId = intTicketId
			FROM tblSCTicket
			WHERE intTicketId = @intTicketId
			
			SET @intTransactionId =  SCOPE_IDENTITY()
		END

		EXEC [uspSMCreateAttachmentFromFile]   
				@transactionId  = @intTransactionId                                      
				,@fileName = @strFileName												
				,@fileExtension = @strFileExtension                                      
				,@filePath = @strPath                                                    
				,@screenNamespace = 'Grain.view.Scale'                                   
				,@useDocumentWatcher = 0                                                 
				,@throwError = 1
				,@attachmentId = @intAttachmentId OUTPUT
				,@error = @errorMessage OUTPUT
	END
END
GO
