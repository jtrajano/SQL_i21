CREATE VIEW [dbo].[vyuSTCSLatestCheckoutWithError]
AS
SELECT ch.intStoreId, cpew.intCheckoutId
FROM tblSTCheckoutProcessErrorWarning cpew
JOIN tblSTCheckoutHeader ch
	ON cpew.intCheckoutId = ch.intCheckoutId
WHERE  ch.strCheckoutStatus <> 'Posted'
AND cpew.strMessageType IN ('S', 'F')