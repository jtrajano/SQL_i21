CREATE PROCEDURE [dbo].[uspSCGetAndAllocateBasisContractUnits]
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

	DECLARE @intContractPricingTypeId INT 
	DECLARE @PRICING_TYPE_HTA INT = 3


	SELECT 
		@intContractPricingTypeId = HEADER.intPricingTypeId	
	FROM tblCTContractDetail DETAIL
		JOIN tblCTContractHeader HEADER
			ON DETAIL.intContractHeaderId = HEADER.intContractHeaderId
	WHERE DETAIL.intContractDetailId = @intContractDetailId


	if @ysnOutbound = 0
	begin

		
		DECLARE @tmpContractPrice TABLE(
			intContractDetailId	int
			,intPriceFixationId	int
			,intPriceFixationDetailId	int
			,dblCashPrice	numeric(18, 6)		
			,dblAvailableQuantity	numeric(38, 6)
		)

		
		INSERT INTO @tmpContractPrice (intContractDetailId, intPriceFixationId, intPriceFixationDetailId, dblCashPrice, dblAvailableQuantity)
		
		SELECT intContractDetailId, intPriceFixationId, intPriceFixationDetailId, dblFinalprice, dblAvailableQuantity 
		FROM vyuCTGetAvailablePriceForVoucher
		WHERE intContractDetailId = @intContractDetailId
		ORDER BY intPriceFixationDetailId ASC

		SELECT @dblContractAvailablePrice = SUM(dblAvailableQuantity)
		FROM @tmpContractPrice

		
		--check if there is available Price Quantity
		IF(ISNULL(@dblContractAvailablePrice,0) >= @dblQty)
		BEGIN
			-- there are two ways to price an HTA Contract
			/*
				1. is through the sequence contract by setting the pricing type of the sequence as Priced
				2. is through the pricing screen.

				If the use uses the sequence pricing, it will not have a price fixation detail id and will not satisfy the condition we used for checking the price fixation detail id
				the code change is if the pricing quantity is enough it will get the pricing and available quantity and insert it to our return table

			*/
			IF @intContractPricingTypeId = @PRICING_TYPE_HTA  AND EXISTS(SELECT TOP 1 1 FROM @tmpContractPrice WHERE intPriceFixationId IS NULL)
			BEGIN

				SELECT TOP 1 
					@_dblPrice = dblCashPrice
				FROM @tmpContractPrice

				INSERT INTO  @returnTable(
					intContractDetailId
					,intPriceFixationDetailId
					,dblQuantity
					,dblPrice 
				)
				SELECT 
					intContractDetailId = @intContractDetailId
					,intPriceFixationDetailId = NULL
					,dblQuantity = @dblQty
					,dblPrice  = @_dblPrice

			END
			ELSE
			BEGIN
				
				SELECT TOP 1 
					@_intPriceFixationDetailId = intPriceFixationDetailId
					,@_dblPrice = dblCashPrice
					,@_dblPriceAvailable = dblAvailableQuantity
				FROM @tmpContractPrice
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
									FROM @tmpContractPrice 
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
							FROM @tmpContractPrice 
							WHERE intPriceFixationDetailId > @_intPriceFixationDetailId
							ORDER BY intPriceFixationDetailId
						END
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