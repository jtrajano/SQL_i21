CREATE FUNCTION dbo.fnICCalculateGrossQtyRatio(
	  @intItemUOMId INT
	, @intGrossUOMId INT
	, @dblQty NUMERIC(18, 6)
	, @dblProposedQty NUMERIC(18, 6)
	, @dblProposedGrossQty NUMERIC(18, 6))
RETURNS NUMERIC(18, 6)
BEGIN
	DECLARE @dblConvertedProposedGrossQty NUMERIC(18, 6)
	DECLARE @dblNewGrossQty NUMERIC(18, 6)

	SET @dblConvertedProposedGrossQty = dbo.fnCalculateQtyBetweenUOM(@intGrossUOMId, @intItemUOMId, @dblProposedGrossQty)
	SET @dblNewGrossQty = @dblProposedQty * (@dblConvertedProposedGrossQty / @dblQty)

	RETURN CAST(dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, @intGrossUOMId, @dblNewGrossQty) AS NUMERIC(18, 6))
END