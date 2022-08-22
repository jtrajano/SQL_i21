﻿CREATE PROCEDURE [dbo].[uspSCGetAndAllocateBasisContractUnits]
	@dblQty NUMERIC(36,20)
	,@intContractDetailId INT
	,@ysnOutbound bit = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


BEGIN TRY
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;

	DECLARE @dblContractAvailablePrice NUMERIC(36,20)
	DECLARE @_intPriceFixationDetailId INT
	DECLARE @_dblPrice NUMERIC(18,6)
	DECLARE @_dblPriceAvailable NUMERIC(36,20)
	DECLARE @dblRemainingQty NUMERIC(36,20) 

	DECLARE @returnTable TABLE (
		intContractDetailId INT
		,intPriceFixationDetailId INT
		,dblQuantity NUMERIC(36,20)
		,dblPrice NUMERIC(18,6)
	)

	


	if @ysnOutbound = 0
	begin

		IF OBJECT_ID('tempdb..#tmpContractPrice') IS NOT NULL DROP TABLE #tmpContractPrice

		SELECT
			*
		INTO #tmpContractPrice
		FROM vyuCTAvailableQuantityForVoucher
		WHERE intContractDetailId = @intContractDetailId
		ORDER BY intPriceFixationDetailId ASC

		SELECT @dblContractAvailablePrice = SUM(dblAvailableQuantity)
		FROM #tmpContractPrice

		--check if there is available Price Quantity
		IF(ISNULL(@dblContractAvailablePrice,0) >= @dblQty)
		BEGIN
			SELECT TOP 1 
				@_intPriceFixationDetailId = intPriceFixationDetailId
				,@_dblPrice = dblCashPrice
				,@_dblPriceAvailable = dblAvailableQuantity
			FROM #tmpContractPrice
			ORDER BY intPriceFixationDetailId

			SET @dblRemainingQty = @dblQty
			WHILE ISNULL(@_intPriceFixationDetailId,0) > 0 AND @dblRemainingQty > 0
			BEGIN
			
				IF(@_dblPriceAvailable >= @dblRemainingQty)
				BEGIN
					INSERT INTO  @returnTable(
						intContractDetailId
						,intPriceFixationDetailId
						,dblQuantity
						,dblPrice 
					)
					SELECT 
						intContractDetailId = @intContractDetailId
						,intPriceFixationDetailId = @_intPriceFixationDetailId
						,dblQuantity = @dblRemainingQty
						,dblPrice  = @_dblPrice

					SET @dblRemainingQty = 0	
				END
				ELSE
				BEGIN
					INSERT INTO  @returnTable(
						intContractDetailId
						,intPriceFixationDetailId
						,dblQuantity
						,dblPrice 
					)
					SELECT 
						intContractDetailId = @intContractDetailId
						,intPriceFixationDetailId = @_intPriceFixationDetailId
						,dblQuantity = @_dblPriceAvailable
						,dblPrice  = @_dblPrice

					SET @dblRemainingQty = @dblRemainingQty - @_dblPriceAvailable
				END
			
			
				--LOOP iterator
				BEGIN
					IF NOT EXISTS (SELECT TOP 1 1 
								FROM #tmpContractPrice 
								WHERE intPriceFixationDetailId > @_intPriceFixationDetailId
								ORDER BY intPriceFixationDetailId)
					BEGIN
						SET @_intPriceFixationDetailId = NULL
					END 
					ELSE
					BEGIN
						SELECT TOP 1 
							@_intPriceFixationDetailId = intPriceFixationDetailId 
							,@_dblPrice = dblCashPrice
							,@_dblPriceAvailable = dblAvailableQuantity
						FROM #tmpContractPrice 
						WHERE intPriceFixationDetailId > @_intPriceFixationDetailId
						ORDER BY intPriceFixationDetailId
					END
				END
			END
		END

		SELECT 
			intContractDetailId 
			,intPriceFixationDetailId
			,dblQuantity 
			,dblPrice 
		FROM @returnTable

	end 
	else
	begin
	
		

		declare @intContractHeaderId int			
		select 
			@intContractHeaderId = intContractHeaderId 
		from tblCTContractDetail 
		where intContractDetailId = @intContractDetailId


		insert into @returnTable(intContractDetailId, intPriceFixationDetailId, dblQuantity, dblPrice)
		select intContractDetailId
			, intPriceFixationDetailId
			, dblQuantity
			, dblPrice 
		from #tmpContractPriceOutbound



		SELECT 
			intContractDetailId 
			,intPriceFixationDetailId
			,dblQuantity 
			,dblPrice 
		FROM @returnTable

	end


	
		
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH