﻿CREATE PROCEDURE [dbo].[uspTMContractScheduleQty]
	@intSiteId INT,
	@dblQuantity NUMERIC(18,6),
	@strScreenName NVARCHAR(100),
	@intContractDetailId INT = NULL,
	@intUserId INT = NULL,
	@ysnThrowError BIT = 1,
	@dblOverrage NUMERIC(18,6) = 0 OUTPUT,
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

	BEGIN TRY
	IF @transCount = 0 BEGIN TRANSACTION

		IF(@dblQuantity > 0)
		BEGIN
			IF(@intContractDetailId IS NOT NULL)
			BEGIN
				-- IF POSITIVE QTY THEN ADD FROM SCHEDULED QTY
				DECLARE @dblAvailable DECIMAL(18,6) = NULL

				--Get the available quantity of the contract
				SELECT @dblAvailable = B.dblBalance - B.dblScheduleQty
				FROM tblCTContractHeader A
				INNER JOIN tblCTContractDetail B
					ON A.intContractHeaderId = B.intContractHeaderId
				WHERE B.intContractDetailId = @intContractDetailId

				
				IF(@dblAvailable > 0)
				BEGIN
					DECLARE @dblQuantityToUpdate DECIMAL(18,6) = NULL

					---Check Quantity is greater than contract available if yes then schedule the whole available Qty if not then schedule the quantity
					IF(@dblQuantity > @dblAvailable)
					BEGIN
						SET @dblQuantityToUpdate = @dblAvailable

						--get The overrage
						SET @dblOverrage = @dblQuantity - @dblAvailable
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
					SET @dblOverrage = @dblQuantity
				END
			END
		END
		ELSE
		BEGIN
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

		END

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