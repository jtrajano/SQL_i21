﻿CREATE PROCEDURE [dbo].[uspSCCreateInvoiceForPostedDestinationWeightsAndGrades]
	@intTicketId INT,
	@intUserId INT,
	@intInvoiceId INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg NVARCHAR(MAX);

DECLARE @ysnTicketDestinationWeightAndGradesPosted BIT
DECLARE @ysnTicketEntityId INT
DECLARE @ysnTicketLocationId INT
DECLARE @strTicketInOutFlag NVARCHAR(3)
DECLARE @intTicketType INT

BEGIN TRY
	SET @ysnTicketDestinationWeightAndGradesPosted = 0
	
	SELECT TOP 1
		@ysnTicketDestinationWeightAndGradesPosted = ysnDestinationWeightGradePost
		,@ysnTicketEntityId = intEntityId
		,@ysnTicketLocationId = intProcessingLocationId
		,@intTicketType = intTicketType
		,@strTicketInOutFlag = strInOutFlag
	FROM tblSCTicket
	WHERE intTicketId = @intTicketId

	IF(@strTicketInOutFlag = 'O' AND @intTicketType = 6)
	BEGIN
		IF(@ysnTicketDestinationWeightAndGradesPosted = 1)
		BEGIN
			EXEC uspSCDirectCreateInvoice @intTicketId, @ysnTicketEntityId, @ysnTicketLocationId, @intUserId, @intInvoiceId OUTPUT
		END
	END

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH