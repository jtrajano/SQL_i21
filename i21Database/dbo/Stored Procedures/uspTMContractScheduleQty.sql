CREATE PROCEDURE [dbo].[uspTMContractScheduleQty]
	@intSiteId INT,
	@dblQuantity NUMERIC(18,6),
	@strScreenName NVARCHAR(100),
	@intContractDetailId INT = NULL,
	@intUserId INT = NULL,
	@ysnThrowError BIT = 1,
	@ysnFromDelete BIT = 0,
	@intDispatchId INT = NULL,
	@dblOverage NUMERIC(18,6) = 0 OUTPUT,
	@strErrorMessage NVARCHAR(MAX) = '' OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	DECLARE @transCount INT = @@TRANCOUNT;
	DECLARE @intLoadDistributionDetailId INT

	BEGIN TRY
		IF @transCount = 0 BEGIN TRANSACTION

		IF(@dblQuantity > 0)
		BEGIN
			IF(@intContractDetailId IS NOT NULL)
			BEGIN
				-- IF POSITIVE QTY THEN ADD FROM SCHEDULED QTY
				DECLARE @dblAvailable DECIMAL(18,6) = NULL

				--Get the available quantity of the contract
				SELECT @dblAvailable = ISNULL(B.dblBalance,0.0) - ISNULL(B.dblScheduleQty,0.0)
				FROM tblCTContractHeader A
				INNER JOIN vyuCTContractDetail B
					ON A.intContractHeaderId = B.intContractHeaderId
				WHERE B.intContractDetailId = @intContractDetailId

				
				IF(@dblAvailable > 0)
				BEGIN
					DECLARE @dblQuantityToUpdate DECIMAL(18,6) = NULL

					---Check Quantity is greater than contract available if yes then schedule the whole available Qty if not then schedule the quantity
					IF(@dblQuantity > @dblAvailable)
					BEGIN
						SET @dblQuantityToUpdate = @dblAvailable

						--get The overage
						SET @dblOverage = @dblQuantity - @dblAvailable
					END
					ELSE
					BEGIN
						SET @dblQuantityToUpdate = @dblQuantity
					END
					
					IF(@dblQuantityToUpdate <> 0)
					BEGIN 
						EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
							, @dblQuantityToUpdate = @dblQuantityToUpdate
							, @intUserId = @intUserId
							, @intExternalId = @intSiteId
							, @strScreenName = @strScreenName
					END
				END
				ELSE
				BEGIN
					SET @dblOverage = @dblQuantity
				END
			END
		END
		ELSE
		BEGIN
			SET @dblOverage = 0
			/*
			-- IF NEGATIVE QTY THEN REMOVE FROM SCHEDULED QTY
			SELECT @intContractDetailId = O.intContractDetailId  
				, @dblQuantity = O.dblQuantity * -1
				, @intUserId = D.intUserID
			FROM tblTMOrder O 
			INNER JOIN tblTMDispatch D ON D.intDispatchID = O.intDispatchId AND D.intContractId = O.intContractDetailId
			WHERE D.intSiteID = @intSiteId

			IF(@intContractDetailId IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM tblCTSequenceUsageHistory WHERE intContractDetailId = @intContractDetailId
				AND strScreenName = @strScreenName
				AND strFieldName = 'Scheduled Quantity'
				AND intExternalId = @intSiteId 
				--AND dblTransactionQuantity = @dblQuantity
				)
				BEGIN
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
						, @dblQuantityToUpdate = @dblQuantity 
						, @intUserId = @intUserId
						, @intExternalId = @intSiteId
						, @strScreenName = @strScreenName
				END
			END
			*/
			
			DECLARE @dblScheduleQty DECIMAL(18,6) = NULL

			--Get the available quantity of the contract
			SELECT @dblScheduleQty = ISNULL(B.dblScheduleQty,0)
			FROM tblCTContractHeader A
			INNER JOIN vyuCTContractDetail B
				ON A.intContractHeaderId = B.intContractHeaderId
			WHERE B.intContractDetailId = @intContractDetailId

			--Check if the SCheduled qty of contract is greater thant the quantity if not then remove all the schedule quantity of the contract
			IF(@dblScheduleQty > ABS(@dblQuantity))
			BEGIN
				IF(@dblQuantity <> 0)
				BEGIN
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
							, @dblQuantityToUpdate = @dblQuantity 
							, @intUserId = @intUserId
							, @intExternalId = @intSiteId
							, @strScreenName = @strScreenName

					
				END
			END
			ELSE
			BEGIN
				IF(@dblScheduleQty <> 0)
				BEGIN
					SET @dblScheduleQty = @dblScheduleQty * -1
					SET @dblQuantity = @dblScheduleQty
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
							, @dblQuantityToUpdate = @dblScheduleQty
							, @intUserId = @intUserId
							, @intExternalId = @intSiteId
							, @strScreenName = @strScreenName

				END
			END

			--if tmo deletion then transfer the schedule to transport if already been used in TR
			IF(@ysnFromDelete = 1)
			BEGIN
				SELECT TOP 1	
					@intLoadDistributionDetailId = DD.intLoadDistributionDetailId
				FROM tblLGLoad LG
				JOIN tblTRLoadHeader LH ON LH.intLoadId = LG.intLoadId
				JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = LH.intLoadHeaderId
				JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
				JOIN tblLGLoadDetail LD ON LD.intLoadId = LD.intLoadId
					AND LD.intLoadDetailId = DD.intLoadDetailId        
				WHERE LD.intTMDispatchId = @intDispatchId
					AND DD.intContractDetailId = @intContractDetailId
					AND LH.ysnPosted <> 1
				
				SET @dblQuantity = (SELECT ABS(@dblQuantity))
				IF(ISNULL(@intLoadDistributionDetailId,0) >0)
				BEGIN
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
						, @dblQuantityToUpdate = @dblQuantity 
						, @intUserId = @intUserId
						, @intExternalId = @intLoadDistributionDetailId
						, @strScreenName = 'Transport Sale'
				END
			END

		END

		IF @transCount = 0 COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		SET @strErrorMessage = @ErrorMessage

		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		IF(@ysnThrowError = 1) 
		BEGIN
			RAISERROR (
				@ErrorMessage, -- Message text.
				@ErrorSeverity, -- Severity.
				@ErrorState -- State.
			);
		END
	END CATCH


	

END