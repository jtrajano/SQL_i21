CREATE VIEW vyuLGLoadOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			CD.intItemId,
			CD.strItemDescription,
			CD.dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.strItemUOM as strUnitMeasure,
			CD.intCompanyLocationId,
			IsNull(CD.dblBalance, 0) - IsNull(CD.dblScheduleQty, 0)		AS dblUnLoadedQuantity,
			CD.intContractTypeId intPurchaseSale,
			CD.intEntityId,
			CD.intContractNumber,
			CD.dtmContractDate,
			CD.strEntityName,
			CD.dtmStartDate,
			CD.dtmEndDate,
			CD.intDefaultLocationId,
			IsNull(CD.dblScheduleQty, 0) as dblScheduleQty,
			CD.strItemNo,
			CD.strCustomerContract,
			IsNull(CD.dblBalance, 0) as dblBalance
	FROM vyuCTContractDetailView 		CD
