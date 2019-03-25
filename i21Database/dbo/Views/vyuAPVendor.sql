﻿CREATE VIEW [dbo].[vyuAPVendor]
--WITH SCHEMABINDING
	AS 
SELECT 
	A.intEntityId,
	A.strName, 
	A.strWebsite,
	A.strInternalNotes,
	--B.[intEntityId],
	B.intCurrencyId,
	B.intGLAccountExpenseId,
	D.intEntityId AS intDefaultContactId,
	C.intEntityLocationId AS intDefaultLocationId,
	F.strAccountId AS strExpenseAccountId,
	B.intPaymentMethodId,
	A.str1099Form,
	A.str1099Name,
	A.str1099Type,
	A.dtmW9Signed,
	A.ysnPrint1099,
	A.strFederalTaxId,
	B.strTaxState,
	B.strVendorAccountNum,
	strVendorId= case when B.strVendorId = '' then A.strEntityNo else B.strVendorId end,
	B.strVendorPayToId,
	B.ysnPymtCtrlActive,
	B.ysnPymtCtrlAlwaysDiscount,
	B.ysnPymtCtrlEFTActive,
	B.ysnPymtCtrlHold,
	B.ysnWithholding,
	B.dblCreditLimit,
	C.intShipViaId,
	--C.intTaxCodeId,
	CASE WHEN C.intTermsId > 0 THEN C.intTermsId ELSE B.intTermsId  END as intTermsId,
	--C.strContactName,
	C.strAddress,
	C.strCity,
	C.strCountry,
	C.strNotes,
	C.strState,
	C.strZipCode,
	--D2.strEmail,
	D.strEmail,
	D.strEmail2,
	D.strFax,
	--D.strLocationName,
	D.strMobile,
	D.strPhone,
	D.strPhone2,
	D.strTitle,
	E.strCurrency,
	ysnHasPayables = CAST((CASE WHEN EXISTS(SELECT 1 
											FROM dbo.tblAPBill G 
											WHERE G.ysnPosted = 1 AND G.ysnPaid = 0 AND G.[intEntityVendorId] = B.[intEntityId]
											UNION 
											SELECT 1
											FROM tblARInvoice AA
											WHERE 
												NOT EXISTS( SELECT TOP 1 1 
															FROM tblAPBillDetail apbilldetail
															INNER JOIN tblAPBill apbill 
																ON apbilldetail.intBillId = apbill.intBillId 
															WHERE apbill.ysnPosted = 1
																AND intInvoiceId = AA.intInvoiceId
														   )
												AND AA.strTransactionType IN ('Cash Refund','Invoice','Debit Memo', 'Cash')
												AND AA.ysnPosted = 1
												AND AA.intEntityCustomerId = B.[intEntityId]
											) 
						THEN 1 ELSE 0 END) AS BIT),
	B.intApprovalListId,
	C.intFreightTermId,
	H.strPaymentMethod,
	B.ysnOneBillPerPayment,
	B.strFLOId,
	intCent = CASE WHEN (SELECT TOP 1 intCent from tblSMCurrency where intMainCurrencyId = B.intCurrencyId) IS NOT NULL THEN 0 ELSE E.intCent END,
	ysnSubCurrency = ISNULL(E.ysnSubCurrency, 0),
	intSubCurrencyCent = (SELECT TOP 1 intCent from tblSMCurrency where intMainCurrencyId = B.intCurrencyId),

	B.strStoreFTPPath,
	B.strStoreFTPUsername,
	B.strStoreFTPPassword,
	B.intStoreStoreId,
	I.intStoreNo,
	B.intProtocolNumber,
	B.intPortNumber,
	B.intChainAccountNumber,
	B.intCsvFormat,
	storeDescription = I.strDescription,
	ysnTransportTerminal
	,strTerm = J.strTerm
	,CAST(CASE WHEN lien.intEntityVendorId IS NULL THEN 0 ELSE 1 END AS BIT) ysnHasLien
FROM
		dbo.tblEMEntity A
	INNER JOIN dbo.tblAPVendor B
		ON A.intEntityId = B.[intEntityId]
	INNER JOIN tblEMEntityType EntType
		ON EntType.intEntityId = B.[intEntityId]
			AND EntType.strType = 'Vendor'
	INNER JOIN dbo.[tblEMEntityLocation] C
		ON B.[intEntityId] = C.intEntityId and C.ysnDefaultLocation = 1
	--INNER JOIN (dbo.tblEMEntityContact D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityContactId] = D2.intEntityId)
	--	ON B.intDefaultContactId = D.[intEntityContactId]
	INNER JOIN dbo.[tblEMEntityToContact] G
		ON G.intEntityId = A.intEntityId
	INNER JOIN dbo.tblEMEntity D
		ON G.intEntityContactId = D.[intEntityId] AND G.ysnDefaultContact = 1
	LEFT JOIN dbo.tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
	LEFT JOIN dbo.tblGLAccount F 
		ON B.intGLAccountExpenseId = F.intAccountId
	LEFT JOIN dbo.tblSMPaymentMethod H
		ON B.intPaymentMethodId = H.intPaymentMethodID
	LEFT JOIN dbo.tblSTStore I
		ON I.intStoreId = B.intStoreStoreId
	LEFT JOIN tblSMTerm J
		ON B.intTermsId = J.intTermID
	LEFT JOIN tblAPVendorLien lien
		ON lien.intEntityVendorId = A.intEntityId