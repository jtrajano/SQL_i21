CREATE PROCEDURE [dbo].[uspSCProcessTicketApply]
	@UnitAllocation ScaleManualDistributionAllocation READONLY,
	@intTicketId INT,
	@intUserId INT,
	@intInvoiceId INT OUTPUT

AS
BEGIN
	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS ON  

	
	DECLARE @strTransactionId NVARCHAR(50)
	DECLARE @intInventoryShipmentId INT
	DECLARE @dtmClientDate DATETIME


	SET @dtmClientDate = GETDATE()

	----Contract
	INSERT INTO tblSCTicketContractUsed(
		intTicketId
		,intContractDetailId
		,intEntityId
		,dblScheduleQty
	)
	SELECT
		intTicketId = @intTicketId
		,intContractDetailId = intContractDetailId
		,intEntityId = intEntityId
		,dblScheduleQty = dblQuantity
	FROM @UnitAllocation
	WHERE intAllocationType = 3

	-- Spot
	-- Delete entry from distribution of in-transit status this will be replaced by the Allocation int ticket applied screen
	DELETE FROM tblSCTicketSpotUsed WHERE intTicketId = @intTicketId


	INSERT INTO tblSCTicketSpotUsed(
		intTicketId
		,intEntityId
		,dblQty
		,dblUnitFuture
		,dblUnitBasis
	)
	SELECT 
		intTicketId = @intTicketId
		,intEntityId = intEntityId
		,dblQty = dblQuantity
		,dblUnitFuture = dblFuture
		,dblUnitBasis = dblBasis
	FROM @UnitAllocation
	WHERE intAllocationType = 4 

	SELECT TOP 1 
		@intInventoryShipmentId = A.intInventoryShipmentId
	FROM tblICInventoryShipment A
	INNER JOIN tblICInventoryShipmentItem B
		ON A.intInventoryShipmentId = B.intInventoryShipmentId
	WHERE A.intSourceType = 1
		AND B.intSourceId = @intTicketId

	-- TODO add parameter for ticket in-transit
	EXEC dbo.uspARCreateInvoiceFromShipment @intInventoryShipmentId, @intUserId, @intInvoiceId OUT, 0, 1 ,@dtmShipmentDate = @dtmClientDate, @intScaleTicketId = @intTicketId;

	EXEC dbo.uspSMAuditLog 
		@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
		,@screenName		= 'Grain.view.Scale'		-- Screen Namespace
		,@entityId			= @intUserId				-- Entity Id.
		,@actionType		= 'Updated'					-- Action Type
		,@changeDescription	= 'Ticket Applied'		-- Description
		,@fromValue			= ''						-- Old Value
		,@toValue			= @strTransactionId			-- New Value
		,@details			= '';
	
	UPDATE tblSCTicket
	SET ysnTicketApplied = 1
		,dtmDateModifiedUtc = GETUTCDATE()
	WHERE intTicketId = @intTicketId
END



