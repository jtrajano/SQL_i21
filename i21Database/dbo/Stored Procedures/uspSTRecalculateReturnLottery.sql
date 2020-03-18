
CREATE PROCEDURE [dbo].[uspSTRecalculateReturnLottery]
	@Success BIT OUTPUT,
	@StatusMsg NVARCHAR(1000) OUTPUT
AS

BEGIN TRY

DECLARE @tblSTUnpostedLotteryTempTable TABLE 
(
	 dblUnpostedQuantity	NUMERIC(18,6)
	,intLotteryBookId		INT
)

INSERT INTO @tblSTUnpostedLotteryTempTable
(
	 dblUnpostedQuantity
	,intLotteryBookId	
)
SELECT 
	 dblUnpostedQuantity = ISNULL(SUM(ISNULL(dblQuantitySold,0)),0) 
	,intLotteryBookId
FROM tblSTCheckoutLotteryCount
INNER JOIN tblSTCheckoutHeader 
ON tblSTCheckoutLotteryCount.intCheckoutId = tblSTCheckoutHeader.intCheckoutId
WHERE ISNULL(tblSTCheckoutHeader.ysnPosted,0) = 0 
GROUP BY intLotteryBookId


UPDATE tblSTReturnLottery
SET 
dblQuantity = ISNULL(tblSTReturnLottery.dblOriginalQuantity,0) - ISNULL([@tblSTUnpostedLotteryTempTable].dblUnpostedQuantity,0),
ysnReadyForPosting = CASE WHEN ISNULL([@tblSTUnpostedLotteryTempTable].dblUnpostedQuantity,0) = 0 THEN 1 ELSE 0 END
FROM tblSTReturnLottery
LEFT JOIN @tblSTUnpostedLotteryTempTable
ON tblSTReturnLottery.intLotteryBookId = [@tblSTUnpostedLotteryTempTable].intLotteryBookId

SET @Success = 1
SET @StatusMsg = CAST(@@ROWCOUNT AS NVARCHAR(MAX)) + ' rows affected.'

END TRY 
BEGIN CATCH

	SET @Success = 0
	SET @StatusMsg = ERROR_MESSAGE()

END CATCH 