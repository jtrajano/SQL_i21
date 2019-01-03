CREATE VIEW [dbo].[vyuSTCheckoutHeaderReport]
	AS
SELECT 
intStoreId
, intStoreNo
, strRegion
, strDistrict
, strStoreDescription
, dtmCheckoutDate
, ISNULL(ysnPosted, 0) ysnPosted
, SUM(ISNULL(dblSalesAmount, 0)) dblSalesAmount
, SUM(ISNULL(dblAmountFuel, 0)) dblAmountFuel
, SUM(ISNULL(dblSaleTax, 0)) dblSaleTax
, SUM(ISNULL(dblAmountPaymentOption, 0)) dblAmountPaymentOption
, SUM(ISNULL(dblAmountCustomerCharges, 0)) dblAmountCustomerCharges
, SUM(ISNULL(dblAmountCustomerPayment, 0)) dblAmountCustomerPayment
, SUM(ISNULL(dblDeposit, 0)) dblDeposit
FROM (
SELECT  
ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CH.dtmCheckoutDate
, Inv.ysnPosted
, (SELECT SUM(ISNULL(CDT.dblTotalSalesAmountComputed, 0)) 
	FROM tblSTCheckoutDepartmetTotals CDT 
	INNER JOIN tblICItem IT ON IT.intItemId = CDT.intItemId 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CDT.intCheckoutId = CH.intCheckoutId 
		AND (CDT.dblTotalSalesAmountComputed <> 0
		OR CDT.intTotalSalesCount <> 0)) dblSalesAmount
, (SELECT SUM(ISNULL(CPT.dblAmount, 0))
	FROM tblSTCheckoutPumpTotals CPT 
	INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CPT.intPumpCardCouponId 
	INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CPT.intCheckoutId = CH.intCheckoutId AND CPT.dblAmount <> 0) dblAmountFuel
, (SELECT SUM(ISNULL(STT.dblTotalTax, 0)) 
	FROM tblSTCheckoutSalesTaxTotals STT
	INNER JOIN tblGLAccount ACC ON ACC.intAccountId = STT.intSalesTaxAccount
	INNER JOIN tblICItem IT ON IT.intItemId = STT.intItemId 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE STT.intCheckoutId = CH.intCheckoutId AND STT.dblTotalTax <> 0) dblSaleTax
, (SELECT SUM(ISNULL(CPO.dblAmount, 0)) 
	FROM tblSTCheckoutPaymentOptions CPO 
	LEFT JOIN tblGLAccount ACC ON ACC.intAccountId = CPO.intAccountId
	INNER JOIN tblSTPaymentOption PO ON PO.intPaymentOptionId = CPO.intPaymentOptionId
	INNER JOIN tblICItem IT ON IT.intItemId = CPO.intItemId
	--INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CPO.intItemId 
	--INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
	WHERE CPO.intCheckoutId = CH.intCheckoutId AND CPO.dblAmount <> 0) dblAmountPaymentOption
, (SELECT SUM(ISNULL(CC.dblAmount, 0)) 
	FROM tblSTCheckoutCustomerCharges CC 
	INNER JOIN tblARCustomer Cust ON Cust.intEntityId = CC.intCustomerId
	INNER JOIN tblEMEntity Entity ON Entity.intEntityId = Cust.intEntityId
	INNER JOIN tblICItem IT ON IT.intItemId = CC.intProduct 
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CC.intCheckoutId = CH.intCheckoutId AND CC.dblAmount <> 0) dblAmountCustomerCharges
, (SELECT SUM(ISNULL(CT.dblPaymentAmount, 0)) 
	FROM tblSTCheckoutCustomerPayments CT
	INNER JOIN tblARCustomer Cust ON Cust.intEntityId = CT.intCustomerId
	INNER JOIN tblEMEntity Entity ON Entity.intEntityId = Cust.intEntityId
	--INNER JOIN tblICItem IT ON IT.intItemId = CT.intItemId 
	--INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
	WHERE CT.intCheckoutId = CH.intCheckoutId AND CT.dblPaymentAmount <> 0) dblAmountCustomerPayment
, (SELECT SUM(ISNULL(D.dblTotalDeposit, 0)) 
	FROM tblSTCheckoutDeposits D 
	WHERE D.intCheckoutId = CH.intCheckoutId AND D.dblTotalDeposit <> 0) dblDeposit
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId = CH.intInvoiceId
) A
GROUP BY intStoreId, intStoreNo, strRegion, strDistrict, strStoreDescription, dtmCheckoutDate, ysnPosted