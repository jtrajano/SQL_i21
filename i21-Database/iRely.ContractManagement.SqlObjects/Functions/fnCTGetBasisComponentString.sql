CREATE FUNCTION [dbo].[fnCTGetBasisComponentString]
(
	@intContractDetailId INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @col NVARCHAR(MAX);
 
	SELECT @col = COALESCE(@col + ', ', '') + strItemNo + ' = ' + dbo.fnRemoveTrailingZeroes(dblRate)
	FROM vyuCTContractCostView WHERE ysnBasis = 1 AND intContractDetailId = @intContractDetailId

	RETURN @col
END