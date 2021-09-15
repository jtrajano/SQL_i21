CREATE PROCEDURE [dbo].[uspSCGetTicketDistributionAllocation]
	@intTicketId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @tmpTicketAllocationTable ScaleManualDistributionAllocation

	---SPOT
	BEGIN
		INSERT INTO @tmpTicketAllocationTable (
			[intAllocationType]
			,[dblQuantity] 
			,[intEntityId] 
			,[intContractDetailId]
			,[intLoadDetailId]  
			,[intStorageScheduleId]
			,[intStorageScheduleTypeId]
			,[dblFuture] 
			,[dblBasis] 
			,intTicketDistributionAllocationId
		)
		SELECT 
			[intAllocationType] = 4
			,[dblQuantity] = B.dblQty
			,[intEntityId] = B.intEntityId
			,[intContractDetailId] = NULL
			,[intLoadDetailId] = NULL 
			,[intStorageScheduleId] = NULL
			,[intStorageScheduleTypeId] = NULL
			,[dblFuture] = ISNULL(B.dblUnitFuture,0)
			,[dblBasis] = ISNULL(B.dblUnitBasis,0)
			,intTicketDistributionAllocationId = C.intTicketDistributionAllocationId
		FROM tblSCTicket A
		INNER JOIN tblSCTicketSpotUsed B
			ON A.intTicketId = B.intTicketId
		INNER JOIN tblSCTicketDistributionAllocation C
			ON B.intTicketSpotUsedId = C.intSourceId
				AND intSourceType = 4
		WHERE A.intTicketId = @intTicketId 
	END

	---CONTRACT
	BEGIN
		--Priced Contract
		INSERT INTO @tmpTicketAllocationTable (
			[intAllocationType]
			,[dblQuantity] 
			,[intEntityId] 
			,[intContractDetailId]
			,[intLoadDetailId]  
			,[intStorageScheduleId]
			,[intStorageScheduleTypeId]
			,[dblFuture] 
			,[dblBasis] 
			,intTicketDistributionAllocationId
		)
		SELECT 
			intAllocationType = 1
			,[dblQuantity] = B.dblScheduleQty
			,[intEntityId] = B.intEntityId
			,[intContractDetailId] = B.intContractDetailId
			,[intLoadDetailId] = NULL 
			,[intStorageScheduleId] = NULL
			,[intStorageScheduleTypeId] = NULL
			,[dblFuture] = ISNULL(C.dblFutures,0)
			,[dblBasis] = ISNULL(C.dblBasis,0)
			,intTicketDistributionAllocationId = D.intTicketDistributionAllocationId
		FROM tblSCTicket A
		INNER JOIN tblSCTicketContractUsed B
			ON A.intTicketId = B.intTicketId
		INNER JOIN tblCTContractDetail C
			ON B.intContractDetailId = C.intContractDetailId
		INNER JOIN tblSCTicketDistributionAllocation D
			ON B.intTicketContractUsed = D.intSourceId
				AND intSourceType = 1
		WHERE A.intTicketId = @intTicketId 
	END

	---LOAD
	BEGIN
		--Priced Contract
		INSERT INTO @tmpTicketAllocationTable (
			[intAllocationType]
			,[dblQuantity] 
			,[intEntityId] 
			,[intContractDetailId]
			,[intLoadDetailId]  
			,[intStorageScheduleId]
			,[intStorageScheduleTypeId]
			,[dblFuture] 
			,[dblBasis] 
			,intTicketDistributionAllocationId
		)
		SELECT 
			intAllocationType = 2
			,[dblQuantity] = B.dblQty
			,[intEntityId] = B.intEntityId
			,[intContractDetailId] = D.intContractDetailId
			,[intLoadDetailId] = B.intLoadDetailId 
			,[intStorageScheduleId] = NULL
			,[intStorageScheduleTypeId] = NULL
			,[dblFuture] = ISNULL(D.dblFutures,0)
			,[dblBasis] = ISNULL(D.dblBasis,0)
			,intTicketDistributionAllocationId = F.intTicketDistributionAllocationId
		FROM tblSCTicket A
		INNER JOIN tblSCTicketLoadUsed B
			ON A.intTicketId = B.intTicketId
		INNER JOIN tblLGLoadDetail C
			ON B.intLoadDetailId = C.intLoadDetailId
		INNER JOIN tblSCTicketDistributionAllocation F
			ON B.intTicketLoadUsedId = F.intSourceId
				AND intSourceType = 2
		LEFT JOIN tblCTContractDetail D 
			ON C.intPContractDetailId = D.intContractDetailId
		LEFT JOIN tblCTContractHeader E
			ON D.intContractHeaderId = E.intContractHeaderId
		WHERE A.intTicketId = @intTicketId 
			AND E.intPricingTypeId = 1
	END

	-- STORAGE(DP)
	BEGIN
		INSERT INTO @tmpTicketAllocationTable (
			[intAllocationType]
			,[dblQuantity] 
			,[intEntityId] 
			,[intContractDetailId]
			,[intLoadDetailId]  
			,[intStorageScheduleId]
			,[intStorageScheduleTypeId]
			,[dblFuture] 
			,[dblBasis] 
			,intTicketDistributionAllocationId
		)
		SELECT 
			intAllocationType = 3
			,[dblQuantity] = B.dblQty
			,[intEntityId] = B.intEntityId
			,[intContractDetailId] = B.intContractDetailId
			,[intLoadDetailId] = NULL 
			,[intStorageScheduleId] = B.intStorageScheduleId
			,[intStorageScheduleTypeId] = B.intStorageTypeId
			,[dblFuture] = ISNULL(C.dblFutures,0)
			,[dblBasis] = ISNULL(C.dblBasis,0)
			,intTicketDistributionAllocationId = D.intTicketDistributionAllocationId
		FROM tblSCTicket A
		INNER JOIN tblSCTicketStorageUsed B
			ON A.intTicketId = B.intTicketId
		INNER JOIN tblSCTicketDistributionAllocation D
			ON B.intTicketStorageUsedId = D.intSourceId
				AND intSourceType = 3
		LEFT JOIN tblCTContractDetail C
			ON B.intContractDetailId = C.intContractDetailId
		WHERE A.intTicketId = @intTicketId 
	END
	
	SELECT 
		[intAllocationType]
		,[dblQuantity] 
		,[intEntityId] 
		,[intContractDetailId]
		,[intLoadDetailId]  
		,[intStorageScheduleId]
		,[intStorageScheduleTypeId]
		,[dblFuture] 
		,[dblBasis] 
		,intTicketDistributionAllocationId
	FROM @tmpTicketAllocationTable
END

GO