CREATE VIEW [dbo].[vyuAPInboundTaxReportView]
AS

SELECT
	--HEADER
	 APBD.intBillDetailId
	,APB.intBillId
	,APB.strBillId
	,dbo.fnAPGetVoucherTransactionType2(APB.intTransactionType) strTransactionType

	--VENDOR
	,strVendorName =  E.strName
	,strVendorNumber = E.strEntityNo
	,strVendorFederalTaxId = E.strFederalTaxId 
	,strVendorStateTaxId = E.strStateTaxId
	,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL)) COLLATE Latin1_General_CI_AS
	,strVendorCity = ISNULL(EL.strCity, 'N/A')
	,strVendorState = ISNULL(EL.strState, 'N/A')
	,strVendorZipCode = ISNULL(EL.strZipCode,'N/A')
	,strVendorCounty = ISNULL(EL.strCounty,'N/A')
	,strVendorEmail = ISNULL(vendor.strEmail, vendor.strEmail2)
	,strVendorPhone = ISNULL(vendor.strPhone, vendor.strPhone2)

	--TAXES
	,RT.strTaxGroup
	,RT.strCalculationMethod
	,RT.strTaxCode
	,strTaxAgency = RT.strTaxAgency
	,strTaxCodeDescription = RT.strDescription
	,strTaxClassDescription =RT.strTaxClass
	,strTaxCodePointFrom = RT.strTaxPoint
	
	--DATES
	,dtmDatePaid = CASE WHEN APB.ysnPaid = 1 THEN payment.dtmDatePaid ELSE NULL END
	,APB.dtmDate
	,APB.dtmBillDate
	,APB.dtmDueDate

	--ITEMS
	,C.strCommodityCode 
	,strItem = IE.strItemNo
	,strItemCategory = IC.strCategoryCode

	--SHIP FROM
	,strShipFromName = ELS.strCheckPayeeName
	,strShipFromLocation = ELS.strLocationName COLLATE Latin1_General_CI_AS
	,strShipFromAddress = ELS.strAddress
	,strShipFromCity = ELS.strCity
	,strShipFromState = ELS.strState
	,strShipFromCountry = ELS.strCountry

	--SHIP TO
	,strShipToLocation = CL.strLocationName COLLATE Latin1_General_CI_AS
	,strShipToAddress = CL.strAddress
	,strShipToCity = CL.strCity
	,strShipToState = CL.strStateProvince
	,strShipToCountry = CL.strCountry

	--ACCOUNTS
	,strDebitAccount = account.strAccountId
	,strCreditAccount = apaccount.strAccountId
	,strTaxAccount = RT.strAccountId

	--TOTAL HEADERS
	,strCurrency = SMC.strCurrency
	,strUnitOfMeasure = UM.strUnitMeasure

	--TAX AMOUNTS
	,APBD.dblQtyReceived
	,APBD.dblCost
	,dblTax = RT.dblAdjustedTax
	
	--TOTAL AMOUNTS
	,dblTotalAmount = APB.dblTotal
	,dblPaymentAmount = APB.dblPayment
	,dblNontaxablePurchase = CASE WHEN ISNULL(APBD.dblTax, 0) = 0 THEN APBD.dblTotal ELSE 0 END
	,dblTaxablePurchase = CASE WHEN ISNULL(APBD.dblTax, 0) = 0 THEN 0 ELSE APBD.dblTotal END
	
	--GENERIC AMOUNTS
	,dblGross = APBD.dblTotal
	,dblTaxRate = RT.dblRate
	
	--FUNCTIONAL TOTAL AMOUNTS
	,dblFunctionalTax = ISNULL(APB.dblAverageExchangeRate, 1) * RT.dblAdjustedTax
    ,dblFunctionalGross = ISNULL(APB.dblAverageExchangeRate, 1) * APBD.dblTotal
	,dblFunctionalTotalAmount = ISNULL(APB.dblAverageExchangeRate, 1) * APB.dblTotal
	,dblFunctionalPaymentAmount = ISNULL(APB.dblAverageExchangeRate, 1) * APB.dblPayment
	,dblFunctionalNontaxablePurchase = ISNULL(APB.dblAverageExchangeRate, 1) * (CASE WHEN ISNULL(APBD.dblTax, 0) = 0 THEN APBD.dblTotal ELSE 0 END)
	,dblFunctionalTaxablePurchase = ISNULL(APB.dblAverageExchangeRate, 1) * (CASE WHEN ISNULL(APBD.dblTax, 0) = 0 THEN 0 ELSE APBD.dblTotal END)
	
	--PAYMENT HEADERS
	,ysnPaid = APB.ysnPaid
	,strCheckNumber = payment.strPaymentInfo
FROM tblAPBillDetail APBD
INNER JOIN tblAPBill APB ON APBD.intBillId = APB.intBillId AND APB.ysnPosted = CAST(1 AS BIT)
INNER JOIN tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId
INNER JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId AND ysnDefaultContact = 1
INNER JOIN tblSMCurrency SMC ON APB.intCurrencyId = SMC.intCurrencyID
INNER JOIN tblICItem IE ON IE.intItemId = APBD.intItemId
LEFT JOIN (
	tblICItemUOM IUOM 
	INNER JOIN tblICUnitMeasure UM ON IUOM.intUnitMeasureId = UM.intUnitMeasureId
) ON APBD.intCostUOMId = IUOM.intItemUOMId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = APB.intPayToAddressId
LEFT JOIN tblEMEntityLocation ELS ON APB.intShipFromEntityId = EL.intEntityId AND APB.intShipFromId = ELS.intEntityLocationId
LEFT JOIN tblSMCompanyLocation CL ON APB.intShipToId = CL.intCompanyLocationId
LEFT JOIN tblICCommodity C ON C.intCommodityId = IE.intCommodityId
LEFT JOIN tblICCategory IC ON IC.intCategoryId = IE.intCategoryId
INNER JOIN (
    SELECT
         APBDT.intBillDetailId
        ,APBDT.intTaxGroupId
		,TG.strTaxGroup
		,APBDT.strCalculationMethod
        ,STC.strTaxCode
		,STC.strTaxAgency
		,STC.strDescription
		,STC.strTaxPoint
		,GL.strAccountId
        ,SMTC.strTaxClass
		,APBDT.dblRate
		,APBDT.dblAdjustedTax
    FROM tblAPBillDetailTax APBDT
	LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = APBDT.intTaxGroupId
    LEFT JOIN tblSMTaxCode STC ON APBDT.intTaxCodeId = STC.intTaxCodeId
	LEFT JOIN tblGLAccount GL ON STC.intPurchaseTaxAccountId = GL.intAccountId
    LEFT JOIN tblSMTaxClass SMTC ON APBDT.intTaxClassId = SMTC.intTaxClassId
	WHERE APBDT.ysnCheckOffTax = 0
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
WHERE APB.intTransactionType NOT IN (15)

GO