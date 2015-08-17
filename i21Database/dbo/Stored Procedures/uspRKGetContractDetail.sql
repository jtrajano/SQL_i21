CREATE PROC uspRKGetContractDetail 
	@intCommodityId int,
	@intLocationId int = NULL,
	@intSeqId int
AS
IF @intSeqId = 1
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (1)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (1)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END
	
ELSE IF @intSeqId = 2
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (2)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1 AND CD.intPricingTypeId IN (2)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END
	
ELSE IF @intSeqId = 3
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (3)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1 AND CD.intPricingTypeId IN (3)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END
	
ELSE IF @intSeqId = 4
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (1)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (1)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END

	
ELSE IF @intSeqId = 5
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (2)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (2)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END

ELSE IF @intSeqId = 6
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (3)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (3)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
END