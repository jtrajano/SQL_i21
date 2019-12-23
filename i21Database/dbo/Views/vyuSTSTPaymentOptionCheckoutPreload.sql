CREATE VIEW [dbo].[vyuSTSTPaymentOptionCheckoutPreload]
AS
SELECT 
	stpo.[intPaymentOptionId], 
    stpo.[intStoreId], 
    stpo.[strPaymentOptionId], 
    stpo.[strDescription], 
	stpo.[intItemId], 
    stpo.[intAccountId], 
    stpo.[strRegisterMop],  
	stpo.[ysnDepositable], 
	stpo.[strNetworkCreditCardName],
	stpo.[ysnSkipImport],
    stpo.[intConcurrencyId],

	-- Not Map
	item.strItemNo,
	item.strDescription		AS strItemDescription,
	st.intStoreNo,
	gl.strAccountId,
	gl.strDescription		AS strAccountDescription
FROM tblSTPaymentOption stpo
INNER JOIN tblSTStore st
	ON stpo.intStoreId = st.intStoreId
INNER JOIN tblICItem item
	ON stpo.intItemId = item.intItemId
LEFT JOIN tblGLAccount gl
	ON stpo.intAccountId = gl.intAccountId
WHERE stpo.intPaymentOptionId NOT IN (ISNULL(st.intCustomerChargeMopId,0) , ISNULL(st.intCashTransctionMopId, 0))