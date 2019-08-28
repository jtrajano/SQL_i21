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
    stpo.[intConcurrencyId]
FROM tblSTPaymentOption stpo
INNER JOIN tblSTStore st
	ON stpo.intStoreId = st.intStoreId
WHERE stpo.intPaymentOptionId NOT IN (ISNULL(st.intCustomerChargeMopId,0) , ISNULL(st.intCashTransctionMopId, 0))