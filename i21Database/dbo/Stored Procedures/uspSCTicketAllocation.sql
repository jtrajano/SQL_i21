CREATE PROCEDURE uspSCConsolidateTicketUsedBy
	@TICKET_ID INT

AS
BEGIN

	DECLARE @ALLOCATION_CONTRACT INT = 1
	DECLARE @ALLOCATION_LOAD INT = 2
	DECLARE @ALLOCATION_STORAGE INT = 3
	DECLARE @ALLOCATION_SPOT INT = 4
	
	INSERT INTO tblSCTicketDistributionAllocation(
		intTicketId
		,intSourceId
		,intSourceType
	)
	--LOAD ALLOCATION
	SELECT 
		intTicketId = intTicketId
		,intSourceId = intTicketLoadUsedId
		,intSourceType = @ALLOCATION_LOAD
	FROM tblSCTicketLoadUsed
	WHERE intTicketId = @TICKET_ID

	UNION ALL
	--CONTRACT ALLOCATION
	SELECT 
		intTicketId = intTicketId
		,intSourceId = intTicketContractUsed
		,intSourceType = @ALLOCATION_CONTRACT
	FROM tblSCTicketContractUsed
	WHERE intTicketId = @TICKET_ID
	UNION ALL
	--STORAGE ALLOCATION
	SELECT 
		intTicketId = intTicketId
		,intSourceId = intTicketStorageUsedId
		,intSourceType = @ALLOCATION_STORAGE
	FROM tblSCTicketStorageUsed
	WHERE intTicketId = @TICKET_ID
	
	UNION ALL
	--SPOT ALLOCATION
	SELECT 
		intTicketId = intTicketId
		,intSourceId = intTicketSpotUsedId
		,intSourceType = @ALLOCATION_SPOT
	FROM tblSCTicketSpotUsed
	WHERE intTicketId = @TICKET_ID
END

GO