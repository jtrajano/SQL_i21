CREATE PROCEDURE [dbo].[uspICUpdateInventoryShiftCountDetails]
	  @intInventoryCountId INT
	, @intEntityUserSecurityId INT
	, @strHeaderNo NVARCHAR(50)
	, @intLocationId INT = 0
	, @intCountGroupId INT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DELETE FROM tblICInventoryCountDetail
WHERE intInventoryCountId = @intInventoryCountId

;WITH LastShiftCount AS
(
	SELECT c.intInventoryCountId, c.strCountNo, cd.intCountGroupId, cd.dblPhysicalCount, cd.intInventoryCountDetailId,
		ROW_NUMBER() OVER
        (
			PARTITION BY cd.intCountGroupId
            ORDER BY cd.intInventoryCountDetailId DESC
        ) AS intRank
    FROM tblICInventoryCountDetail cd
		INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = cd.intInventoryCountId
	WHERE ISNULL(NULLIF(c.strCountBy, ''), 'Item') = 'Pack'
		AND cd.intCountGroupId IS NOT NULL
		AND (cd.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
)
INSERT INTO tblICInventoryCountDetail(
	  intInventoryCountId
	, dblSystemCount
	, strCountLine
	, dblQtyReceived
	, dblQtySold
	, intCountGroupId
	, intEntityUserSecurityId
	, intConcurrencyId
	, intSort)
SELECT
	  @intInventoryCountId
	, ISNULL(sc.dblPhysicalCount, 0.00)
	, @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY sc.intCountGroupId ASC) AS NVARCHAR(50))
	, 0.00
	, 0.00
	, cg.intCountGroupId
	, intEntityUserSecurityId = @intEntityUserSecurityId
	, intConcurrencyId = 1
	, intSort = 1
FROM tblICCountGroup cg
OUTER APPLY (
	SELECT lsc.*
	FROM LastShiftCount lsc
	WHERE lsc.intRank = 1
		AND lsc.intCountGroupId = cg.intCountGroupId
) sc
WHERE (cg.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)