CREATE FUNCTION [dbo].[fnLGGetSupplyPointContractData](
	@intEntityVendorId INT
	,@intEntityLocationId INT
	,@dtmEffectiveDate DATETIME = NULL
	,@intContractDetailId INT = NULL
)
RETURNS TABLE
AS
RETURN 

SELECT TOP 1
	intEntityVendorId = CH.intEntityId
	,CD.intVendorLocationId
	,CH.intContractHeaderId
	,CD.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,CD.dblBalance
	,dblScheduleQty = ISNULL(CD.dblScheduleQty, 0)
	,dblAvailableQty = CD.dblBalance - ISNULL(CD.dblScheduleQty, 0)
	,dblAppliedQty = CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0) ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0) END
	,CD.dtmStartDate 
	,CD.dtmEndDate
FROM tblCTContractDetail CD
INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
WHERE CH.ysnSupplyPointContract = 1 
	AND ((@intContractDetailId IS NOT NULL AND @intContractDetailId = CD.intContractDetailId)
		OR (@intContractDetailId IS NULL AND (@dtmEffectiveDate IS NULL OR @dtmEffectiveDate BETWEEN CD.dtmStartDate AND CD.dtmEndDate)))

GO


