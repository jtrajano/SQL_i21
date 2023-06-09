CREATE PROCEDURE [dbo].[uspSCTicketApplyUnpost]
	@intTicketApplyId INT,
	@intUserId INT 
AS 
BEGIN
/*
	Process flow
	- First check all the ticket on the hold apply and make sure that all tickets in the ticket apply is not redistributed outside of ticket apply process
	- if validation pass, 
	- 1. lock the ticket for processing
	- 2. undistribute the ticket
	- 3. update the ticket status to 'R' and distribution option to Hold
	- 4. distribute the ticket to Hold
	- 5. log to ticket history
	- 6. unlock the ticket
	= 
*/
	

	DECLARE @TICKET_APPLY_ID INT = @intTicketApplyId
	DECLARE @ENTITY_USER_NAME NVARCHAR(100)
	-- user invoked the process
	DECLARE @USER_ID INT = @intUserId


	SELECT @ENTITY_USER_NAME = strName FROM tblEMEntity WHERE intEntityId = @intUserId

	DECLARE @TICKET_INFORMATION TABLE(
		ID INT IDENTITY(1,1),
		TICKET_ID INT,
		TICKET_STATUS NVARCHAR(5),
		TICKET_ENTITY INT,
		TICKET_INDICATOR NVARCHAR(1),
		NET_UNIT NUMERIC(38, 20) NULL,
		TICKET_NUMBER NVARCHAR(50) 
	)

	-- LOG INFORMATION
	INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
	SELECT @TICKET_APPLY_ID, 'Unposting process started', @ENTITY_USER_NAME, @USER_ID


	INSERT INTO @TICKET_INFORMATION(TICKET_ID, TICKET_STATUS, TICKET_ENTITY, TICKET_INDICATOR, NET_UNIT, TICKET_NUMBER)
	SELECT 
		TICKET_APPLY.intTicketId,
		TICKET.strTicketStatus,
		TICKET.intEntityId,
		TICKET.strInOutFlag,
		TICKET.dblNetUnits,
		TICKET.strTicketNumber
	FROM tblSCTicketApplyTicket TICKET_APPLY
		JOIN tblSCTicket TICKET
			ON TICKET_APPLY.intTicketId = TICKET.intTicketId
	WHERE intTicketApplyId = @intTicketApplyId

	-- ticket validation
	IF EXISTS(SELECT TOP 1 1 FROM @TICKET_INFORMATION WHERE TICKET_STATUS <> 'C')
	BEGIN
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID, 'Unposting process finished with error (Some of the tickets are not completed, cannot proceed with the unposting.)', @ENTITY_USER_NAME, @USER_ID
		RAISERROR ('Some of the tickets are not completed, cannot proceed with the unposting.', 16, 1);
	END

	DECLARE @CURRENT_TICKET_INDEX INT = 0
	DECLARE @CURRENT_TICKET_ID INT
	DECLARE @CURRENT_ENTITY_ID INT 
	DECLARE @CURRENT_TICKET_INDICATOR NVARCHAR(1)
	DECLARE @CURRENT_TICKET_NUMBER NVARCHAR(50)
	DECLARE @CURRENT_NET_UNIT NUMERIC(38, 20) 

	SELECT @CURRENT_TICKET_INDEX = MIN (ID)
	FROM @TICKET_INFORMATION

	WHILE @CURRENT_TICKET_INDEX IS NOT NULL
	BEGIN
		-- clear the vaiables
		SELECT @CURRENT_ENTITY_ID = NULL						
			, @CURRENT_TICKET_ID = NULL
			, @CURRENT_TICKET_INDICATOR = '' 
			, @CURRENT_NET_UNIT = NULL
			, @CURRENT_TICKET_NUMBER = ''
		-- set loop variable
		SELECT 
			@CURRENT_ENTITY_ID = TICKET_ENTITY
			, @CURRENT_TICKET_ID = TICKET_ID
			, @CURRENT_TICKET_INDICATOR = TICKET_INDICATOR
			, @CURRENT_NET_UNIT = NET_UNIT
			, @CURRENT_TICKET_NUMBER = TICKET_NUMBER
		FROM @TICKET_INFORMATION 
			WHERE ID = @CURRENT_TICKET_INDEX
	
		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Locking the ticket for processing-' + @CURRENT_TICKET_NUMBER
			, @ENTITY_USER_NAME
			, @USER_ID
		-- 1. lock the ticket for processing	
		-- mark the ticket for processing
		EXEC uspSCCheckUpdateTicketProcessed 
			@intTicketId = @CURRENT_TICKET_ID
			, @intUserId = @USER_ID
			, @ysnStartProcess = 1


		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Ticket undistribution-' + @CURRENT_TICKET_NUMBER
			, @ENTITY_USER_NAME
			, @USER_ID

		-- 2. undistribute the ticket
		EXEC [dbo].[uspSCUndistributeTicket] 
			@intTicketId = @CURRENT_TICKET_ID
			, @intUserId = @USER_ID
			, @intEntityId = @CURRENT_ENTITY_ID
			, @strInOutFlag = @CURRENT_TICKET_INDICATOR

			
		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Updating ticket information and set it back to hold-' + @CURRENT_TICKET_NUMBER
			, @ENTITY_USER_NAME
			, @USER_ID
		-- 3. update the ticket status to 'R' and distribution option to Hold
		UPDATE tblSCTicket
			SET  strTicketStatus = 'R'
			, strDistributionOption = 'HLD'
			, intStorageScheduleTypeId = -5
		WHERE intTicketId = @CURRENT_TICKET_ID


		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Ticket hold distribution-' + @CURRENT_TICKET_NUMBER
			, @ENTITY_USER_NAME
			, @USER_ID

		-- 4. distribute the ticket to Hold
		
		EXEC [dbo].[uspSCProcessHoldTicket] 
			@intTicketId = @CURRENT_TICKET_ID
			, @intEntityId = @CURRENT_ENTITY_ID
			, @dblNetUnits = @CURRENT_NET_UNIT
			, @intUserId = @USER_ID
			, @strInOutFlag = @CURRENT_TICKET_INDICATOR
			, @ysnPost  = 1

		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Ticket history log-' + @CURRENT_TICKET_NUMBER
			, @ENTITY_USER_NAME
			, @USER_ID
		-- 5. log to ticket history
		
		INSERT INTO tblSCTicketHistory(intTicketId, intEntityId, dtmTicketHistoryDate, dblSplitPercent, dblQuantity, intStorageScheduleTypeId)
		SELECT @CURRENT_TICKET_ID, @CURRENT_ENTITY_ID, GETDATE(), 100, @CURRENT_NET_UNIT, -3		

		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Unlocking the ticket-' + @CURRENT_TICKET_NUMBER
			, @ENTITY_USER_NAME
			, @USER_ID
		-- 6. unlock the ticket	
		
		EXEC uspSCCheckUpdateTicketProcessed 
			@intTicketId = @CURRENT_TICKET_ID
			, @intUserId = @USER_ID
			, @ysnStartProcess = 0

		SELECT @CURRENT_TICKET_INDEX = MIN (ID)
		FROM @TICKET_INFORMATION
		WHERE ID > @CURRENT_TICKET_INDEX


	END



	-- update the post value of the ticket apply
	UPDATE tblSCTicketApply
		SET ysnPosted = 0
			, dtmPosted = NULL
			, intEntityUserId = @USER_ID
	WHERE intTicketApplyId = @TICKET_APPLY_ID
	
	-- log information
	INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
	SELECT @TICKET_APPLY_ID, 'Ticket unposting process completed', @ENTITY_USER_NAME, @USER_ID
END