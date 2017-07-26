CREATE PROCEDURE [dbo].[uspSCUpdateStatus]
    @scId INT,
	@status INT = NULL
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	CREATE TABLE #tmpSC(intTicketId INT)
	DECLARE @intContractDetailId INT
			,@intFromItemUOMId INT;

	IF @status IS NOT NULL
	BEGIN
		UPDATE A SET A.strTicketStatus = 
		CASE
			WHEN @status = 1 THEN 'R'
		END
		FROM tblSCTicket A
		WHERE A.intTicketId = @scId

		SELECT @intContractDetailId = intContractId, @intFromItemUOMId = intItemUOMIdTo FROM tblSCTicket where intTicketId = @scId

		UPDATE vyuCTContractDetailView set dblScheduleQty = (CT.dblScheduleQty - dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,CT.intItemUOMId,SC.dblScheduleQty))
		FROM vyuCTContractDetailView CT 
		LEFT JOIN tblSCTicketContractUsed SC ON SC.intContractDetailId = CT.intContractDetailId
		WHERE SC.intTicketId = @scId AND SC.intContractDetailId != ISNULL(@intContractDetailId,0)

		DELETE FROM tblSCTicketContractUsed WHERE intTicketId = @scId
	END
	ELSE
	BEGIN
		IF @scId > 0
		BEGIN
			INSERT INTO #tmpSC
			SELECT 
				A.intTicketId 
			FROM tblSCTicket A
			WHERE intTicketId = @scId
		END
		ELSE
		BEGIN
			INSERT INTO #tmpSC
			SELECT 
				A.intTicketId 
			FROM tblSCTicket A
		END

		UPDATE B
			SET B.strTicketStatus = (CASE	
										WHEN ISNULL(@status, 0 ) = 0
											THEN 'C' --Completed
										WHEN @status = 1
											THEN 'R' --Reopen
									END)
		FROM #tmpSC A
			INNER JOIN tblSCTicket B
				ON A.intTicketId = B.intTicketId
	END
END
