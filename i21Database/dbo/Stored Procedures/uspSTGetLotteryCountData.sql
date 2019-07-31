CREATE PROCEDURE [dbo].[uspSTGetLotteryCountData]
	@date DATETIME,
	@storeId INT
AS

SELECT 
	intBeginCount = ISNULL((
		SELECT TOP 1 ISNULL(tblSTCheckoutLotteryCount.intEndingCount,0) FROM tblSTCheckoutHeader 
		INNER JOIN tblSTCheckoutLotteryCount 
		ON tblSTCheckoutHeader.intCheckoutId = tblSTCheckoutLotteryCount.intCheckoutId
		WHERE tblSTCheckoutHeader.intStoreId = @storeId
		AND tblSTCheckoutHeader.dtmCheckoutDate < @date
		AND tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		ORDER BY dtmCheckoutDate DESC
	),0),
	tblSTLotteryBook.dtmSoldDate,
	tblSTLotteryBook.strStatus,
    tblSTLotteryBook.intStoreId,
    tblSTLotteryBook.intLotteryBookId, 
    tblSTLotteryBook.strBinNumber, 
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
	ORDER BY 
    tblSTLotteryBook.strBinNumber ASC



