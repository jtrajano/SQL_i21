CREATE VIEW [dbo].[vyuAPInboundTaxReportView]
AS

SELECT
	 APBD.intBillDetailId
	,APB.intBillId
	,strVendorName =  E.strName
	,strVendorNumber = E.strEntityNo
	,strVendorFederalTaxId = E.strFederalTaxId 
	,strVendorStateTaxId = E.strStateTaxId
	,APB.strBillId
	,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL)) COLLATE Latin1_General_CI_AS
	,strVendorCity = ISNULL(EL.strCity, 'N/A')
	,strVendorState = ISNULL(EL.strState, 'N/A')
	,strVendorZipCode = ISNULL(EL.strZipCode,'N/A')
	,strVendorCounty = ISNULL(EL.strCounty,'N/A')
	,strVendorEmail = ISNULL(vendor.strEmail, vendor.strEmail2)
	,strVendorPhone = ISNULL(vendor.strPhone, vendor.strPhone2)
	,RT.strTaxCode
	,strTaxAgency = RT.strTaxAgency
	,strTaxCodeDescription = RT.strDescription
	,strTaxClassDescription =RT.strTaxClass
	,strTaxCodePointFrom = RT.strTaxPoint
	,RT.strCalculationMethod
	,dtmDatePaid = CASE WHEN APB.ysnPaid = 1 THEN payment.dtmDatePaid ELSE NULL END
	,dtmInvoicePostDate = APB.dtmDate
	,dtmInvoiceDate = APB.dtmBillDate
	,dtmInvoiceDueDate = dtmDueDate
	,C.strCommodityCode 
	,strItem = IE.strItemNo
	,strShipFromLocation = ELS.strLocationName COLLATE Latin1_General_CI_AS
	,strShipFromName = ELS.strCheckPayeeName
	,strShipFromAddress = ELS.strAddress
	,strShipFromCity = ELS.strCity
	,strShipFromState = ELS.strState
	,strShipFromCountry = ELS.strCountry
	,strDebitAccount = account.strAccountId
	,strCreditAccount = apaccount.strAccountId
	,strTaxAccount = RT.strAccountId
	,APBD.dblTax
	,APBD.dblQtyReceived
	,strUnitOfMeasure = UM.strUnitMeasure
	,dblPaymentAmount = ISNULL(payment.dblAmountPaid, 0.00)
	,dblNontaxablePurchase = CASE WHEN ISNULL(APBD.dblTax, 0) = 0 THEN APBD.dblTotal ELSE 0.00 END
	,dblTaxablePurchase = CASE WHEN ISNULL(APBD.dblTax, 0) = 0 THEN 0.00 ELSE APBD.dblTotal END
	,dblGross = APBD.dblTotal
	,dblTaxRate = RT.dblRate
	,ysnPaid = APB.ysnPaid
	,strCheckNumber = payment.strPaymentInfo
	,strCurrency = SMC.strCurrency
FROM tblAPBillDetail APBD
INNER JOIN tblAPBill APB ON APBD.intBillId = APB.intBillId AND APB.ysnPosted = CAST(1 AS BIT)
INNER JOIN tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId
INNER JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId AND ysnDefaultContact = 1
INNER JOIN tblSMCurrency SMC ON APB.intCurrencyId = SMC.intCurrencyID
INNER JOIN tblICItem IE ON IE.intItemId = APBD.intItemId
LEFT JOIN (dbo.tblICItemUOM costUOM INNER JOIN dbo.tblICUnitMeasure UM ON costUOM.intUnitMeasureId = UM.intUnitMeasureId) ON APBD.intCostUOMId = costUOM.intItemUOMId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = APB.intPayToAddressId
LEFT JOIN tblEMEntityLocation ELS ON APB.intShipFromEntityId = EL.intEntityId AND APB.intShipFromId = ELS.intEntityLocationId
LEFT JOIN tblICCommodity C ON C.intCommodityId = IE.intCommodityId
INNER JOIN (
    SELECT
         APBDT.intBillDetailId
        ,APBDT.intTaxGroupId
		,APBDT.strCalculationMethod
        ,STC.strTaxCode
		,STC.strTaxAgency
		,STC.strDescription
		,STC.strTaxPoint
		,GL.strAccountId
        ,SMTC.strTaxClass
		,APBDT.dblRate
    FROM tblAPBillDetailTax APBDT
    LEFT JOIN tblSMTaxCode STC ON APBDT.intTaxCodeId = STC.intTaxCodeId
	LEFT JOIN tblGLAccount GL ON STC.intPurchaseTaxAccountId = GL.intAccountId
    LEFT JOIN tblSMTaxClass SMTC ON APBDT.intTaxClassId = SMTC.intTaxClassId
	WHERE APBDT.ysnCheckOffTax = 1
) RT ON APBD.intBillDetailId = RT.intBillDetailId
LEFT OUTER JOIN tblSMTaxGroup SMTG ON ISNULL(APBD.intTaxGroupId, RT.intTaxGroupId) = SMTG.intTaxGroupId
OUTER APPLY (
	SELECT TOP 1	
			strEmail,
			strEmail2,
			strPhone,
			strPhone2 
	FROM tblEMEntity E1
	WHERE E1.intEntityId = EC.intEntityContactId 
) vendor
OUTER APPLY(  
	SELECT TOP 1   
		 B1.dtmDatePaid  
		,B1.dblAmountPaid
		,B1.strPaymentInfo  
    FROM tblAPPayment B1
	INNER JOIN tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId  
	LEFT JOIN tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId   
	WHERE B.intBillId = APB.intBillId
	ORDER BY dtmDatePaid DESC
) payment
OUTER APPLY (
	SELECT TOP 1 strAccountId
	FROM tblGLAccount
	WHERE intAccountId = APB.intAccountId
) apaccount
OUTER APPLY (
	SELECT TOP 1 strAccountId
	FROM tblGLAccount
	WHERE intAccountId = APBD.intAccountId
) account

GO