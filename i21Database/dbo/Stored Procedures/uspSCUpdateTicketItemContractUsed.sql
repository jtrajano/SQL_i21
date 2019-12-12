CREATE PROCEDURE [dbo].[uspSCUpdateTicketItemContractUsed]
	@intTicketId INT,
	@intItemContractId INT,
	@dblQty DECIMAL(38,20),
	@intEntityId int
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
	IF(NOT EXISTS(SELECT TOP 1 1 FROM tblSCTicketItemContractUsed WHERE intTicketId = @intTicketId AND intItemContractDetailId = @intItemContractId AND intEntityId = @intEntityId))
	BEGIN 
		INSERT INTO tblSCTicketItemContractUsed (intTicketId,intItemContractDetailId,dblQty,intEntityId)
		VALUES(@intTicketId,@intItemContractId,@dblQty,@intEntityId)
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