CREATE PROCEDURE [dbo].[uspSCTicketApplyCreateTransparency]
	@intTicketApplyId INT
AS
BEGIN
/*
	Purpose:
	- Create unit allocation for tickets based on the assigned units per contract / storage / spot
*/


	SET NOCOUNT ON
	

	DECLARE @TICKET_APPLY_ID INT = @intTicketApplyId
	DECLARE @TOTAL_APPLIED_UNITS NUMERIC(38, 20)
	DECLARE @TOTAL_TICKET_UNITS NUMERIC(38, 20)

	-- VALIDATION
	-- checks if the total units of ticket matches the total units for allocation
	-- allocation units
	SELECT @TOTAL_APPLIED_UNITS = SUM(dblUnit) 
		FROM (
			SELECT dblUnit FROM tblSCTicketApplyContract WHERE intTicketApplyId = @TICKET_APPLY_ID
			UNION ALL 
			SELECT dblUnit FROM tblSCTicketApplySpot WHERE intTicketApplyId = @TICKET_APPLY_ID
			UNION ALL 
			SELECT dblUnit FROM tblSCTicketApplyStorage WHERE intTicketApplyId = @TICKET_APPLY_ID
		) APPLIED_UNIT

	-- ticket units
	SELECT @TOTAL_TICKET_UNITS  = SUM(dblUnit) FROM tblSCTicketApplyTicket WHERE intTicketApplyId  = @TICKET_APPLY_ID

	-- check if either the ticket is zero or the applied unit is zero
	-- we have nothing to do if one of them is zero
	IF ISNULL(@TOTAL_TICKET_UNITS, 0) = 0 OR ISNULL(@TOTAL_APPLIED_UNITS, 0) = 0
	BEGIN
		RAISERROR ('Ticket is not applied correctly. Either Ticket does not have units or there is no unit allocations.', 16, 1);
	END

	IF @TOTAL_TICKET_UNITS <> @TOTAL_APPLIED_UNITS
	BEGIN
		RAISERROR ('Ticket units does not match applied units.', 16, 1);
	END

	-- we do not need these variables now, set them to null
	SELECT @TOTAL_APPLIED_UNITS = NULL, @TOTAL_TICKET_UNITS = NULL

	-- temporary table for contract units
	DECLARE @CONTRACT TABLE(
		IDTN INT IDENTITY(1,1),
		ID INT,
		UNIT NUMERIC(38, 20)
	)
	-- temporary table for spot
	DECLARE @SPOT TABLE(
		IDTN INT IDENTITY(1,1),
		ID INT,
		UNIT NUMERIC(38, 20)
	)
	-- temporary table for storage
	DECLARE @STORAGE TABLE(
		IDTN INT IDENTITY(1,1),
		ID INT,
		UNIT NUMERIC(38, 20)
	)
	-- temporary table tickets
	DECLARE @TICKET TABLE(
		ID INT,
		UNIT NUMERIC(38, 20)
	)

	-- get all the contract allocation
	INSERT INTO @CONTRACT(ID, UNIT)
	SELECT 		
		intTicketApplyContractId 
		, dblUnit
	FROM tblSCTicketApplyContract
	WHERE intTicketApplyId = @TICKET_APPLY_ID

	-- get all the spot allocation
	INSERT INTO @SPOT
	SELECT 
		intTicketApplySpotId
		, dblUnit
	FROM tblSCTicketApplySpot
	WHERE intTicketApplyId = @TICKET_APPLY_ID

	-- get all the storage allocation
	INSERT INTO @STORAGE
	SELECT 
		intTicketApplyStorageId
		, dblUnit
	FROM tblSCTicketApplyStorage
	WHERE intTicketApplyId = @TICKET_APPLY_ID 
	AND dblUnit IS NOT NULL

	-- get all the tickets
	INSERT INTO @TICKET(ID, UNIT)
	SELECT 
		intTicketApplyTicketId 
		, dblUnit
	FROM tblSCTicketApplyTicket
	WHERE intTicketApplyId = @TICKET_APPLY_ID


	-- loop variables 

	DECLARE @CURRENT_TICKET_APPLY_ID INT 
	DECLARE @CURRENT_UNIT NUMERIC(38, 20)
	-- these are the id per unit allocations
	DECLARE @LOOP_ID INT
	DECLARE @LOOP_UNIT NUMERIC(38, 20)
	DECLARE @LOOP_TYPE INT 
	DECLARE @LOOP_ALLOCATION NUMERIC(38, 20)

	-- getting the starting point of the loop
	SELECT 	
		@CURRENT_TICKET_APPLY_ID = MIN(ID) 	
	FROM @TICKET


	WHILE @CURRENT_TICKET_APPLY_ID IS NOT NULL
	BEGIN
		-- get the ticket unit for allocation
		SELECT @CURRENT_UNIT = UNIT 
		FROM @TICKET WHERE ID = @CURRENT_TICKET_APPLY_ID

		-- make sure that before moving to the next ticket
		-- the current units are allocated
		WHILE @CURRENT_UNIT > 0 
		BEGIN

			-- clear all the loop variable
			SELECT @LOOP_ID = NULL
				,@LOOP_UNIT = NULL
				,@LOOP_TYPE = NULL

			-- get units from contract allocation
			IF EXISTS( SELECT TOP 1 1 FROM @CONTRACT)
			BEGIN
				SELECT TOP 1
					@LOOP_ID = ID
					,@LOOP_UNIT = UNIT
					,@LOOP_TYPE = 1
				FROM @CONTRACT
				ORDER BY IDTN

			END
			-- get units from storage allocation
			ELSE IF EXISTS( SELECT TOP 1 1 FROM @STORAGE)
			BEGIN
				SELECT TOP 1
					@LOOP_ID = ID
					,@LOOP_UNIT = UNIT
					,@LOOP_TYPE = 3
				FROM @STORAGE
				ORDER BY IDTN

			END
			-- get units from spot allocatinon
			ELSE IF EXISTS(SELECT TOP 1 1 FROM @SPOT)
			BEGIN

				SELECT TOP 1
					@LOOP_ID = ID
					,@LOOP_UNIT = UNIT
					,@LOOP_TYPE = 2
				FROM @SPOT
				ORDER BY IDTN

			END

			--balance and check to zero out the current unit
			IF(@CURRENT_UNIT > @LOOP_UNIT)
			BEGIN
				SET @LOOP_ALLOCATION = @LOOP_UNIT				
			END
			ELSE
			BEGIN
				SET @LOOP_ALLOCATION = @CURRENT_UNIT
			END

			-- update the current unit
			SET @CURRENT_UNIT = @CURRENT_UNIT - @LOOP_ALLOCATION
			
			-- this part updates the unit allocation for 
			-- it inserts data to the ticket apply ** alocation table to be used to create manual distribution scripts
			-- it delete allocation unit that does not have any units left 
			-- ** contract 
			IF @LOOP_TYPE = 1
			BEGIN				
				UPDATE @CONTRACT SET UNIT = UNIT - @LOOP_ALLOCATION WHERE ID = @LOOP_ID
				DELETE FROM @CONTRACT WHERE UNIT = 0


				INSERT INTO tblSCTicketApplyContractAllocation(intTicketApplyTicketId, intTicketApplyContractId, dblUnit)
				SELECT @CURRENT_TICKET_APPLY_ID, @LOOP_ID, @LOOP_ALLOCATION

			END
			-- ** storage
			ELSE IF @LOOP_TYPE = 2
			BEGIN
				UPDATE @SPOT SET UNIT = UNIT - @LOOP_ALLOCATION WHERE ID = @LOOP_ID
				DELETE FROM @SPOT WHERE UNIT = 0


				INSERT INTO tblSCTicketApplySpotAllocation(intTicketApplyTicketId, intTicketApplySpotId, dblUnit)
				SELECT @CURRENT_TICKET_APPLY_ID, @LOOP_ID, @LOOP_ALLOCATION
			END	
			-- ** spot
			ELSE IF @LOOP_TYPE = 3
			BEGIN
				UPDATE @STORAGE SET UNIT = UNIT - @LOOP_ALLOCATION WHERE ID = @LOOP_ID
				DELETE FROM @STORAGE WHERE UNIT = 0


				INSERT INTO tblSCTicketApplyStorageAllocation(intTicketApplyTicketId, intTicketApplyStorageId, dblUnit)
				SELECT @CURRENT_TICKET_APPLY_ID, @LOOP_ID, @LOOP_ALLOCATION
			END	

			-- clears the loop variable
			SELECT @LOOP_ID = NULL
				,@LOOP_UNIT = NULL
				,@LOOP_TYPE = NULL

		END
		

		-- after the units are fully allocated , move to the next ticket 
		SELECT @CURRENT_TICKET_APPLY_ID = MIN(ID) 
		FROM @TICKET 
		WHERE ID > @CURRENT_TICKET_APPLY_ID
	END
	
	SELECT 
		@CURRENT_TICKET_APPLY_ID = NULL
		, @CURRENT_UNIT = NULL
		

	

END
 
GO