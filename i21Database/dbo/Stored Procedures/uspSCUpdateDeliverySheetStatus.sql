﻿CREATE PROCEDURE [dbo].[uspSCUpdateDeliverySheetStatus]
    @dsId INT,
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
		UPDATE A SET A.ysnPost = 
		CASE
			WHEN @status = 1 THEN 0
		END
		FROM tblSCDeliverySheet A
		WHERE A.intDeliverySheetId = @dsId

		UPDATE tblSCTicket SET ysnDeliverySheetPost = 0 WHERE intDeliverySheetId = @dsId;
		--SELECT @intContractDetailId = intContractId, @intFromItemUOMId = intItemUOMIdTo FROM tblSCTicket where intTicketId = @dsId

		--UPDATE vyuCTContractDetailView set dblScheduleQty = (CT.dblScheduleQty - dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,CT.intItemUOMId,SC.dblScheduleQty))
		--FROM vyuCTContractDetailView CT 
		--LEFT JOIN tblSCTicketContractUsed SC ON SC.intContractDetailId = CT.intContractDetailId
		--WHERE SC.intTicketId = @dsId AND SC.intContractDetailId != ISNULL(@intContractDetailId,0)

		--DELETE FROM tblSCTicketContractUsed WHERE intTicketId = @dsId
	END
	ELSE
	BEGIN
		IF @dsId > 0
		BEGIN
			INSERT INTO #tmpSC
			SELECT 
				A.intDeliverySheetId 
			FROM tblSCDeliverySheet A
			WHERE intDeliverySheetId = @dsId
		END
		ELSE
		BEGIN
			INSERT INTO #tmpSC
			SELECT 
				A.intDeliverySheetId 
			FROM tblSCDeliverySheet A
		END

		UPDATE B
		SET B.ysnPost = (CASE	
							WHEN ISNULL(@status, 0) = 0
								THEN 1 --Post
							WHEN @status = 1
								THEN 0 --Unpost
						END)
		FROM #tmpSC A
			INNER JOIN tblSCDeliverySheet B
				ON A.intDeliverySheetId = B.intDeliverySheetId
	END
END
