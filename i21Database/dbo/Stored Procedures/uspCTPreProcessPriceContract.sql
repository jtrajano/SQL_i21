CREATE PROCEDURE [dbo].[uspCTPreProcessPriceContract]
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

		--------------------------
		-- Call all validations --
		--------------------------

		-- CALL [uspCTValidatePricingUpdateDelete], also include validation on fnCTGetPricingDetailVoucherInvoice



		-------------------------
		-- End all validations --
		-------------------------



		--------------------------------------------
		-- Call all pre process after validations --
		--------------------------------------------

		--uspCTBeforeSavePriceContract
			-- Take note to not call routines that should be on the post process SP instead of the pre process
				-- uspCTSequencePriceChanged
				-- split routines
				-- ammendment and approval routines


		--uspCTDeleteUnpostedInvoiceFromPricingUpdate

		--uspCTProcessSummaryLogOnPriceUpdate

		-------------------------
		-- End all pre process --
		-------------------------

		DELETE FROM @PriceContractXML WHERE intPriceContractId = @intPriceContractId AND intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId = @intPriceFixationDetailId
	END
END;