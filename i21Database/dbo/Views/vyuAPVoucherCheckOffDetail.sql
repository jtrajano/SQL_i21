﻿CREATE VIEW [dbo].[vyuAPVoucherCheckOffDetail] AS

--VOUCHER WITH CHECK OFF TAX 
SELECT	DISTINCT			
			 APB.intBillId	 
			,APB.strBillId
			,V.strVendorId
			,APB.intEntityVendorId
			,strVendorName =  E.strName
			,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL)) COLLATE Latin1_General_CI_AS
			,ISNULL(EL.strCity, 'N/A') AS strVendorCity
			,ISNULL(EL.strState, 'N/A') AS strVendorState
			,ISNULL(EL.strZipCode,'N/A') AS strVendorZipCode
			,ISNULL(EL.strCounty,'N/A') AS strVendorCounty
			,ISNULL(vendor.strEmail, vendor.strEmail2) AS strEmail2
			,ISNULL(vendor.strPhone, vendor.strPhone2) AS strPhone
			,strShipFrom = SF.strLocationName COLLATE Latin1_General_CI_AS
			,SF.strAddress
			,SF.strCity
			,SF.strState
			,SF.strZipCode
			,TC.strTaxCode
			,TC.strDescription AS strTaxCodeDesc
			,TC.strCounty
			,APBDT.strCalculationMethod
			,ISNULL(APBDT.dblRate,0) AS dblTaxRate
			,APBDT.dblTax AS dblTaxAmount
			,APBD.dblQtyReceived
			,C.strCommodityCode 
			,strItem = IE.strItemNo 
			,SC.intTicketId
			,ISNULL(SC.strTicketNumber,ISNULL(SS.strDeliverySheetNumber, CS.strStorageTicketNumber)) AS strTicketNumber
			,(CASE WHEN APBD.intCustomerStorageId > 0 THEN CS.strStorageTicketNumber ELSE SS.strDeliverySheetNumber END) AS strDeliverySheetNumber
			,APB.strVendorOrderNumber
			,APB.dtmBillDate
			,CASE WHEN APB.ysnPaid = 1 THEN Payment.dtmDatePaid ELSE NULL END AS dtmDatePaid
			,APBD.dblTotal + APBD.dblTax as dblTotal
			,ISNULL(APBDT.dblTax,0) as dblTax
			,0 AS dblCommodityTotal
			,strCompanyName = (SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup)
			,strCompanyAddress = (SELECT TOP 1 
				   ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strZip),'') + ' ' + ISNULL(RTRIM(strCity), '') + ' ' + ISNULL(RTRIM(strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strPhone)+ CHAR(13) + char(10), '') FROM tblSMCompanySetup)
			,GL.strAccountId
			--,TAXDETAIL.*
FROM		dbo.tblAPBill APB
			INNER JOIN dbo.tblAPBillDetail APBD  ON APBD.intBillId = APB.intBillId
			LEFT JOIN dbo.tblAPBillDetailTax APBDT ON APBD.intBillDetailId = APBDT.intBillDetailId
			INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
			INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId
			INNER JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId AND ysnDefaultContact = 1
			LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = APB.intPayToAddressId
			INNER JOIN dbo.tblICItem IE ON IE.intItemId = APBD.intItemId
			LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APBD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId
			LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId 
			LEFT JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId
			LEFT JOIN dbo.tblSCDeliverySheet SS ON SS.intDeliverySheetId = IRE.intSourceId
			LEFT JOIN dbo.tblGRCustomerStorage CS ON CS.intCustomerStorageId = APBD.intCustomerStorageId
			LEFT JOIN dbo.tblICCommodity C ON C.intCommodityId = IE.intCommodityId
			LEFT JOIN tblSMTaxCode TC ON APBDT.intTaxCodeId = TC.intTaxCodeId
			LEFT JOIN dbo.tblSMTaxClass TCS ON TC.intTaxClassId = TCS.intTaxClassId
			LEFT JOIN vyuGLAccountDetail GL ON GL.intAccountId = APBD.intAccountId
			OUTER APPLY(
				SELECT TOP 1 dtmDatePaid
				FROM(
					SELECT 
						B1.dtmDatePaid
						-- B1.dblAmountPaid,
						-- B1.ysnPosted
					FROM dbo.tblAPPayment B1
					INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
					LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId 
					WHERE B.intBillId = APB.intBillId AND B1.ysnPosted = 1
					UNION ALL
					SELECT
						B.dtmDate
					FROM dbo.tblAPAppliedPrepaidAndDebit A
					INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
					WHERE B.intBillId = APB.intBillId AND A.ysnApplied = 1
				) paymentData
				  --AND intPaymentMethodId = 7 --WILL SHOW TRANSACTION THAT WAS PAID USING CHECK ONLY
				ORDER BY dtmDatePaid DESC
			)  Payment 
			OUTER APPLY (
				SELECT TOP 1	
						strEmail,
						strEmail2,
						strPhone,
						strPhone2 
				FROM tblEMEntity E1
				WHERE E1.intEntityId = EC.intEntityContactId 
			) vendor
			OUTER APPLY
			(
				SELECT TOP 1 
				 strLocationName
				,strAddress
				,strCity
				,strState
				,strZipCode FROM  [tblEMEntityLocation] B WHERE APB.intShipFromEntityId = B.intEntityId AND APB.intShipFromId = B.intEntityLocationId 
			) SF
WHERE  
	  APB.ysnPosted = 1 
		--   AND Payment.ysnPosted = 1 
		  AND (APBDT.ysnCheckOffTax = 1 --SHOW ONLY ALL THE CHECK OFF TAX REGARDLESS OF SOURCE TRANSACTION
		  OR APBD.intCustomerStorageId > 0
		  OR APBD.intScaleTicketId > 0) 
		  
-- UNION ALL 

-- --VOUCHER W/ APPLIED PREPAID WITH CHECK OFF TAX 
-- SELECT	DISTINCT			
-- 			 APB.intBillId
-- 			,APB.strBillId
-- 			,V.strVendorId
-- 			,APB.intEntityVendorId
-- 			,strVendorName =  E.strName
-- 			,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL))
-- 			,ISNULL(EL.strCity, 'N/A') AS strVendorCity
-- 			,ISNULL(EL.strState, 'N/A') AS strVendorState
-- 			,ISNULL(EL.strZipCode,'N/A') AS strVendorZipCode
-- 			,ISNULL(EL.strCounty,'N/A') AS strVendorCounty
-- 			,ISNULL(vendor.strEmail, vendor.strEmail2) AS strEmail2
-- 			,ISNULL(vendor.strPhone, vendor.strPhone2) AS strPhone
-- 			,strShipFrom =  SF.strLocationName COLLATE Latin1_General_CI_AS
-- 			,SF.strAddress
-- 			,SF.strCity
-- 			,SF.strState
-- 			,SF.strZipCode
-- 			,TC.strTaxCode
-- 			,TC.strDescription AS strTaxCodeDesc
-- 			,TC.strCounty
-- 			,APBDT.strCalculationMethod
-- 			,ISNULL(APBDT.dblRate,0) AS dblTaxRate
-- 			,APBDT.dblTax AS dblTaxAmount
-- 			,APBD.dblQtyReceived
-- 			,C.strCommodityCode 
-- 			,strItem = IE.strItemNo 
-- 			,SC.intTicketId
-- 			,ISNULL(SC.strTicketNumber,ISNULL(SS.strDeliverySheetNumber, CS.strStorageTicketNumber)) AS strTicketNumber
-- 			,(CASE WHEN APBD.intCustomerStorageId > 0 THEN CS.strStorageTicketNumber ELSE SS.strDeliverySheetNumber END) AS strDeliverySheetNumber
-- 			,APB.strVendorOrderNumber
-- 			,APB.dtmBillDate
-- 			,Payment.dtmDatePaid
-- 			,APBD.dblTotal + APBD.dblTax as dblTotal
-- 			,ISNULL(APBDT.dblTax,0) as dblTax
-- 			,0 AS dblCommodityTotal
-- 			,strCompanyName = (SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup)
-- 			,strCompanyAddress = (SELECT TOP 1 
-- 				   ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')
-- 				 + ISNULL(RTRIM(strZip),'') + ' ' + ISNULL(RTRIM(strCity), '') + ' ' + ISNULL(RTRIM(strState), '') + CHAR(13) + char(10)
-- 				 + ISNULL('' + RTRIM(strCountry) + CHAR(13) + char(10), '')
-- 				 + ISNULL(RTRIM(strPhone)+ CHAR(13) + char(10), '') FROM tblSMCompanySetup)
-- 			,GL.strAccountId
-- 			--,TAXDETAIL.*
-- FROM		dbo.tblAPBill APB
-- 			INNER JOIN dbo.tblAPBillDetail APBD  ON APBD.intBillId = APB.intBillId
-- 			LEFT JOIN dbo.tblAPBillDetailTax APBDT ON APBD.intBillDetailId = APBDT.intBillDetailId
-- 			INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId
-- 			INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId
-- 			INNER JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId AND ysnDefaultContact = 1
-- 			LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = APB.intPayToAddressId
-- 			INNER JOIN dbo.tblICItem IE ON IE.intItemId = APBD.intItemId
-- 			LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APBD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId
-- 			LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId 
-- 			LEFT JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId
-- 			LEFT JOIN dbo.tblSCDeliverySheet SS ON SS.intDeliverySheetId = IRE.intSourceId
-- 			LEFT JOIN dbo.tblGRCustomerStorage CS ON CS.intCustomerStorageId = APBD.intCustomerStorageId
-- 			LEFT JOIN dbo.tblICCommodity C ON C.intCommodityId = IE.intCommodityId
-- 			LEFT JOIN tblSMTaxCode TC ON APBDT.intTaxCodeId = TC.intTaxCodeId
-- 			LEFT JOIN dbo.tblSMTaxClass TCS ON TC.intTaxClassId = TCS.intTaxClassId
-- 			INNER JOIN dbo.tblAPAppliedPrepaidAndDebit APD ON APD.intBillId = APB.intBillId
-- 			INNER JOIN dbo.tblAPBill APB2 ON APD.intTransactionId = APB2.intBillId
-- 			LEFT JOIN vyuGLAccountDetail GL ON GL.intAccountId = APBD.intAccountId
-- 			OUTER APPLY (
-- 				SELECT TOP 1	
-- 						strEmail,
-- 						strEmail2,
-- 						strPhone,
-- 						strPhone2 
-- 				FROM tblEMEntity E1
-- 				WHERE E1.intEntityId = EC.intEntityContactId 
-- 			) vendor
-- 			OUTER APPLY(
-- 			SELECT TOP 1 
-- 						 B1.dtmDatePaid,
-- 						 B1.dblAmountPaid,
-- 						 B1.ysnPosted
-- 						 FROM dbo.tblAPPayment B1
-- 			INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
-- 			LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId 
-- 			WHERE B.intBillId = APB.intBillId 
-- 				  --AND intPaymentMethodId = 7 --WILL SHOW TRANSACTION THAT WAS PAID USING CHECK ONLY
				
-- 			ORDER BY dtmDatePaid DESC
-- 			)  Payment 
-- 			OUTER APPLY
-- 			(
-- 				SELECT TOP 1 
-- 				 strLocationName
-- 				,strAddress
-- 				,strCity
-- 				,strState
-- 				,strZipCode FROM  [tblEMEntityLocation] B WHERE APB.intShipFromEntityId = B.intEntityId AND APB.intShipFromId = B.intEntityLocationId 
-- 			) SF
-- WHERE  
-- 	  APB.ysnPosted = 1 
-- 	 AND APBDT.ysnCheckOffTax = 1 --SHOW ONLY ALL THE CHECK OFF TAX REGARDLESS OF SOURCE TRANSACTION
-- 	 AND ( APBD.dblTax < 0 
-- 		   OR APBD.intCustomerStorageId > 0
-- 		  OR APBD.intScaleTicketId > 0) 
-- 	 and Payment.dtmDatePaid IS NOT NULL
GO