CREATE VIEW [dbo].[vyuSTCheckoutHeaderReport]
	AS
SELECT 
intStoreId
, intStoreNo
, strRegion
, strDistrict
, strStoreDescription
, dtmCheckoutDate
, ysnPosted
, SUM(dblSalesAmount) dblSalesAmount
, SUM(dblAmountFuel) dblAmountFuel
, SUM(dblSaleTax) dblSaleTax
, SUM(dblAmountPaymentOption) dblAmountPaymentOption
, SUM(dblAmountCustomerCharges) dblAmountCustomerCharges
, SUM(dblAmountCustomerPayment) dblAmountCustomerPayment
, SUM(dblDeposit) dblDeposit
FROM (
SELECT  
ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CH.dtmCheckoutDate
, Inv.ysnPosted
, (SELECT SUM(CDT.dblTotalSalesAmount) 
	FROM tblSTCheckoutDepartmetTotals CDT 
	INNER JOIN tblICItem IT ON IT.intItemId = CDT.intItemId 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CDT.intCheckoutId = CH.intCheckoutId AND CDT.dblTotalSalesAmount > 0) dblSalesAmount
, (SELECT SUM(CPT.dblAmount)
	FROM tblSTCheckoutPumpTotals CPT 
	INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CPT.intPumpCardCouponId 
	INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CPT.intCheckoutId = CH.intCheckoutId AND CPT.dblAmount > 0) dblAmountFuel
, (SELECT SUM(STT.dblTotalTax) 
	FROM tblSTCheckoutSalesTaxTotals STT
	INNER JOIN tblGLAccount ACC ON ACC.intAccountId = STT.intSalesTaxAccount
	INNER JOIN tblICItem IT ON IT.intItemId = STT.intItemId 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE STT.intCheckoutId = CH.intCheckoutId  AND STT.dblTotalTax > 0) dblSaleTax
, (SELECT SUM(CPO.dblAmount) 
	FROM tblSTCheckoutPaymentOptions CPO 
	INNER JOIN tblGLAccount ACC ON ACC.intAccountId = CPO.intAccountId
	INNER JOIN tblSTPaymentOption PO ON PO.intPaymentOptionId = CPO.intPaymentOptionId
	INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CPO.intItemId 
	INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
	WHERE CPO.intCheckoutId = CH.intCheckoutId AND CPO.dblAmount > 0) dblAmountPaymentOption
, (SELECT SUM(CC.dblAmount) 
	FROM tblSTCheckoutCustomerCharges CC 
	INNER JOIN tblARCustomer Cust ON Cust.intEntityId = CC.intCustomerId
	INNER JOIN tblEMEntity Entity ON Entity.intEntityId = Cust.intEntityId
	INNER JOIN tblICItem IT ON IT.intItemId = CC.intProduct 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CC.intCheckoutId = CH.intCheckoutId AND CC.dblAmount > 0) dblAmountCustomerCharges
, (SELECT SUM(CT.dblAmount) 
	FROM tblSTCheckoutCustomerPayments CT
	INNER JOIN tblARCustomer Cust ON Cust.intEntityId = CT.intCustomerId
	INNER JOIN tblEMEntity Entity ON Entity.intEntityId = Cust.intEntityId
	INNER JOIN tblICItem IT ON IT.intItemId = CT.intItemId 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CT.intCheckoutId = CH.intCheckoutId AND CT.dblAmount > 0) dblAmountCustomerPayment
, (SELECT SUM(D.dblTotalDeposit) 
	FROM tblSTCheckoutDeposits D 
	WHERE D.intCheckoutId = CH.intCheckoutId AND D.dblTotalDeposit > 0) dblDeposit
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId = CH.intInvoiceId
) A
GROUP BY intStoreId, intStoreNo, strRegion, strDistrict, strStoreDescription, dtmCheckoutDate, ysnPosted