CREATE VIEW [dbo].[vyuAPVendorInquiry]
AS

SELECT 
	entity.intEntityId
	,entity.strName
	,CASE WHEN vendor.strVendorId = '' THEN entity.strEntityNo ELSE vendor.strVendorId END AS strEntityNo
	,entityContact.strPhone
	,entityContact.strEmail
	,entityContact.strMobile
	,entityContact.strName AS strContactName
	,fi.strLastVoucher
	,fi.intLastBillId
	,fi.dtmLastPaymentDate
	,fi.intLastPaymentId
	,fi.dblYTDVouchers
	,fi.dblYTDPayments
	,balances.dblFuture
	,balances.dbl0To30Days
	,balances.dbl31To60Days
	,balances.dbl61To90Days
FROM dbo.tblAPVendor vendor
INNER JOIN dbo.tblEMEntity entity ON vendor.intEntityId = entity.intEntityId
INNER JOIN dbo.tblEMEntityToContact entityToContact ON entityToContact.intEntityId = entity.intEntityId
INNER JOIN dbo.tblEMEntity entityContact
		ON entityToContact.intEntityContactId = entityContact.intEntityId AND entityToContact.ysnDefaultContact = 1
OUTER APPLY dbo.fnAPVendorInquiryFinancialInfo(vendor.intEntityId) fi
OUTER APPLY dbo.fnAPGetVendorBalances(vendor.intEntityId) balances
