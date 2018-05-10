

 
 
 CREATE VIEW [dbo].[vyuCFTransactionForBatchRecalculate]
 AS
 
 SELECT 
 cfTrans.intTransactionId,
 cfTrans.strTransactionId,
 cfTrans.intSiteId,
 cfTrans.intNetworkId,
 cfTrans.dtmTransactionDate,
 cfAccount.intCustomerId,
 cfTrans.dblCalculatedTotalPrice AS dblTotalAmount,
 cfTrans.strPriceMethod,
 cfNetwork.strNetwork
 FROM tblCFTransaction AS cfTrans
 INNER JOIN tblCFNetwork AS cfNetwork
 ON cfTrans.intNetworkId = cfNetwork.intNetworkId
 LEFT OUTER JOIN tblCFCard AS cfCard
 ON cfTrans.intCardId = cfCard.intCardId
 LEFT OUTER JOIN tblCFAccount AS cfAccount
 ON cfCard.intAccountId = cfAccount.intAccountId
-- LEFT OUTER JOIN 
--(SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
--FROM         dbo.tblCFTransactionPrice 
--WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice 
--ON cfTrans.intTransactionId = cfTransPrice.intTransactionId
WHERE ISNULL(ysnPosted,0) = 0 
--AND  ISNULL(ysnInvalid,0) = 0