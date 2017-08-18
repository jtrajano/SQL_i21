CREATE VIEW [dbo].vyuAPRptVoucherCheckOff

AS
SELECT	DISTINCT	 
			 VendorId = V.strVendorId
			,VendorName =  V.strVendorId + ' ' + E.strName
			,strDescription = C.strCommodityCode 
			,strItem = IE.strItemNo 
			,strTicketNumber = SC.strTicketNumber
			,APB.strVendorOrderNumber
			,StateOfOrigin = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL,NULL,NULL, APB.strShipFromCity, APB.strShipFromState, NULL, NULL, NULL))
			,Location = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, NULL, APB.strShipToCity, APB.strShipToState,NULL, NULL, NULL))
			,BillDate = APB.dtmBillDate
			,PaymentDate = Payment.dtmDatePaid
			,ExemptUnits = APBD.dblQtyReceived 
			,APBD.dblTotal
			,strCompanyName = (SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup)
			,strCompanyAddress = (SELECT TOP 1 ISNULL(RTRIM(strCompanyName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strZip),'') + ' ' + ISNULL(RTRIM(strCity), '') + ' ' + ISNULL(RTRIM(strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strPhone)+ CHAR(13) + char(10), '') FROM tblSMCompanySetup)
	FROM	dbo.tblAPBill APB
			INNER JOIN dbo.tblAPBillDetail APBD  ON APBD.intBillId = APB.intBillId
			INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
			INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId
			INNER JOIN dbo.tblICItem IE ON IE.intItemId = APBD.intItemId
			LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APBD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId
			LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId 
			INNER JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId
			LEFT JOIN dbo.tblICCommodity C ON C.intCommodityId = IE.intCommodityId
			 OUTER APPLY(
			SELECT TOP 1 
						 B1.dtmDatePaid
						 FROM dbo.tblAPPayment B1
			INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
			LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId 
			WHERE B.intBillId = APB.intBillId
			ORDER BY dtmDatePaid DESC
			)  Payment     
	WHERE APBD.dblTax = 0 AND APB.ysnPosted = 1
GO


