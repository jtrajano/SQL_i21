CREATE PROCEDURE [dbo].uspSCProcessTicketWithBasisContract
	@intTicketId  INT 
	,@intUserId INT
	,@ysnThrowError BIT = 0
	,@strErrorMessage NVARCHAR(MAX) OUTPUT
	,@intCreatedTransactionId INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @intEntityId INT
DECLARE	@intLocationId INT
DECLARE	@dtmScaleDate DATETIME
DECLARE @strTicketInOutFlag NVARCHAR(2)



BEGIN TRY
	IF @transCount = 0 BEGIN TRANSACTION

	----CREATE VOUCHER/INVOICE
	BEGIN
		SELECT TOP 1 
			@intEntityId = intEntityId
			,@intLocationId = intProcessingLocationId
			,@dtmScaleDate = dtmTicketDateTime
			,@strTicketInOutFlag = strInOutFlag
		FROM tblSCTicket
		WHERE intTicketId = @intTicketId

		IF(@strTicketInOutFlag = 'I')
		BEGIN
			EXEC uspSCDirectCreateVoucher
					@intTicketId = @intTicketId
					,@intEntityId = @intEntityId
					,@intLocationId = @intLocationId
					,@dtmScaleDate = @dtmScaleDate
					,@intUserId = @intUserId
					,@intBillId = @intCreatedTransactionId OUTPUT
		END
		ELSE
		BEGIN
			EXEC uspSCDirectCreateInvoice
					@intTicketId = @intTicketId
					,@intEntityId = @intEntityId
					,@intLocationId = @intLocationId
					,@intUserId = @intUserId
					,@intBillId = @intCreatedTransactionId OUTPUT
		END

		IF(ISNULL(@intCreatedTransactionId,0) > 0)
		BEGIN
			UPDATE tblSCTicketDirectBasisContract 
			SET ysnProcessed =1
			WHERE intTicketId = @intTicketId
		END
	END

	IF @transCount = 0 COMMIT TRAN
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	SET @strErrorMessage = @ErrorMessage

	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	IF(@ysnThrowError = 1) 
	BEGIN
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		);
	END
END CATCH
GO