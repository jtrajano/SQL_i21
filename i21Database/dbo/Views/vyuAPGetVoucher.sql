CREATE VIEW vyuAPGetVoucher

AS

SELECT b.intBillId
	, b.intAccountId
	, gl.strAccountId
	, b.intBillBatchId
	, b.intConcurrencyId
	, b.intContactId
	, strContactName = contact.strName
	, b.intCurrencyId
	, cur.strCurrency
	, b.intEntityId
	, b.intEntityVendorId
	, b.intOrderById
	, strOrderedBy = orderBy.strUserName
	, b.intPayToAddressId
	, strPayTo = payTo.strLocationName
	, b.intPurchaseOrderId
	, b.intShipFromId
	, strShipFrom = enLocFrom.strLocationName
	, b.intShipFromEntityId
	, strShipFromEntity = sfEn.strName
	, b.intShipToId
	, strShipTo = enLocTo.strLocationName
	, b.intShipViaId
	, sv.strShipVia
	, strUserLocation = loc.strLocationName
	, b.intStoreLocationId
	, b.intSubCurrencyCents
	, b.intTermsId
	, t.strTerm
	, b.intBookId
	, book.strBook
	, b.intSubBookId
	, subBook.strSubBook
	, b.intTransactionReversed
	, b.intTransactionType
	, b.intUserId
	, b.intVoucherDifference
	, b.intBankInfoId
	, ba.strBankAccountNo
	, b.dbl1099
	, b.dblAmountDue
	, b.dblDiscount
	, b.dblInterest
	, b.dblPayment
	, b.dblSubtotal
	, b.dblTax
	, b.dblTotal
	, b.dblTotalController
	, b.dblWithheld
	, b.strApprovalNotes
	, b.strBillId
	, b.strComment
	, b.strPONumber
	, b.strReference
	, b.strRemarks
	, b.strShipFromAddress
	, b.strShipFromAttention
	, b.strShipFromCity
	, b.strShipFromCountry
	, b.strShipFromPhone
	, b.strShipFromState
	, b.strShipFromZipCode
	, b.strShipToAddress
	, b.strShipToAttention
	, b.strShipToCity
	, b.strShipToCountry
	, b.strShipToPhone
	, b.strShipToState
	, b.strShipToZipCode
	, b.strVendorOrderNumber
	, b.dtmApprovalDate
	, b.dtmBillDate
	, b.dtmDate
	, b.dtmDateCreated
	, b.dtmDatePaid
	, b.dtmDeferredInterestDate
	, b.dtmInterestAccruedThru
	, b.dtmDueDate
	, b.ysnPaid
	, b.ysnPosted
	, b.ysnProcessedClaim
	, b.ysnIsPaymentScheduled
	, b.ysnOldPrepayment
	, b.ysnOrigin
	, b.ysnReadyForPayment
	, b.ysnRecurring
	, b.ysnDiscountOverride
	, b.ysnPrepayHasPayment
	, strName = ve.strName
	, strVendorId = v.strVendorId
	, strDetailAccountId = CASE WHEN details.strAccountId IS NULL THEN gl.strAccountId ELSE details.strAccountId END
	, dblActual = ISNULL(details.dblActual, 0)
FROM tblAPBill b
JOIN tblGLAccount gl ON gl.intAccountId = b.intAccountId
JOIN tblAPVendor v ON v.intEntityId = b.intEntityVendorId
JOIN tblEMEntity ve ON ve.intEntityId = v.intEntityId
JOIN tblSMTerm t ON t.intTermID = b.intTermsId
JOIN tblSMCurrency cur ON cur.intCurrencyID = b.intCurrencyId
JOIN tblEMEntityLocation enLocFrom ON enLocFrom.intEntityLocationId = b.intShipFromId
LEFT JOIN tblEMEntityLocation enLocTo ON enLocTo.intEntityLocationId = b.intShipToId
JOIN tblEMEntity sfEn ON sfEn.intEntityId = b.intShipFromEntityId
LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = intStoreLocationId
JOIN tblEMEntityLocation payTo ON payTo.intEntityLocationId = b.intPayToAddressId
LEFT JOIN tblSMShipVia sv ON sv.intEntityId = b.intShipViaId
LEFT JOIN tblCTBook book ON book.intBookId = b.intBookId
LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = b.intSubBookId
LEFT JOIN tblEMEntity contact ON contact.intEntityId = b.intContactId
LEFT JOIN tblSMUserSecurity orderBy ON orderBy.intEntityId = b.intOrderById
LEFT JOIN vyuCMBankAccount ba ON ba.intBankAccountId = b.intBankInfoId
CROSS APPLY (
	SELECT TOP 1 bd.dblActual
		, gld.strAccountId
	FROM tblAPBillDetail bd
	JOIN tblGLAccount gld ON gld.intAccountId = bd.intAccountId
	WHERE bd.intBillId = b.intBillId
) details