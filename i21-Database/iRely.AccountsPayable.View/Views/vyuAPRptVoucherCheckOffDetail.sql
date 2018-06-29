
CREATE VIEW [dbo].[vyuAPRptVoucherCheckOffDetail]
AS

SELECT	DISTINCT			
			 APB.intBillId	 
			,APB.strBillId
			,V.strVendorId
			,strVendorName =  E.strName
			,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL))
			,ISNULL(TC.strCity, 'N/A') AS strVendorCity
			,ISNULL(TC.strState, 'N/A') AS strVendorState
			,ISNULL(TC.strZipCode,'N/A') AS strVendorZipCode
			,strEmail2
			,E.strPhone
			,TC.strTaxCode
			,TC.strDescription AS strTaxCodeDesc
			,APBDT.strCalculationMethod
			,APBDT.dblRate AS dblTaxRate
			,APBDT.dblTax AS dblTaxAmount
			,APBD.dblQtyReceived
			,C.strCommodityCode 
			,strItem = IE.strItemNo 
			,intTicketId
			,SC.strTicketNumber
			,APB.strVendorOrderNumber
			,APB.dtmBillDate
			,APBD.dblTotal 
			,APBD.dblTax
			,0 AS dblCommodityTotal
			,strCompanyName = (SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup)
			,strCompanyAddress = (SELECT TOP 1 
				   ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strZip),'') + ' ' + ISNULL(RTRIM(strCity), '') + ' ' + ISNULL(RTRIM(strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strPhone)+ CHAR(13) + char(10), '') FROM tblSMCompanySetup)
			--,TAXDETAIL.*
FROM		dbo.tblAPBill APB
			INNER JOIN dbo.tblAPBillDetail APBD  ON APBD.intBillId = APB.intBillId
			INNER JOIN dbo.tblAPBillDetailTax APBDT ON APBD.intBillDetailId = APBDT.intBillDetailId
			INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
			INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId
			LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND ysnDefaultLocation  =1 
			INNER JOIN dbo.tblICItem IE ON IE.intItemId = APBD.intItemId
			LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APBD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId
			LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId 
			LEFT JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId
			LEFT JOIN dbo.tblICCommodity C ON C.intCommodityId = IE.intCommodityId
			INNER JOIN tblSMTaxCode TC ON APBDT.intTaxCodeId = TC.intTaxCodeId
			INNER JOIN dbo.tblSMTaxClass TCS ON TC.intTaxClassId = TCS.intTaxClassId
OUTER APPLY(
			SELECT TOP 1 
						 B1.dtmDatePaid,
						 B1.dblAmountPaid,
						 B1.ysnPosted
						 FROM dbo.tblAPPayment B1
			INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
			LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId 
			WHERE B.intBillId = APB.intBillId 
				  AND intPaymentMethodId = 7 --WILL SHOW TRANSACTION THAT WAS PAID USING CHECK ONLY
			ORDER BY dtmDatePaid DESC
			)  Payment 
WHERE  
	  APB.ysnPosted = 1 
		  AND Payment.ysnPosted = 1 
		  AND APBDT.ysnCheckOffTax = 1 --SHOW ONLY ALL THE CHECK OFF TAX REGARDLESS OF SOURCE TRANSACTION
