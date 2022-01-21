CREATE PROCEDURE [dbo].[uspSCCheckTicketContractAfterManualDistribution]
	@intTicketId INT
	,@intUserId INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS ON


	DECLARE @intTicketContractDetailId INT
	DECLARE @dblTicketScheduleQty NUMERIC(18,6)
	DECLARE @intTicketItemUOM INT

	SELECT TOP 1
		@intTicketContractDetailId = intContractId
		,@dblTicketScheduleQty = dblScheduleQty
		,@intTicketItemUOM = intItemUOMIdTo
	FROM tblSCTicket 
	WHERE intTicketId = @intTicketId
		and intStorageScheduleTypeId = -2 -- CONTRACT DISTRIBUTION TYPE

	IF(ISNULL(@intTicketContractDetailId,0) > 0)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCTicketContractUsed WHERE intTicketId = @intTicketId
			AND intContractDetailId = @intTicketContractDetailId
		)
		BEGIN
			IF ISNULL(@dblTicketScheduleQty,0) > 0
			BEGIN
				SET @dblTicketScheduleQty = @dblTicketScheduleQty * -1

				EXEC	uspCTUpdateScheduleQuantity 
				@intContractDetailId	=	@intTicketContractDetailId,
				@dblQuantityToUpdate	=	@dblTicketScheduleQty,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intTicketId,
				@strScreenName			=	'Auto - Scale'
			END
		END
	END
END
GO
