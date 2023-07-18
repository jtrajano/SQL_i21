CREATE PROCEDURE [dbo].[uspSCTicketApplyProcessForIntransit]
	@TICKET_APPLY_ID INT,
	@USER_ID INT 
AS

	SET NOCOUNT ON

	--user defined table to hold the distribution allocation
	DECLARE @TEMP_HOLDING_TABLE AS ScaleManualDistributionAllocation
			
	-- temp table tp list all ticket for ticket apply process
	DECLARE @TICKET_APPLY_TICKET_ID AS TABLE(
		ID INT
		,TICKET_ID INT
		,TICKET_NUMBER NVARCHAR(40)
	)

	INSERT INTO @TICKET_APPLY_TICKET_ID(ID, TICKET_ID, TICKET_NUMBER)
	SELECT 
		TICKET_APPLY.intTicketApplyTicketId
		, TICKET_APPLY.intTicketId 
		, TICKET.strTicketNumber
	FROM tblSCTicketApplyTicket TICKET_APPLY
		JOIN tblSCTicket TICKET
			ON TICKET_APPLY.intTicketId = TICKET.intTicketId
	WHERE intTicketApplyId = @TICKET_APPLY_ID

	--loop variables
	DECLARE @CURRENT_TICKET_APPLY_ID INT
	DECLARE @CURRENT_TICKET_ID INT
	DECLARE @CURRENT_TICKET_NUMBER NVARCHAR(40)


	-- get the first ticket to process
	SELECT @CURRENT_TICKET_APPLY_ID  = MIN(ID) 
	FROM @TICKET_APPLY_TICKET_ID

	--variable used for the procedure
	DECLARE @INVOICE_OUT INT
	DECLARE @TICKET_ID INT

	-- user information
	DECLARE @ENTITY_USER_NAME NVARCHAR(100)
	SELECT @ENTITY_USER_NAME = strName FROM tblEMEntity WHERE intEntityId = @USER_ID

	-- log information
	INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
	SELECT @TICKET_APPLY_ID, 'Ticket apply process started', @ENTITY_USER_NAME, @USER_ID

	WHILE @CURRENT_TICKET_APPLY_ID  IS NOT NULL
	BEGIN

		-- get the ticket id
		SELECT @CURRENT_TICKET_ID = TICKET_ID 
			, @CURRENT_TICKET_NUMBER = TICKET_NUMBER
		FROM @TICKET_APPLY_TICKET_ID 
		WHERE ID = @CURRENT_TICKET_APPLY_ID
	
		--clear the hoolding table
		DELETE FROM @TEMP_HOLDING_TABLE	
	
		
		--log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID, 'Ticket application process started - ' + LTRIM(@CURRENT_TICKET_NUMBER), @ENTITY_USER_NAME, @USER_ID


		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Locking the ticket for processing'
			, @ENTITY_USER_NAME
			, @USER_ID

		-- mark the ticket for processing
		EXEC uspSCCheckUpdateTicketProcessed 
			@intTicketId = @CURRENT_TICKET_ID
			, @intUserId = @USER_ID
			, @ysnStartProcess = 1


		--log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID, 'Allocation process started', @ENTITY_USER_NAME, @USER_ID

		--create contract allocation
		INSERT INTO @TEMP_HOLDING_TABLE(intAllocationType, dblQuantity, intEntityId, intContractDetailId)
		SELECT 3, CONTRACT_ALLOCATION.dblUnit, TICKET_APPLY.intEntityId, CONTRACT_T.intContractDetailId
			FROM tblSCTicketApplyContractAllocation CONTRACT_ALLOCATION
				JOIN tblSCTicketApplyContract CONTRACT_T
					ON CONTRACT_ALLOCATION.intTicketApplyContractId = CONTRACT_T.intTicketApplyContractId
				JOIN tblSCTicketApply TICKET_APPLY
					ON CONTRACT_T.intTicketApplyId = TICKET_APPLY.intTicketApplyId

		WHERE  CONTRACT_ALLOCATION.intTicketApplyTicketId = @CURRENT_TICKET_APPLY_ID


		--create spot allocation
		INSERT INTO @TEMP_HOLDING_TABLE(intAllocationType, dblQuantity, intEntityId, dblBasis, dblFuture)
		SELECT 4, SPOT_ALLOCATION.dblUnit, TICKET_APPLY.intEntityId, SPOT.dblBasis, SPOT.dblFutures
			FROM tblSCTicketApplySpotAllocation SPOT_ALLOCATION
				JOIN tblSCTicketApplySpot SPOT
					ON SPOT_ALLOCATION.intTicketApplySpotId = SPOT.intTicketApplySpotId
				JOIN tblSCTicketApply TICKET_APPLY
					ON SPOT.intTicketApplyId = TICKET_APPLY.intTicketApplyId

		WHERE  SPOT_ALLOCATION.intTicketApplyTicketId = @CURRENT_TICKET_APPLY_ID


		--log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID, 'Allocation process finished', @ENTITY_USER_NAME, @USER_ID

		DECLARE @CNT INT = 0

		UPDATE @TEMP_HOLDING_TABLE SET intCntId = @CNT, @CNT = @CNT + 1	

		SELECT @TICKET_ID = @CURRENT_TICKET_ID


	
		--log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID, 'Execute in-transit apply process started', @ENTITY_USER_NAME, @USER_ID

		
		-- execute in transit ticket apply 
		EXEC [dbo].[uspSCProcessTicketApply] 
			@UnitAllocation = @TEMP_HOLDING_TABLE,
			@intTicketId = @TICKET_ID, --
			@intUserId = @USER_ID,
			@intInvoiceId = @INVOICE_OUT OUTPUT
				
		

		
		-- log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID
			, 'Release the ticket from processing lock'
			, @ENTITY_USER_NAME
			, @USER_ID
		
		-- release the ticket from processing
		EXEC uspSCCheckUpdateTicketProcessed 
			@intTicketId = @CURRENT_TICKET_ID
			, @intUserId = @USER_ID
			, @ysnStartProcess = 0


		--log information
		INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
		SELECT @TICKET_APPLY_ID, 'Ticket application process finished - ' + LTRIM(@CURRENT_TICKET_NUMBER), @ENTITY_USER_NAME, @USER_ID
		SELECT @CURRENT_TICKET_APPLY_ID  = MIN(ID) 
		FROM @TICKET_APPLY_TICKET_ID
		WHERE ID > @CURRENT_TICKET_APPLY_ID

	END

	-- update the post value of the ticket apply
	UPDATE tblSCTicketApply
		SET ysnPosted = 1
			, dtmPosted = GETDATE()
			, intEntityUserId = @USER_ID
	WHERE intTicketApplyId = @TICKET_APPLY_ID
	
	-- log information
	INSERT INTO tblSCTicketApplyLog(intTicketApplyId, strLogCase1, strEntityName, intEntityId)
	SELECT @TICKET_APPLY_ID, 'Ticket apply process finished', @ENTITY_USER_NAME, @USER_ID


RETURN 0
