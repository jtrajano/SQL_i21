CREATE FUNCTION fnAllowCommodityToChange (
	@intItemId AS INT 
	,@intCommodityId AS INT 
)
RETURNS BIT
AS
BEGIN
	IF (
		@intItemId IS NOT NULL 
		AND (
			EXISTS (SELECT TOP 1 1 FROM tblICInventoryTransaction t WHERE t.intItemId = @intItemId AND ISNULL(t.ysnIsUnposted,0) = 0) 
			OR EXISTS (
				SELECT	TOP 1 1 
				FROM	tblICLot l 
				WHERE	l.dblQty <> 0
						AND l.intItemId = @intItemId
			)
			OR EXISTS (
				SELECT TOP 1 
					ch.intCommodityId
	
				FROM 
					tblCTContractHeader ch INNER JOIN tblCTContractDetail cd
						ON ch.intContractHeaderId = cd.intContractHeaderId
				WHERE 
					--(ch.intCommodityId = @intCommodityId AND @intCommodityId IS NOT NULL)
					(cd.intItemId = @intItemId AND @intItemId IS NOT NULL) 
			)
		)
	)
	BEGIN 
		RETURN 0
	END 

	RETURN 1
END