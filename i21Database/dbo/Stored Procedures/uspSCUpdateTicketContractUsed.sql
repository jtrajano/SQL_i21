CREATE PROCEDURE [dbo].[uspSCUpdateTicketContractUsed]
	@intTicketId INT,
	@intContractDetailId INT,
	@dblScheduleQty DECIMAL(38,20),
	@ysnStorage int = null
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY
	IF NOT EXISTS(SELECT intContractDetailId FROM tblSCTicketContractUsed WHERE intTicketId = @intTicketId AND intContractDetailId = @intContractDetailId)
	BEGIN
		INSERT INTO tblSCTicketContractUsed (intTicketId,intContractDetailId,dblScheduleQty)
		VALUES(@intTicketId,@intContractDetailId,@dblScheduleQty)
	END
	IF(ISNULL(@ysnStorage,0) = 0)
		BEGIN
			UPDATE tblSCTicket SET intContractId = @intContractDetailId WHERE intTicketId = @intTicketId AND ISNULL(intContractId,0) = 0
			UPDATE tblSCTicket SET strContractNumber = CT.strContractNumber
			, intContractSequence = CT.intContractSeq
			, strContractLocation = CT.strLocationName
			, dblScheduleQty = @dblScheduleQty
			, dblUnitPrice = CT.dblFutures
			, dblUnitBasis = CT.dblBasis
			FROM tblSCTicket SC INNER JOIN vyuCTContractDetailView CT ON SC.intContractId = CT.intContractDetailId 
			WHERE intTicketId = @intTicketId AND SC.intContractId = @intContractDetailId
		END
	ELSE
	BEGIN
		UPDATE tblSCTicket SET intContractId = @intContractDetailId WHERE intTicketId = @intTicketId AND ISNULL(intContractId,0) = 0
		UPDATE tblSCTicket SET strContractNumber = CT.strContractNumber , intContractSequence = CT.intContractSeq, strContractLocation = CT.strLocationName
		FROM tblSCTicket SC INNER JOIN vyuCTContractDetailView CT ON SC.intContractId = CT.intContractDetailId 
		WHERE intTicketId = @intTicketId AND SC.intContractId = @intContractDetailId
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