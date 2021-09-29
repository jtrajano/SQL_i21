CREATE PROCEDURE [dbo].[uspSCDirectUpdateContractAndLoadUsed]
	@intTicketId INT
	,@intUserId INT
AS
BEGIN
	DECLARE @dblLoadQuantity NUMERIC(38,20)
	DECLARE @intLoadItemUOMId INT
	DECLARE @dblLoadContractUOMQuantity NUMERIC(38,20)
	DECLARE @intContractItemUOMId INT
	DECLARE @intTicketStorageScheduleTypeId INT
	DECLARE @intTicketItemUOMIdTo INT
	DECLARE @intTicketLoadDetailId  INT
	DECLARE @intTicketContractDetailId INT
	DECLARE @UnitAllocation ScaleManualDistributionAllocation
	DECLARE @dblTicketScheduledQty NUMERIC(38,20)
	DECLARE @dblTicketTotalAllocatedSelContract NUMERIC(38,20)

	DECLARE @_intLoadContractDetailId INT
	DECLARE @_intLoopLoadDetailId INT
	DECLARE @_intLoopContractDetailId INT
	DECLARE @_ysnLoopContractLoadBase BIT
	DECLARE @_dblLoopContractUpdateQuantity NUMERIC(38,20)
	DECLARE @_dblLoopQuantity NUMERIC(38,20)
	DECLARE @_dblUpdateContractQty NUMERIC(38,20)
	DECLARE @_intContractItemUOMId INT



	--GET TICKET DETAILS
	SELECT TOP 1
		@intTicketItemUOMIdTo = intItemUOMIdTo
		,@intTicketLoadDetailId = ISNULL(intLoadDetailId,0)
		,@intTicketStorageScheduleTypeId = intStorageScheduleTypeId
		,@intTicketContractDetailId = ISNULL(intContractId,0)
		,@dblTicketScheduledQty = dblScheduleQty
	FROM tblSCTicket
	WHERE intTicketId = @intTicketId


	SELECT TOP 1 
		@intLoadItemUOMId = intItemUOMId
		,@dblLoadQuantity = dblQuantity
	FROM tblLGLoadDetail
	WHERE intLoadDetailId = @intTicketLoadDetailId 


	--GEt the Contract and load allocation during distribution
	INSERT INTO @UnitAllocation(
		intLoadDetailId
		,intEntityId
		,intContractDetailId
		,dblQuantity
		,intAllocationType
	)
	--LOAD
	SELECT
		intLoadDetailId = intLoadDetailId
		,intEntityId = intEntityId
		,intContractDetailId = NULL
		,dblQuantity = dblQty
		,intAllocationType = 2
	FROM tblSCTicketLoadUsed
	WHERE intTicketId = @intTicketId
	UNION
	--CONTRACT
	SELECT
		intLoadDetailId = NULL
		,intEntityId = intEntityId
		,intContractDetailId = intContractDetailId
		,dblQuantity = dblScheduleQty
		,intAllocationType = 1
	FROM tblSCTicketContractUsed
	WHERE intTicketId = @intTicketId

	

	---LOAD DISTRIBUTION
	IF (@intTicketStorageScheduleTypeId  = -6)
	BEGIN
		---Check for contract and Remove the Scheduled qty of the LS used in the ticket (Load Distribution)
		IF @intTicketLoadDetailId > 0 
		BEGIN
			SELECT TOP 1
				@_intLoadContractDetailId = ISNULL(intPContractDetailId,0)
			FROM tblLGLoadDetail
			WHERE intLoadDetailId = @intTicketLoadDetailId

			IF(@_intLoadContractDetailId > 0)
			BEGIN
				EXEC uspSCDirectUpdateLSSchedule
					@intLoadDetailId = @intTicketLoadDetailId
					,@intContractDetailId = @_intLoadContractDetailId
					,@intUserId = @intUserId
					,@intTicketId = @intTicketId
			END
		END
	END

	---- CONTRACT DISTRIBUTION
	IF (@intTicketStorageScheduleTypeId  = -2)
	BEGIN
		IF(@intTicketContractDetailId > 0)
		BEGIN

			-- get contract detail
			SELECT 
				@_intContractItemUOMId = A.intItemUOMId
			FROM  tblCTContractDetail A
			INNER JOIN tblCTContractHeader B
				ON A.intContractHeaderId = B.intContractHeaderId
			WHERE A.intContractDetailId = @intTicketContractDetailId

			SET @_dblUpdateContractQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMIdTo,@_intContractItemUOMId,@dblTicketScheduledQty)
			SET @_dblUpdateContractQty = @_dblUpdateContractQty * -1
			
			
			---REmove schedule qty on ticket
			EXEC uspSCUpdateContractSchedule
				@intContractDetailId = @intTicketContractDetailId
				,@dblQuantity = @_dblUpdateContractQty
				,@intUserId = @intUserId
				,@intExternalId = @intTicketId
				,@strScreenName = 'Scale'
		END
	END

	--LOAD
	BEGIN
		IF OBJECT_ID (N'tempdb.dbo.#tmpOtherLoadScheduledUsed') IS NOT NULL
		DROP TABLE #tmpOtherLoadScheduledUsed

		CREATE TABLE #tmpOtherLoadScheduledUsed (
			intCntId INT IDENTITY(1,1)
			,intContractDetailId INT
			,intLoadDetailId INT
		);		

		-- get other LS used with contract
		INSERT INTO #tmpOtherLoadScheduledUsed(
			intContractDetailId
			,intLoadDetailId
		)
		SELECT 
			C.intContractDetailId
			,B.intLoadDetailId
		FROM @UnitAllocation A
		INNER JOIN tblLGLoadDetail B
			ON A.intLoadDetailId = B.intLoadDetailId
		LEFT JOIN tblCTContractDetail C
			ON B.intPContractDetailId = C.intContractDetailId
		WHERE A.intAllocationType = 2
			AND B.intLoadDetailId <> @intTicketLoadDetailId
			AND C.intContractDetailId IS NOT NULL

		---Remove schedule of other LS used on the distribution
		BEGIN
			DECLARE OtherLoadScheduledUsed CURSOR FAST_FORWARD
			FOR
				SELECT
					intLoadDetailId
					,intContractDetailId
				FROM #tmpOtherLoadScheduledUsed

			OPEN OtherLoadScheduledUsed
				FETCH NEXT FROM OtherLoadScheduledUsed 
				INTO @_intLoopLoadDetailId, @_intLoopContractDetailId 

				WHILE @@FETCH_STATUS = 0
				BEGIN

					EXEC uspSCDirectUpdateLSSchedule
						@intLoadDetailId = @_intLoopLoadDetailId
						,@intContractDetailId = @_intLoopContractDetailId
						,@intUserId = @intUserId
						,@intTicketId = @intTicketId


					FETCH NEXT FROM OtherLoadScheduledUsed
					INTO @_intLoopLoadDetailId, @_intLoopContractDetailId
				END
			CLOSE OtherLoadScheduledUsed;
			DEALLOCATE OtherLoadScheduledUsed;
		END

		--Update LS contract balances
		BEGIN
			DECLARE LoadScheduledUsed CURSOR FAST_FORWARD
			FOR
				SELECT 
					C.intContractDetailId
					,dblQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMIdTo,C.intItemUOMId,A.dblQuantity)
					,ISNULL(ysnLoad,0) 
				FROM @UnitAllocation A
				INNER JOIN tblLGLoadDetail B
					ON A.intLoadDetailId = B.intLoadDetailId
				LEFT JOIN tblCTContractDetail C
					ON B.intPContractDetailId = C.intContractDetailId
				LEFT JOIN tblCTContractHeader D
					ON C.intContractHeaderId = D.intContractHeaderId
				WHERE A.intAllocationType = 2
					AND C.intContractDetailId IS NOT NULL

			OPEN LoadScheduledUsed
				FETCH NEXT FROM LoadScheduledUsed 
				INTO  @_intLoopContractDetailId, @_dblLoopQuantity,@_ysnLoopContractLoadBase

				WHILE @@FETCH_STATUS = 0
				BEGIN

					IF @_ysnLoopContractLoadBase = 1
					BEGIN
						SET @_dblLoopContractUpdateQuantity = 1 	
					END
					ELSE
					BEGIN
						SET @_dblLoopContractUpdateQuantity = @_dblLoopQuantity
					END

					EXEC uspCTUpdateSequenceBalance 
						@intContractDetailId = @_intLoopContractDetailId
						,@dblQuantityToUpdate = @_dblLoopContractUpdateQuantity
						,@intUserId	= @intUserId
						,@intExternalId	= @intTicketId
						,@strScreenName	= 'Scale'


					FETCH NEXT FROM LoadScheduledUsed
					INTO  @_intLoopContractDetailId, @_dblLoopQuantity,@_ysnLoopContractLoadBase
				END
			CLOSE LoadScheduledUsed;
			DEALLOCATE LoadScheduledUsed;
		END
	END


	--CONTRACT
	IF EXISTS(SELECT TOP 1 1 FROM @UnitAllocation WHERE intAllocationType = 1)
	BEGIN
		

		DECLARE ContractUsed CURSOR FAST_FORWARD
		FOR
			SELECT 
				C.intContractDetailId
				,dblQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMIdTo,C.intItemUOMId,A.dblScheduleQty)
				,ISNULL(D.ysnLoad,0) 
			FROM tblSCTicketContractUsed A
			INNER JOIN tblCTContractDetail C
				ON A.intContractDetailId = C.intContractDetailId
			LEFT JOIN tblCTContractHeader D
				ON C.intContractHeaderId = D.intContractHeaderId
			WHERE C.intContractDetailId IS NOT NULL
				AND A.intTicketId = @intTicketId

		OPEN ContractUsed
			FETCH NEXT FROM ContractUsed 
			INTO  @_intLoopContractDetailId, @_dblLoopQuantity,@_ysnLoopContractLoadBase

			WHILE @@FETCH_STATUS = 0
			BEGIN

				IF @_ysnLoopContractLoadBase = 1
				BEGIN
					SET @_dblLoopContractUpdateQuantity = 1 	
				END
				ELSE
				BEGIN
					SET @_dblLoopContractUpdateQuantity = @_dblLoopQuantity 
				END

				EXEC uspCTUpdateSequenceBalance 
					@intContractDetailId = @_intLoopContractDetailId
					,@dblQuantityToUpdate = @_dblLoopContractUpdateQuantity
					,@intUserId	= @intUserId
					,@intExternalId	= @intTicketId
					,@strScreenName	= 'Scale'

				FETCH NEXT FROM ContractUsed
				INTO  @_intLoopContractDetailId, @_dblLoopQuantity,@_ysnLoopContractLoadBase
			END
		CLOSE ContractUsed;
		DEALLOCATE ContractUsed;
	END
	
	
	
END
GO



