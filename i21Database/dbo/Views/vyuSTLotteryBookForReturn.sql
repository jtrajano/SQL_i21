
CREATE VIEW vyuSTLotteryBookForReturn
AS
SELECT 
dblQuantityRemaining,
dtmActivateDate,
dtmReceiptDate,
tblSTLotteryBook.intConcurrencyId,
intLotteryBookId,
tblSTLotteryGame.intLotteryGameId,
tblSTStore.intStoreId,
intBinNumber,
strBookNumber,
tblSTLotteryBook.strStatus,
strCountDirection,
strGame = tblSTLotteryGame.strGame,
intStoreNo = tblSTStore.intStoreNo,
strStoreDescription = tblSTStore.strDescription,
strItemDescription = tblICItem.strDescription,
dblTicketCost = tblSTLotteryGame.dblInventoryCost,
dblTicketValue = tblSTLotteryGame.dblTicketValue,
strState = tblSTStore.strState 
FROM tblSTLotteryBook
INNER JOIN tblSTLotteryGame
ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
INNER JOIN tblSTStore 
ON tblSTLotteryBook.intStoreId = tblSTStore.intStoreId
LEFT JOIN tblICItem 
ON tblSTLotteryGame.intItemId = tblICItem.intItemId 
WHERE LOWER(tblSTLotteryBook.strStatus) != 'returned' 
AND LOWER(tblSTLotteryBook.strStatus) != 'sold'


