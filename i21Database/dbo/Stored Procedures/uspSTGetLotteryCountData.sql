CREATE PROCEDURE [dbo].[uspSTGetLotteryCountData]
	@date DATETIME,
	@storeId INT,
	@checkoutId INT,
	@shiftNo INT
AS

DECLARE @tblSTOuputTable TABLE
(
	 intBeginCount			INT
	,dtmSoldDate			DATETIME
	,strStatus				NVARCHAR(MAX)
	,ysnBookSoldOut			BIT
	,intStoreId				INT
	,intLotteryBookId		INT
	,intBinNumber			INT
	,strGame				NVARCHAR(MAX)
	,intLotteryGameId		INT
	,strBookNumber			NVARCHAR(MAX)
	,strCountDirection		NVARCHAR(MAX)
	,intStartingNumber		INT
	,dblTicketValue			NUMERIC(18,6)
	,intTicketPerPack		INT
	,intEndingNumber		INT
	,intConcurrencyId		INT
	,intItemId				INT
	,strItemDescription		NVARCHAR(MAX)
	,strItemNo				NVARCHAR(MAX)
	,strLongUPCCode			NVARCHAR(MAX)
	,intCategoryId			INT
	,strCategoryCode		NVARCHAR(MAX)
	,strCategoryDescription	NVARCHAR(MAX)
	,intItemUOMId			INT
	,strSoldOut				NVARCHAR(MAX)
)

-- DECLARE @shiftNo INT 
-- SELECT TOP 1 @shiftNo = intShiftNo FROM tblSTCheckoutHeader WHERE intCheckoutId = @checkoutId


SELECT tblSTCheckoutLotteryCount.* INTO #tempLotteryCount
FROM tblSTCheckoutLotteryCount 
INNER JOIN tblSTReturnLottery ON tblSTCheckoutLotteryCount.intLotteryBookId = tblSTReturnLottery.intLotteryBookId
INNER JOIN tblSTLotteryBook ON tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
WHERE tblSTCheckoutLotteryCount.intCheckoutId = @checkoutId 
AND LOWER(tblSTLotteryBook.strStatus) = 'returned' AND tblSTReturnLottery.dtmReturnDate != @date


INSERT INTO @tblSTOuputTable
(
	 intBeginCount			
	,dtmSoldDate			
	,strStatus				
	,ysnBookSoldOut			
	,intStoreId				
	,intLotteryBookId		
	,intBinNumber			
	,strGame				
	,intLotteryGameId		
	,strBookNumber			
	,strCountDirection		
	,intStartingNumber		
	,dblTicketValue			
	,intTicketPerPack		
	,intEndingNumber		
	,intConcurrencyId		
	,intItemId				
	,strItemDescription		
	,strItemNo				
	,strLongUPCCode			
	,intCategoryId			
	,strCategoryCode		
	,strCategoryDescription	
	,intItemUOMId			
	,strSoldOut				
)
SELECT 
*
,strSoldOut = 
CASE WHEN LOWER(strStatus) = 'sold' 
	THEN 'Yes'
	ELSE
			CASE 
			WHEN strCountDirection = 'Low to High' 
				THEN 
				CASE WHEN intEndingNumber =  intBeginCount
					THEN 'Yes' ELSE 'No'
				END
			ELSE 
				CASE WHEN intStartingNumber = intBeginCount
					THEN 'Yes' ELSE 'No'
				END
		END
	END
FROM
(
SELECT 
intBeginCount = CASE 
	WHEN LOWER(strStatus) = 'sold' 
	THEN 0
	ELSE
		CASE WHEN ISNULL(intPriorCheckoutCount,0) != 0 
		THEN intPriorCheckoutBeginCount 
		ELSE 
			CASE WHEN strCountDirection = 'Low to High' THEN intStartingNumber ELSE CAST(intEndingNumber AS INT) END
		END
	END
,dtmSoldDate	
,strStatus	
,ysnBookSoldOut = CASE WHEN LOWER(strStatus) = 'sold' 
	THEN CAST(1 AS bit)
	ELSE CAST(0 AS bit)
	END
,intStoreId	
,intLotteryBookId	
,intBinNumber	
,strGame	
,intLotteryGameId	
,strBookNumber	
,strCountDirection	
,intStartingNumber	
,dblTicketValue	
,intTicketPerPack	
,intEndingNumber
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
	intPriorCheckoutBeginCount = ISNULL((
	SELECT TOP 1 ISNULL(tblSTCheckoutLotteryCount.intEndingCount,0) FROM tblSTCheckoutHeader 
		INNER JOIN tblSTCheckoutLotteryCount 
		ON tblSTCheckoutHeader.intCheckoutId = tblSTCheckoutLotteryCount.intCheckoutId
		WHERE tblSTCheckoutHeader.intStoreId = @storeId
		AND tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		AND ( (tblSTCheckoutHeader.dtmCheckoutDate < @date) OR (tblSTCheckoutHeader.dtmCheckoutDate = @date AND tblSTCheckoutHeader.intShiftNo < @shiftNo))
		--GROUP BY tblSTCheckoutHeader.intCheckoutId
		ORDER BY tblSTCheckoutHeader.dtmCheckoutDate DESC , tblSTCheckoutHeader.intShiftNo DESC

	),0),
	
	intPriorCheckoutCount = ISNULL((
		SELECT TOP 1 COUNT(1) FROM tblSTCheckoutHeader 
		INNER JOIN tblSTCheckoutLotteryCount 
		ON tblSTCheckoutHeader.intCheckoutId = tblSTCheckoutLotteryCount.intCheckoutId
		WHERE tblSTCheckoutHeader.intStoreId = @storeId
		AND tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		AND ( (tblSTCheckoutHeader.dtmCheckoutDate < @date) OR (tblSTCheckoutHeader.dtmCheckoutDate = @date AND tblSTCheckoutHeader.intShiftNo < @shiftNo))
		GROUP BY tblSTCheckoutHeader.dtmCheckoutDate,tblSTCheckoutHeader.intShiftNo
		ORDER BY tblSTCheckoutHeader.dtmCheckoutDate DESC , tblSTCheckoutHeader.intShiftNo DESC

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
	tblSTLotteryGame.dblTicketValue, 
	tblSTLotteryGame.intTicketPerPack, 
	tblSTLotteryGame.intStartingNumber,
	tblSTLotteryGame.intEndingNumber,
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
	LEFT JOIN tblSTLotteryGame 
	ON tblSTLotteryGame.intLotteryGameId = tblSTLotteryBook.intLotteryGameId
	INNER JOIN vyuSTItemPricingOnFirstLocation 
	ON vyuSTItemPricingOnFirstLocation.intItemId = tblSTLotteryGame.intItemId
	LEFT JOIN tblSTReturnLottery
	ON tblSTReturnLottery.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
	WHERE ('active' = LOWER(strStatus)
	OR ( ('sold' = LOWER(strStatus)) AND (dtmSoldDate = @date)) 
	OR 'returned' = LOWER(strStatus) AND ( tblSTReturnLottery.dtmReturnDate = @date)) 
	AND tblSTLotteryBook.intStoreId = @storeId
	

) as tblSTCompileData
) as tblSTCompileData1
ORDER BY 
intBinNumber ASC
