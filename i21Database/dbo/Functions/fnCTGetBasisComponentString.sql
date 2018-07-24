CREATE FUNCTION [dbo].[fnCTGetBasisComponentString]
(
	@intContractDetailId INT,
	@strStyle NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @col NVARCHAR(MAX);
 
	IF @strStyle = 'NOTIF'
	BEGIN
		SELECT @col = COALESCE(@col + ', ', '') + strItemNo + ' = ' + dbo.fnRemoveTrailingZeroes(dblRate)
		FROM vyuCTContractCostView WHERE ysnBasis = 1 AND intContractDetailId = @intContractDetailId
	END
	ELSE IF @strStyle = 'HERSHEY'
	BEGIN
		SELECT @col = COALESCE(@col + ', '+CHAR(13)+CHAR(10), '') + strItemNo + ' ' + dbo.fnCTChangeNumericScale(dblRate,2) + ' ' + strCurrency + '/' + strUOM
		FROM vyuCTContractCostView WHERE ysnBasis = 1 AND intContractDetailId = @intContractDetailId
		AND ISNULL(dblRate,0) <> 0
	END

	RETURN @col
END