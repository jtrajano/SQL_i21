CREATE PROCEDURE [dbo].[uspSMTransactionInsertApprovalStatus]
  @screenNamespace NVARCHAR(250),
  @recordId INT,
  @intEntityId INT,
  @status NVARCHAR(250),
  @remarks NVARCHAR(500),
  @result BIT OUTPUT
AS
BEGIN
	DECLARE @intTransactionId INT
	DECLARE @intOrder INT
	DECLARE @intScreenId INT
	DECLARE @screenApproval BIT

	SET @result = 0

	-------------VALIDATIONS-------------
	IF ISNULL(@screenNamespace,'') = ''
	BEGIN
		RAISERROR(N'The namespace cannot be null or empty!.', 16, 1);
		RETURN @result
	END
	IF ISNULL(@recordId,0) = 0
	BEGIN
		RAISERROR(N'The record id cannot be null or empty!.', 16, 1);
		RETURN @result
	END
	IF ISNULL(@intEntityId,0) = 0
	BEGIN
		RAISERROR(N'The entity id cannot be null or empty!.', 16, 1);
		RETURN @result
	END
	IF ISNULL(@status,'') = ''
	BEGIN
		RAISERROR(N'The status cannot be empty or null!.', 16, 1);
		RETURN @result
	END

	SELECT TOP 1 @intScreenId = intScreenId, @screenApproval = ysnApproval FROM tblSMScreen WHERE strNamespace = @screenNamespace
	IF ISNULL(@intScreenId, 0) = 0
	BEGIN
		RAISERROR(N'The screen cannot be found!', 16, 1);
		RETURN @result
	END
	IF ISNULL(@screenApproval, 0) = 0
	BEGIN
		RAISERROR(N'The screen is not configured for approval!', 16, 1);
		RETURN @result
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntity WHERE intEntityId = ISNULL(@intEntityId, 0))
	BEGIN
		RAISERROR(N'The Entity id cannot be found!', 16, 1);
		RETURN @result
	END


	SELECT TOP 1 @intTransactionId = intTransactionId FROM tblSMTransaction WHERE intScreenId = @intScreenId AND intRecordId = @recordId
	IF ISNULL(@intTransactionId, 0) = 0
	BEGIN
		-- RAISERROR(N'The transaction cannot be found! Please check your record id and screen namespace.', 16, 1);
		-- RETURN @result
		INSERT INTO tblSMTransaction (
			intScreenId,
			intRecordId,
			intConcurrencyId
		)
		VALUES (
			@intScreenId,
			@recordId,
			1
		)
		SELECT @intTransactionId = SCOPE_IDENTITY()
	END
	
	
	-------------START THE INSERT-------------
	SET @result = 1
	
	BEGIN TRY
		BEGIN TRANSACTION

		UPDATE tblSMApproval SET ysnCurrent = 0 WHERE intTransactionId = @intTransactionId
		UPDATE tblSMTransaction SET strApprovalStatus = @status WHERE intTransactionId = @intTransactionId
		SELECT @intOrder = MAX(intOrder) FROM tblSMApproval WHERE intTransactionId = @intTransactionId
		INSERT INTO tblSMApproval (
			intTransactionId,
			intScreenId,
			dtmDate,
			dblAmount,
			dtmDueDate,
			intApproverId,
			intSubmittedById,
			strStatus,
			ysnCurrent,
			ysnVisible,
			intOrder,
			strComment
		)
		VALUES (
			@intTransactionId,
			@intScreenId,
			GETUTCDATE(),
			0,
			GETUTCDATE(),
			NULL,
			@intEntityId,
			@status,
			1,
			1,
			ISNULL(@intOrder, 0) + 1,
			ISNULL(@remarks, 'Integration')
		)


		--ROLLBACK TRANSACTION
		COMMIT TRANSACTION
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorSeverity INT,
				@ErrorNumber   INT,
				@ErrorMessage nvarchar(4000),
				@ErrorState INT,
				@ErrorLine  INT,
				@ErrorProc nvarchar(200);

		-- Grab error information from SQL functions
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorNumber   = ERROR_NUMBER()
		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorState    = ERROR_STATE()
		SET @ErrorLine     = ERROR_LINE()

		ROLLBACK TRANSACTION

		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
		SET @result = 0
	END CATCH

	RETURN @result
END