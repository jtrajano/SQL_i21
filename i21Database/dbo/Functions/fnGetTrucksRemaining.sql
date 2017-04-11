CREATE FUNCTION dbo.fnGetTrucksRemaining (
	@intContractHeaderId INT
	,@intItemId INT
	,@dblBasis NUMERIC(18, 6)
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
		AND CD.intItemId = @intItemId
	GROUP BY CH.intContractHeaderId
		,CD.intItemId

	RETURN ISNULL(@intTrucksRemaining, 0)
END