CREATE PROCEDURE [dbo].[uspSTGetLotteryCountData]
	@date DATETIME,
	@storeId INT
AS
SELECT 
intBeginCount = CASE WHEN ISNULL(intPriorCheckoutCount,0) != 0 
THEN intPriorCheckoutCount 
ELSE 
	CASE WHEN strCountDirection = 'Low to High' THEN intPriorCheckoutCount ELSE CAST(dblQuantityRemaining AS INT) END
END
,dtmSoldDate	
,strStatus	
,intStoreId	
,intLotteryBookId	
,intBinNumber	
,strGame	
,intLotteryGameId	
,strBookNumber	
,strCountDirection	
,strSoldOut	
,intStartingNumber	
,dblTicketValue	
,intTicketPerPack	
,intConcurrencyId	
,intItemId	
,strItemDescription	
,strItemNo	
,strLongUPCCode	
,intCategoryId	
,strCategoryCode	
,strCategoryDescription	
,intItemUOMId
FROM (

SELECT 
	intPriorCheckoutCount = ISNULL((
	SELECT TOP 1 ISNULL(tblSTCheckoutLotteryCount.intEndingCount,0) FROM tblSTCheckoutHeader 
		INNER JOIN tblSTCheckoutLotteryCount 
		ON tblSTCheckoutHeader.intCheckoutId = tblSTCheckoutLotteryCount.intCheckoutId
		WHERE tblSTCheckoutHeader.intStoreId = @storeId
		AND tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		AND ( (tblSTCheckoutHeader.dtmCheckoutDate < @date) OR (tblSTCheckoutHeader.dtmCheckoutDate = @date))
		ORDER BY tblSTCheckoutHeader.intCheckoutId DESC
	),0),
	tblSTLotteryBook.dblQuantityRemaining,
	tblSTLotteryBook.dtmSoldDate,
	tblSTLotteryBook.strStatus,
    tblSTLotteryBook.intStoreId,
    tblSTLotteryBook.intLotteryBookId, 
    tblSTLotteryBook.intBinNumber, 
    tblSTLotteryGame.strGame, 
	tblSTLotteryGame.intLotteryGameId,
    tblSTLotteryBook.strBookNumber, 
    tblSTLotteryBook.strCountDirection, 
    CASE WHEN (N'sold' = (LOWER(strStatus))) THEN N'Yes' ELSE N'No' END AS strSoldOut, 
    intStartingNumber, 
    tblSTLotteryGame.dblTicketValue, 
    intTicketPerPack, 
    tblSTLotteryBook.intConcurrencyId,
	tblSTLotteryGame.intItemId,
	vyuSTItemPricingOnFirstLocation.strItemDescription,
	vyuSTItemPricingOnFirstLocation.strItemNo,
	vyuSTItemPricingOnFirstLocation.strLongUPCCode,
	vyuSTItemPricingOnFirstLocation.intCategoryId,
	vyuSTItemPricingOnFirstLocation.strCategoryCode,
	vyuSTItemPricingOnFirstLocation.strCategoryDescription,
	vyuSTItemPricingOnFirstLocation.intItemUOMId
    FROM tblSTLotteryBook
    INNER JOIN tblSTLotteryGame 
	ON tblSTLotteryGame.intLotteryGameId = tblSTLotteryBook.intLotteryGameId
	INNER JOIN vyuSTItemPricingOnFirstLocation 
	ON vyuSTItemPricingOnFirstLocation.intItemId = tblSTLotteryGame.intItemId
    WHERE ('active' = LOWER(strStatus)
	OR ( ('sold' = LOWER(strStatus)) AND (dtmSoldDate = @date)) 
	OR 'returned' = LOWER(strStatus)) 
	AND tblSTLotteryBook.intStoreId = @storeId
	

) as tblSTCompileData
ORDER BY 
intBinNumber ASC