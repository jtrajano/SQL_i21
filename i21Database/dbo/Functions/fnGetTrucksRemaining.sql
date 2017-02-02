CREATE FUNCTION dbo.fnGetTrucksRemaining
	(@intContractHeaderId INT,
	 @intUOMId INT)
RETURNS INT
AS
BEGIN
	DECLARE @intTrucksRemaining INT

SELECT @intTrucksRemaining = COUNT(CD.intContractDetailId) FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId	
WHERE CD.intContractStatusId NOT IN (5,6)
AND CH.intContractHeaderId=@intContractHeaderId
AND CD.intItemUOMId = @intUOMId
GROUP BY CH.intContractHeaderId, CD.intItemId, CD.intItemUOMId	

	return ISNULL(@intTrucksRemaining,0)
END