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
		--NON BASIS/HTA CONTRACT
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
				intAllocationType = 1
				,[dblQuantity] = B.dblScheduleQty
				,[intEntityId] = B.intEntityId
				,[intContractDetailId] = B.intContractDetailId
				,[intLoadDetailId] = NULL 
				,[intStorageScheduleId] = NULL
				,[intStorageScheduleTypeId] = NULL
				,[dblFuture] = CASE WHEN E.intPricingTypeId = 6 THEN ISNULL(C.dblCashPrice,0) ELSE ISNULL(C.dblFutures,0) END
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
			INNER JOIN tblCTContractHeader E
				ON C.intContractHeaderId = E.intContractHeaderId
			WHERE A.intTicketId = @intTicketId 
				AND E.intPricingTypeId <> 2
				AND E.intPricingTypeId <> 3
		END

		--BASIS/HTA CONTRACT
		BEGIN
			
			IF OBJECT_ID('tempdb..#tmpContractTicketAllocationTable') IS NOT NULL DROP TABLE #tmpContractTicketAllocationTable

			SELECT 
				intAllocationType = 1
				,[dblQuantity] = B.dblScheduleQty
				,[intEntityId] = B.intEntityId
				,[intContractDetailId] = B.intContractDetailId
				,[intLoadDetailId] = NULL 
				,[intStorageScheduleId] = NULL
				,[intStorageScheduleTypeId] = NULL
				,[dblFuture] = (SELECT TOP 1 
									ISNULL(dblSettlementPrice,0)
								FROM dbo.fnRKGetFutureAndBasisPrice (	1
																		,A.intCommodityId
																		,RIGHT(CONVERT(VARCHAR, C.dtmEndDate, 106),8)
																		,E.intPricingTypeId
																		,C.intFutureMarketId
																		,C.intFutureMonthId
																		,NULL
																		,NULL
																		,0 
																		,A.intItemId
																		,ISNULL(C.intInvoiceCurrencyId,C.intCurrencyId)
																	)
								)
				,[dblBasis] = ISNULL(C.dblBasis,0)
				,intTicketDistributionAllocationId = D.intTicketDistributionAllocationId
			INTO #tmpContractTicketAllocationTable
			FROM tblSCTicket A
			INNER JOIN tblSCTicketContractUsed B
				ON A.intTicketId = B.intTicketId
			INNER JOIN tblCTContractDetail C
				ON B.intContractDetailId = C.intContractDetailId
			INNER JOIN tblSCTicketDistributionAllocation D
				ON B.intTicketContractUsed = D.intSourceId
					AND intSourceType = 1
			INNER JOIN tblCTContractHeader E
				ON C.intContractHeaderId = E.intContractHeaderId
			WHERE A.intTicketId = @intTicketId 
				AND (E.intPricingTypeId = 2 OR E.intPricingTypeId = 3)

			IF EXISTS(SELECT TOP 1 1 
						FROM #tmpContractTicketAllocationTable 
						WHERE dblFuture IS NULL 
							OR dblFuture = 0)
			BEGIN
				RAISERROR ('Settlement price in risk management is not available.',16,1,'WITH NOWAIT') 
			END

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
			FROM #tmpContractTicketAllocationTable
		END
	END

	---LOAD
	BEGIN
		--NON BASIS/HTA CONTRACT
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
				intAllocationType = 2
				,[dblQuantity] = B.dblQty
				,[intEntityId] = B.intEntityId
				,[intContractDetailId] = D.intContractDetailId
				,[intLoadDetailId] = B.intLoadDetailId 
				,[intStorageScheduleId] = NULL
				,[intStorageScheduleTypeId] = NULL
				,[dblFuture] = CASE WHEN E.intPricingTypeId = 6 THEN ISNULL(D.dblCashPrice,0) ELSE ISNULL(D.dblFutures,0) END
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
			INNER JOIN tblCTContractDetail D 
				ON C.intPContractDetailId = D.intContractDetailId
			INNER JOIN tblCTContractHeader E
				ON D.intContractHeaderId = E.intContractHeaderId
			WHERE A.intTicketId = @intTicketId 
				AND E.intPricingTypeId <> 2
				AND E.intPricingTypeId <> 3
		END

		--BASIS/HTA CONTRACT
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
				intAllocationType = 2
				,[dblQuantity] = B.dblQty
				,[intEntityId] = B.intEntityId
				,[intContractDetailId] = D.intContractDetailId
				,[intLoadDetailId] = B.intLoadDetailId 
				,[intStorageScheduleId] = NULL
				,[intStorageScheduleTypeId] = NULL
				,[dblFuture] = (SELECT TOP 1 
									ISNULL(dblSettlementPrice,0)
								FROM dbo.fnRKGetFutureAndBasisPrice (	1
																		,A.intCommodityId
																		,RIGHT(CONVERT(VARCHAR, D.dtmEndDate, 106),8)
																		,E.intPricingTypeId
																		,D.intFutureMarketId
																		,D.intFutureMonthId
																		,NULL
																		,NULL
																		,0 
																		,A.intItemId
																		,ISNULL(D.intInvoiceCurrencyId,D.intCurrencyId)
																	)
								)
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
			INNER JOIN tblCTContractDetail D 
				ON C.intPContractDetailId = D.intContractDetailId
			INNER JOIN tblCTContractHeader E
				ON D.intContractHeaderId = E.intContractHeaderId
			WHERE A.intTicketId = @intTicketId 
				AND (E.intPricingTypeId = 2 OR E.intPricingTypeId = 3)
		END

		--NO CONTRACT
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
				intAllocationType = 2
				,[dblQuantity] = B.dblQty
				,[intEntityId] = B.intEntityId
				,[intContractDetailId] = D.intContractDetailId
				,[intLoadDetailId] = B.intLoadDetailId 
				,[intStorageScheduleId] = NULL
				,[intStorageScheduleTypeId] = NULL
				,[dblFuture] = ISNULL(C.dblUnitPrice,0)
				,[dblBasis] = 0
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
			WHERE A.intTicketId = @intTicketId 
				AND D.intContractDetailId IS NULL
		END

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