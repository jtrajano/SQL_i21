CREATE PROCEDURE [dbo].[uspSTUpdateShiftPhysicalCount]
	  @intCheckoutId INT
	, @intEntityUserSecurityId INT
	, @strHeaderNo NVARCHAR(50)
	, @intCompanyLocationId INT = 0
	, @intCountGroupId INT = 0
	, @strStatusMsg NVARCHAR(1000) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
SET @strStatusMsg = 'Success'

DELETE FROM tblSTCheckoutShiftPhysical
WHERE intCheckoutId = @intCheckoutId

;WITH LastShiftCount AS
(
	SELECT c.intCheckoutId, c.strCountNo, cd.intCountGroupId, cd.dblPhysicalCount, cd.intCheckoutShiftPhysicalId,
		ROW_NUMBER() OVER
        (
			PARTITION BY cd.intCountGroupId
            ORDER BY cd.intCheckoutShiftPhysicalId DESC
        ) AS intRank
    FROM tblSTCheckoutShiftPhysical cd
		INNER JOIN tblSTCheckoutHeader c ON c.intCheckoutId = cd.intCheckoutId
	WHERE ISNULL(NULLIF(c.strCountBy, ''), 'Item') = 'Pack'
		AND cd.intCountGroupId IS NOT NULL
		AND (cd.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
)
INSERT INTO tblSTCheckoutShiftPhysical(
	  intCheckoutId
	, dblSystemCount
	, strCountLine
	, dblQtyReceived
	, dblQtySold
	, intCountGroupId
	, intEntityUserSecurityId
	, intConcurrencyId
	, intSort)
SELECT
	  intCheckoutId
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



END TRY
BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
END CATCH