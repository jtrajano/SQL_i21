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
			CD.strContractNumber,
			CD.dtmContractDate,
			CD.strEntityName,
            convert(nvarchar(100), CD.dtmStartDate, 101) as strStartDate,
            convert(nvarchar(100), CD.dtmEndDate, 101) as strEndDate,
			CD.dtmStartDate,
			CD.dtmEndDate,
			CD.intDefaultLocationId,
			IsNull(CD.dblScheduleQty, 0) as dblScheduleQty,
			CD.strItemNo,
			CD.strCustomerContract,
			IsNull(CD.dblBalance, 0) as dblBalance,
			CASE WHEN (((IsNull(CD.dblBalance, 0) - IsNull(CD.dblScheduleQty, 0) > 0) Or (CD.ysnUnlimitedQuantity = 1)) or (CD.ysnAllowedToShow = 1))
				THEN CAST(1 as Bit)
				ELSE CAST (0 as Bit)
				END as ysnAllowedToShow,
			CD.ysnUnlimitedQuantity
	FROM vyuCTContractDetailView 		CD
