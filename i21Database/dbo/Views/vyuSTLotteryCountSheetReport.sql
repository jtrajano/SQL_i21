CREATE VIEW [dbo].[vyuSTLotteryCountSheetReport]
	AS 
SELECT DISTINCT
CH.dtmCheckoutDate 
, S.intStoreId
, S.intStoreNo
, LG.strGame
, S.strDescription
, LB.strBookNumber
, LB.strCountDirection
, LC.intBeginCount
, LC.intEndingCount
, LB.intBinNumber
, CH.intCheckoutId
FROM tblSTCheckoutLotteryCount LC
INNER JOIN tblSTCheckoutHeader CH ON CH.intCheckoutId = LC.intCheckoutId
INNER JOIN tblSTStore S ON S.intStoreId = CH.intStoreId
INNER JOIN tblSTLotteryBook LB ON LB.intLotteryBookId = LC.intLotteryBookId
INNER JOIN tblSTLotteryGame LG ON LG.intLotteryGameId = LB.intLotteryGameId
WHERE LB.strStatus = 'active'
