ALTER PROCEDURE [dbo].[uspCTPostProcessPriceContract]
	@strXML    NVARCHAR(MAX),
	@intUserId INT

AS

BEGIN
    DECLARE @intContractHeaderId INT
		, @intPriceContractId INT
		, @intPriceFixationId INT
		, @intPriceFixationDetailId INT
		, @ysnLoad BIT = 0

	DECLARE @PriceContractXML TABLE(
		intPriceContractId INT
		, strPriceContractState NVARCHAR(50)
		, intPriceFixationId INT
		, strPriceFixationState NVARCHAR(50)
		, intPriceFixationDetailId INT
		, strPriceFixationDetailState NVARCHAR(50)
	)

	-- INSERT XML Reading code here

	-- Variable declarations
    SELECT @ysnLoad = ISNULL(ch.ysnLoad, 0)
    FROM tblCTPriceFixationDetail pfd, 
            tblCTPriceFixation pf, 
            tblCTContractHeader ch
    WHERE pfd.intPriceFixationDetailId = @intPriceFixationDetailId
            AND pf.intPriceFixationId = pfd.intPriceFixationId
            AND ch.intContractHeaderId = pf.intContractHeaderId;

	
	
	WHILE EXISTS (SELECT TOP 1 1 FROM @PriceContractXML)
	BEGIN
		SELECT TOP 1 @intPriceContractId = intPriceContractId, @intPriceFixationId = intPriceFixationId, @intPriceFixationDetailId = intPriceFixationDetailId FROM @PriceContractXML

		--------------------------------------------
		-- Call all pre process after validations --
		--------------------------------------------

		-- uspCTSavePriceContract
			-- include the ones that were previously on pre process routines but should be on post process instead
				-- uspCTSequencePriceChanged
				-- split routines
				-- ammendment and approval routines
			-- evaluate uspCTPriceFixationSave contents. we may not need some of the contents in here for price fixation
			-- create modular scripts each for invoice pricing and another for voucher pricing.


		
		-------------------------
		-- End all pre process --
		-------------------------

		DELETE FROM @PriceContractXML WHERE intPriceContractId = @intPriceContractId AND intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId = @intPriceFixationDetailId
	END


	-- Insert code to reorder intNumber on pricing layer (in cases of deletion of layers)

	-- EXEC [uspCTInterCompanyPriceContract] @intPriceContractId, @ysnApprove,@strRowState
END;