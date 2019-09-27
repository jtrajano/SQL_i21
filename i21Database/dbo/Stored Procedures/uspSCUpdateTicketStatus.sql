﻿CREATE PROCEDURE [dbo].[uspSCUpdateTicketStatus]
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
			,@intFromItemUOMId INT
			,@intStorageScheduleTypeId INT;

	IF @status IS NOT NULL
	BEGIN
		UPDATE A SET A.strTicketStatus = 
		CASE
			WHEN @status = 1 THEN 'R'
		END
		FROM tblSCTicket A
		WHERE A.intTicketId = @scId

		SELECT @intContractDetailId = intContractId, @intFromItemUOMId = intItemUOMIdTo, @intStorageScheduleTypeId = intStorageScheduleTypeId FROM tblSCTicket where intTicketId = @scId

		-- IF ISNULL(@intContractDetailId, 0) > 0 AND (@intStorageScheduleTypeId = -2 OR @intStorageScheduleTypeId = -6)
		-- BEGIN
		DELETE FROM tblSCTicketContractUsed WHERE intTicketId = @scId
		DELETE FROM tblSCTicketLoadUsed WHERE intTicketId = @scId
		-- END
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
