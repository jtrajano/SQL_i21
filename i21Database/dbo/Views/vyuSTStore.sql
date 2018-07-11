CREATE VIEW [dbo].[vyuSTStore]
AS
SELECT ST.* 
	   , PO.strPaymentOptionId
	   , CAST(CustomerCharge.strRegisterMop AS NVARCHAR(100)) AS strRegisterMopForCustomerCharge
	   , CAST(CashTransaction.strRegisterMop AS NVARCHAR(100)) AS strRegisterMopForCashTransaction
	   , CAST(LoyaltyDiscount.strRegisterMop AS NVARCHAR(100)) AS strRegisterMopForLoyaltyDiscount
	   , CAST(RemoveProprietart.strRegisterMop AS NVARCHAR(100)) AS strRegisterMopForRemoveProprietart
	   , CAST(AddProprietart.strRegisterMop AS NVARCHAR(100)) AS strRegisterMopForAddProprietart
	   , TG.strTaxGroup
	   , EM.strName
	   , ItemCustomerCharges.strItemNo AS strCustomerChargesItemNo
	   , ItemCustomerPayment.strItemNo AS strCustomerPaymentItemNo
	   , ItemOverShort.strItemNo AS strOverShortItemNo
	   , CAT.intCategoryId
	   , CAT.strCategoryCode
	   , CL.strLocationName
	   , CL.strLocationType
	   , EM.strEntityNo AS strVendorId
FROM tblSTStore ST
LEFT JOIN tblSTPaymentOption PO ON ST.intDefaultPaidoutId = PO.intPaymentOptionId
LEFT JOIN tblSTPaymentOption CustomerCharge ON ST.intCustomerChargeMopId = CustomerCharge.intPaymentOptionId
LEFT JOIN tblSTPaymentOption CashTransaction ON ST.intCashTransctionMopId = CashTransaction.intPaymentOptionId
LEFT JOIN tblSTPaymentOption LoyaltyDiscount ON ST.intLoyaltyDiscountMopId = LoyaltyDiscount.intPaymentOptionId
LEFT JOIN tblSTPaymentOption RemoveProprietart ON ST.intRemovePropCardMopId = RemoveProprietart.intPaymentOptionId
LEFT JOIN tblSTPaymentOption AddProprietart ON ST.intAddPropCardMopId = AddProprietart.intPaymentOptionId
LEFT JOIN tblSMTaxGroup TG ON ST.intTaxGroupId = TG.intTaxGroupId
LEFT JOIN tblEMEntity EM ON ST.intCheckoutCustomerId = EM.intEntityId
LEFT JOIN tblICItem ItemCustomerCharges ON ST.intCustomerChargesItemId = ItemCustomerCharges.intItemId
LEFT JOIN tblICItem ItemCustomerPayment ON ST.intCustomerPaymentItemId = ItemCustomerPayment.intItemId
LEFT JOIN tblICItem ItemOverShort ON ST.intOverShortItemId = ItemOverShort.intItemId
LEFT JOIN tblICCategory CAT ON ST.intLoyaltyDiscountCategoryId = CAT.intCategoryId
LEFT JOIN tblSMCompanyLocation CL ON ST.intCompanyLocationId = CL.intCompanyLocationId
