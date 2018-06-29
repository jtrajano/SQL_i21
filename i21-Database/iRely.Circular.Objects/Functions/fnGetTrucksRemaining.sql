CREATE FUNCTION dbo.fnGetTrucksRemaining (
	@intContractHeaderId INT
	,@intItemId INT
	,@dblBasis NUMERIC(18, 6)
	,@dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	)
RETURNS INT
AS
BEGIN
	DECLARE @intTrucksRemaining INT

	SELECT @intTrucksRemaining = COUNT(CD.intContractDetailId)
	FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE CD.intContractStatusId NOT IN (
			5
			,6
			)
		AND CH.intContractHeaderId = @intContractHeaderId
		AND CD.dblBasis = @dblBasis
		AND CD.intItemContractId = @intItemId
		AND CD.dtmStartDate = @dtmStartDate
		AND CD.dtmEndDate = @dtmEndDate
	GROUP BY CH.intContractHeaderId
		,CD.intItemId
		,CD.dtmStartDate
		,CD.dtmEndDate

	RETURN ISNULL(@intTrucksRemaining, 0)
END