CREATE FUNCTION [dbo].[fnCTGetSeqPriceFixationInfo]
(
	@intContractDetailId	INT
)

RETURNS	@returntable	TABLE
(
    dblTotalLots				NUMERIC(18,6),
    dblLotsFixed				NUMERIC(18,6),
    intPriceFixationId			INT, 
    intPriceContractId			INT,
    dblQuantityPriceFixed		NUMERIC(18,6),
    dblPFQuantityUOMId			INT,
    ysnSpreadAvailable			BIT,
    ysnFixationDetailAvailable  BIT,
    ysnMultiPricingDetail		BIT
)

AS
BEGIN
    
    DECLARE @dblTotalLots				NUMERIC(18,6),
			@dblLotsFixed				NUMERIC(18,6),
			@intPriceFixationId			INT, 
			@intPriceContractId			INT,
			@intPFDCount				INT,
			@dblQuantityPriceFixed		NUMERIC(18,6),
			@dblPFQuantityUOMId			NUMERIC(18,6),
			@ysnSpreadAvailable			BIT = 0,
			@ysnFixationDetailAvailable	BIT = 0,
			@ysnMultiPricingDetail		BIT = 0

    IF EXISTS(
		SELECT
			top 1 1 
		FROM
			tblCTContractDetail cd
			join tblCTContractHeader ch
				on ch.intContractHeaderId = cd.intContractHeaderId
			join tblCTPriceFixation pf
				on pf.intContractHeaderId = ch.intContractHeaderId
				and isnull(pf.intContractDetailId,0) = (case when ch.ysnMultiplePriceFixation = 1 then isnull(pf.intContractDetailId,0) else cd.intContractDetailId end)
		WHERE
			cd.intContractDetailId = @intContractDetailId
	)
    BEGIN

		SELECT	@dblTotalLots		=	pf.dblTotalLots,
				@dblLotsFixed		=	pf.dblLotsFixed,
				@intPriceFixationId	=	pf.intPriceFixationId,
				@intPriceContractId =	pf.intPriceContractId 
		FROM
			tblCTContractDetail cd
			join tblCTContractHeader ch
				on ch.intContractHeaderId = cd.intContractHeaderId
			join tblCTPriceFixation pf
				on pf.intContractHeaderId = ch.intContractHeaderId
				and isnull(pf.intContractDetailId,0) = (case when ch.ysnMultiplePriceFixation = 1 then isnull(pf.intContractDetailId,0) else cd.intContractDetailId end)
		WHERE
			cd.intContractDetailId = @intContractDetailId

		SELECT	 @intPFDCount			=   COUNT(intPriceFixationDetailId) 
				,@dblQuantityPriceFixed =   SUM(dblQuantity) 
				,@dblPFQuantityUOMId	=   MAX(intQtyItemUOMId)   
		FROM	 tblCTPriceFixationDetail
		WHERE	 intPriceFixationId		=   @intPriceFixationId
		GROUP BY intPriceFixationId

		SELECT	@ysnSpreadAvailable = CASE WHEN SA.intSpreadArbitrageId > 0 THEN 1 ELSE 0 END FROM tblCTSpreadArbitrage SA  WHERE SA.intPriceFixationId = @intPriceFixationId	  

		SELECT	@ysnFixationDetailAvailable =   CASE WHEN @intPFDCount > 0 THEN 1 ELSE 0 END,
				@ysnMultiPricingDetail	    =   CASE WHEN @intPFDCount > 1 THEN 1 ELSE 0 END
    END

    INSERT INTO @returntable (dblTotalLots,dblLotsFixed,intPriceFixationId,intPriceContractId,dblQuantityPriceFixed,dblPFQuantityUOMId,ysnSpreadAvailable,ysnFixationDetailAvailable,ysnMultiPricingDetail)
    SELECT @dblTotalLots,@dblLotsFixed,@intPriceFixationId,@intPriceContractId,@dblQuantityPriceFixed,@dblPFQuantityUOMId,@ysnSpreadAvailable,@ysnFixationDetailAvailable,@ysnMultiPricingDetail

    RETURN;
END
