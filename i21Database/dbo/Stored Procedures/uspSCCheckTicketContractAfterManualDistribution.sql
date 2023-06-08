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
	DECLARE @intStorageScheduleTypeId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intLoadId INT

	SELECT TOP 1
		@intTicketContractDetailId = intContractId
		,@dblTicketScheduleQty = dblScheduleQty
		,@intTicketItemUOM = intItemUOMIdTo
		,@intStorageScheduleTypeId = intStorageScheduleTypeId

		,@intLoadDetailId = intLoadDetailId
		,@intLoadId = intLoadId
	FROM tblSCTicket 
	WHERE intTicketId = @intTicketId
		--and intStorageScheduleTypeId = -2 -- CONTRACT DISTRIBUTION TYPE
		AND (intTicketTypeId <> 9)
		
	IF @intStorageScheduleTypeId = -2
	BEGIN
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
	ELSE IF @intStorageScheduleTypeId = -6
	BEGIN
		
		IF NOT EXISTS(SELECT TOP 1 1 
						FROM tblSCTicketLoadUsed 
						WHERE intTicketId = @intTicketId
							AND intLoadDetailId = @intLoadDetailId 		
		)
		BEGIN
			IF ISNULL(@dblTicketScheduleQty,0) > 0 AND ISNULL(@intTicketContractDetailId,0) > 0
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
