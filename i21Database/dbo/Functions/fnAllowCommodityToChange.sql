CREATE FUNCTION fnAllowCommodityToChange (
    @intItemId AS INT,
    @intCommodityId AS INT
)
RETURNS BIT
AS
BEGIN
    IF (@intItemId IS NOT NULL AND @intCommodityId IS NOT NULL)
    BEGIN
        IF (
            EXISTS (
                SELECT 1 FROM tblICInventoryTransaction t
                WHERE t.intItemId = @intItemId AND ISNULL(t.ysnIsUnposted, 0) = 0
            )
            OR EXISTS (
                SELECT 1 FROM tblICLot l
                WHERE l.dblQty <> 0 AND l.intItemId = @intItemId
            )
            OR EXISTS (
                SELECT 1
                FROM tblCTContractHeader ch
                INNER JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId
                WHERE cd.intItemId = @intItemId
            )
        )
        BEGIN 
            RETURN 0
        END
    END

    RETURN 1
END
