CREATE FUNCTION [dbo].[fnCTGetTopOneSequence]
(
	@intContractHeaderId	INT,
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	intCurrencyId			INT,
	intBookId				INT,
	intSubBookId			INT,
	intCompanyLocationId	INT
)
AS
BEGIN

	IF ISNULL(@intContractDetailId,0) > 0
		INSERT INTO @returntable
		SELECT intCurrencyId,intBookId,intSubBookId,intCompanyLocationId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
	ELSE
		INSERT INTO @returntable
		SELECT TOP 1 intCurrencyId,intBookId,intSubBookId,intCompanyLocationId FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	RETURN;
END