CREATE PROCEDURE uspSCBasisContractValidation	
	@CONTRACT_DETAIL INT,
	@QUANTITY_TO_CHECK NUMERIC(38, 20),
	@SCREEN NVARCHAR(20),
	@NO_RAISE BIT = 0, 
	@SIMPLE_MESSAGE BIT = 0,
	@OUTPUT NVARCHAR(200) = '' OUTPUT 
AS
BEGIN
	RETURN 
	BEGIN
		DECLARE @CONTRACT_AVAILABLE_PRICED_QUANTITY NUMERIC(38,20)												
		DECLARE @CONTRACT_NUMBER_AFFECTED NVARCHAR(500)
		DECLARE @CONTRACT_HEADER INT


		SELECT
			@CONTRACT_HEADER = CONTRACT_DETAIL.intContractHeaderId,
			@CONTRACT_NUMBER_AFFECTED = CONTRACT_HEADER.strContractNumber
		FROM tblCTContractDetail CONTRACT_DETAIL
			JOIN tblCTContractHeader CONTRACT_HEADER
				ON CONTRACT_DETAIL.intContractHeaderId = CONTRACT_HEADER.intContractHeaderId 
		WHERE CONTRACT_DETAIL.intContractDetailId = @CONTRACT_DETAIL

		
		DECLARE @CONTRACT_PRICE AS TABLE (
			intIdentityId INT
			,intContractHeaderId int
			,intContractDetailId int
			,ysnLoad bit
			,intPriceContractId int
			,intPriceFixationId int
			,intPriceFixationDetailId int
			,dblQuantity numeric(38,20)
			,dblPrice numeric(38,20)
		)
			
		
		INSERT INTO @CONTRACT_PRICE 
		EXEC uspCTGetContractPrice @CONTRACT_HEADER, @CONTRACT_DETAIL, @QUANTITY_TO_CHECK, @SCREEN

		SELECT @CONTRACT_AVAILABLE_PRICED_QUANTITY = SUM(dblQuantity) 
		FROM @CONTRACT_PRICE

		DELETE FROM @CONTRACT_PRICE
		if(@CONTRACT_AVAILABLE_PRICED_QUANTITY < @QUANTITY_TO_CHECK)
		begin

			IF @SIMPLE_MESSAGE = 1
				SET @OUTPUT = @CONTRACT_NUMBER_AFFECTED + ' has ' + cast(cast(@CONTRACT_AVAILABLE_PRICED_QUANTITY as numeric(18, 2)) as nvarchar) + ' priced units.'
			ELSE 
				SET @OUTPUT = 'Cannot distribute to contract with not enough Priced Quantity (' + @CONTRACT_NUMBER_AFFECTED + ' has ' + cast(cast(@CONTRACT_AVAILABLE_PRICED_QUANTITY as numeric(18, 2)) as nvarchar) + ' priced units) .'

			IF(@NO_RAISE = 0)
				RAISERROR(@OUTPUT, 11, 1);
		end

	end


END