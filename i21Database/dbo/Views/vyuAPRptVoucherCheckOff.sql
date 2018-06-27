CREATE VIEW [dbo].[vyuAPRptVoucherCheckOff]

AS
SELECT	DISTINCT	 
			 APB.intBillId
			,VendorId = ISNULL(V.strVendorId, E.strEntityNo)
			,VendorName =  ISNULL(V.strVendorId,'') + ' ' + E.strName
			,strDescription = C.strCommodityCode 
			,strItem = IE.strItemNo 
			,intTicketId
			,strTicketNumber = SC.strTicketNumber
			,APB.strVendorOrderNumber
			--,StateOfOrigin = ISNULL((SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL,NULL,NULL, APB.strShipFromCity, APB.strShipFromState, NULL, NULL, NULL)),'N/A')
			,StateOfOrigin = ISNULL((SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL,NULL,NULL, EL.strCity, EL.strState, NULL, NULL, NULL)),'N/A')
			,Location = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, NULL, APB.strShipToCity, APB.strShipToState,NULL, NULL, NULL))
			,BillDate = APB.dtmBillDate
			,PostDate = APB.dtmBillDate
			,PaymentDate = Payment.dtmDatePaid
			,ExemptUnits = APBD.dblQtyReceived 
			,APBD.dblTotal --AP-4155
			,APBD.dblTax
			,0 AS dblCommodityTotal
			,strCompanyName = (SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup)
			,strCompanyAddress = (SELECT TOP 1 
				   ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strZip),'') + ' ' + ISNULL(RTRIM(strCity), '') + ' ' + ISNULL(RTRIM(strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strPhone)+ CHAR(13) + char(10), '') FROM tblSMCompanySetup)
	FROM	dbo.tblAPBill APB
			INNER JOIN dbo.tblAPBillDetail APBD  ON APBD.intBillId = APB.intBillId
			INNER JOIN dbo.tblAPBillDetailTax APBDT ON APBD.intBillDetailId = APBDT.intBillDetailId
			INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
			INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId
			INNER JOIN dbo.tblICItem IE ON IE.intItemId = APBD.intItemId
			LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APBD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId
			LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId 
			LEFT JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId
			LEFT JOIN dbo.tblICCommodity C ON C.intCommodityId = IE.intCommodityId
			INNER JOIN dbo.tblEMEntityLocation EL ON  EL.intEntityLocationId = APB.intShipFromId --AND EL.ysnDefaultLocation = 1
			 OUTER APPLY(
			SELECT TOP 1 
						 B1.dtmDatePaid,
						 B1.dblAmountPaid,
						 ysnPaid
						 FROM dbo.tblAPPayment B1
			INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
			LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId 
			WHERE B.intBillId = APB.intBillId 
				  AND intPaymentMethodId = 7 --WILL SHOW TRANSACTION THAT WAS PAID USING CHECK ONLY
			ORDER BY dtmDatePaid DESC
			)  Payment     
	WHERE APB.ysnPosted = 1 
		  AND Payment.ysnPaid = 1 
		  AND APBDT.ysnCheckOffTax = 1 --SHOW ONLY ALL THE CHECK OFF TAX REGARDLESS OF SOURCE TRANSACTION
GO