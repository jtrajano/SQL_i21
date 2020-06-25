CREATE VIEW [dbo].[vyuAPVoucherCheckOffDetailPerPayment] AS  
  
  
--VOUCHER W/ APPLIED PREPAID WITH CHECK OFF TAX PER PAYMENT  
SELECT    
   intBillId  
  ,strBillId  
  ,strVendorId  
  ,intEntityVendorId  
  ,strVendorName  
  ,strVendorAddress COLLATE Latin1_General_CI_AS  as strVendorAddress
  ,strVendorCity  
  ,strVendorState  
  ,strVendorZipCode  
  ,strVendorCounty
  ,strEmail2  
  ,strPhone  
  ,strCounty  
  ,strTaxCode  
  ,strTaxCodeDesc  
  ,strCalculationMethod  
  ,dblTaxRate  
  ,SUM(dblTaxAmount) AS dblTaxAmount  
  ,SUM(dblQtyReceived) AS dblQtyReceived  
  --,strCommodityCode  
  --strItemNo  
  --intTicketId  
  --strTicketNumber  
  ,strDeliverySheetNumber  
  ,strVendorOrderNumber  
  ,strPaymentInfo  
  ,dtmBillDate  
  ,dtmDatePaid  
  ,dblAmountPaid AS dblPaymentAmount  
  ,SUM(dblTax)  AS dblTax  
  ,dblCommodityTotal  
  ,ysnPaid  
    
    FROM (  
     SELECT DISTINCT     
         APB.intBillId    
        ,APB.strBillId  
        ,V.strVendorId  
        ,APB.intEntityVendorId  
        ,strVendorName =  E.strName  
        ,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL))  
        ,ISNULL(EL.strCity, 'N/A') AS strVendorCity  
        ,ISNULL(EL.strState, 'N/A') AS strVendorState  
        ,ISNULL(EL.strZipCode,'N/A') AS strVendorZipCode  
        ,ISNULL(EL.strCounty,'N/A') AS strVendorCounty  
        ,ISNULL(vendor.strEmail, vendor.strEmail2) AS strEmail2  
        ,ISNULL(vendor.strPhone, vendor.strPhone2) AS strPhone  
        ,TC.strTaxCode  
        ,TC.strDescription AS strTaxCodeDesc  
        ,TC.strCounty  
        ,APBDT.strCalculationMethod  
        ,APBDT.dblRate AS dblTaxRate  
        ,APBDT.dblTax AS dblTaxAmount  
        ,APBD.dblQtyReceived  
        ,C.strCommodityCode   
        ,strItem = IE.strItemNo   
        ,SC.intTicketId  
        ,ISNULL(SC.strTicketNumber,ISNULL(SS.strDeliverySheetNumber, CS.strStorageTicketNumber)) AS strTicketNumber  
        ,(CASE WHEN APBD.intCustomerStorageId > 0 THEN CS.strStorageTicketNumber ELSE SS.strDeliverySheetNumber END) AS strDeliverySheetNumber  
        ,APB.strVendorOrderNumber  
        ,APB.dtmBillDate  
        ,APBD.dblTotal   
        ,APBD.dblTax  
        ,0 AS dblCommodityTotal  
        ,APD.dblAmountApplied AS dblAmountPaid  
        ,Payment.strPaymentInfo  
        ,APD.ysnApplied AS ysnPaid  
        ,APB.dtmDate AS dtmDatePaid  
     FROM  dbo.tblAPBill APB  
        INNER JOIN dbo.tblAPBillDetail APBD  ON APBD.intBillId = APB.intBillId  
        INNER JOIN dbo.tblAPBillDetailTax APBDT ON APBD.intBillDetailId = APBDT.intBillDetailId  
        INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId  
        INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId  
        INNER JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId AND ysnDefaultContact = 1  
        LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = APB.intPayToAddressId  
        INNER JOIN dbo.tblICItem IE ON IE.intItemId = APBD.intItemId  
        LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APBD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId  
        LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId   
        LEFT JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId  
        LEFT JOIN dbo.tblICCommodity C ON C.intCommodityId = IE.intCommodityId  
        INNER JOIN tblSMTaxCode TC ON APBDT.intTaxCodeId = TC.intTaxCodeId  
        INNER JOIN dbo.tblSMTaxClass TCS ON TC.intTaxClassId = TCS.intTaxClassId  
        LEFT JOIN dbo.tblSCDeliverySheet SS ON SS.intDeliverySheetId = IRE.intSourceId  
        LEFT JOIN dbo.tblGRCustomerStorage CS ON CS.intCustomerStorageId = APBD.intCustomerStorageId  
        INNER JOIN dbo.tblAPAppliedPrepaidAndDebit APD ON APD.intBillId = APB.intBillId  
        INNER JOIN dbo.tblAPBill APB2 ON APD.intTransactionId = APB2.intBillId                                
     OUTER APPLY(  
        SELECT TOP 1   
            B1.dtmDatePaid,  
            B1.dblAmountPaid,  
            ISNULL(B1.ysnPosted,0) as ysnPosted,  
            B1.strPaymentInfo  
            FROM dbo.tblAPPayment B1  
        INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId  
        LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId   
        WHERE B.intBillId = APB.intBillId   
          -- AND intPaymentMethodId = 7 --WILL SHOW TRANSACTION THAT WAS PAID USING CHECK ONLY  
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
     WHERE    
        APB.ysnPosted = 1   
         AND APBDT.ysnCheckOffTax = 1 --SHOW ONLY ALL THE CHECK OFF TAX REGARDLESS OF SOURCE TRANSACTION  
          AND APBD.dblTax < 0  
) mainQuery  
GROUP BY   
   intBillId  
  ,strBillId  
  ,strVendorId  
  ,intEntityVendorId  
  ,strVendorName  
  ,strVendorAddress  
  ,strVendorCity  
  ,strVendorState  
  ,strVendorZipCode
  ,strVendorCounty  
  ,strEmail2  
  ,strPhone  
  ,strCounty  
  ,strTaxCode  
  ,strTaxCodeDesc  
  ,strCalculationMethod  
  ,dblTaxRate  
  --,dblTaxAmount  
  --,dblQtyReceived  
  --,strCommodityCode  
  --strItemNo  
  --intTicketId  
  --strTicketNumber  
  ,strDeliverySheetNumber  
  ,strVendorOrderNumber  
  ,strPaymentInfo  
  ,dtmBillDate  
  ,dtmDatePaid  
  ,dblAmountPaid   
  --,dblTax  
  ,dblCommodityTotal  
  ,ysnPaid  
  
UNION ALL  
  
--VOUCHER WITH CHECK OFF TAX   PER PAYMENT  
SELECT    
   intBillId  
  ,strBillId  
  ,strVendorId  
  ,intEntityVendorId  
  ,strVendorName  
  ,strVendorAddress  
  ,strVendorCity  
  ,strVendorState  
  ,strVendorZipCode  
  ,strVendorCounty
  ,strEmail2  
  ,strPhone  
  ,strCounty  
  ,strTaxCode  
  ,strTaxCodeDesc  
  ,strCalculationMethod  
  ,dblTaxRate  
  ,SUM(dblTaxAmount) AS dblTaxAmount  
  ,SUM(dblQtyReceived) AS dblQtyReceived  
  --,strCommodityCode  
  --strItemNo  
  --intTicketId  
  --strTicketNumber  
  ,strDeliverySheetNumber  
  ,strVendorOrderNumber  
  ,strPaymentInfo  
  ,dtmBillDate  
  ,dtmDatePaid  
  ,dblAmountPaid AS dblPaymentAmount  
  ,SUM(dblTax)  AS dblTax  
  ,dblCommodityTotal  
  ,ysnPaid  
    
    FROM (  
     SELECT DISTINCT     
         APB.intBillId    
        ,APB.strBillId  
        ,V.strVendorId  
        ,APB.intEntityVendorId  
        ,strVendorName =  E.strName  
        ,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL))  
        ,ISNULL(EL.strCity, 'N/A') AS strVendorCity  
        ,ISNULL(EL.strState, 'N/A') AS strVendorState  
        ,ISNULL(EL.strZipCode,'N/A') AS strVendorZipCode  
        ,ISNULL(EL.strCounty,'N/A') AS strVendorCounty
        ,ISNULL(vendor.strEmail, vendor.strEmail2) AS strEmail2  
        ,ISNULL(vendor.strPhone, vendor.strPhone2) AS strPhone  
        ,TC.strTaxCode  
        ,TC.strDescription AS strTaxCodeDesc  
        ,TC.strCounty  
        ,APBDT.strCalculationMethod  
        ,APBDT.dblRate AS dblTaxRate  
        ,APBDT.dblTax AS dblTaxAmount  
        ,APBD.dblQtyReceived  
        ,C.strCommodityCode   
        ,strItem = IE.strItemNo   
        ,SC.intTicketId  
        ,ISNULL(SC.strTicketNumber,ISNULL(SS.strDeliverySheetNumber, CS.strStorageTicketNumber)) AS strTicketNumber  
        ,(CASE WHEN APBD.intCustomerStorageId > 0 THEN CS.strStorageTicketNumber ELSE SS.strDeliverySheetNumber END) AS strDeliverySheetNumber  
        ,APB.strVendorOrderNumber  
        ,APB.dtmBillDate  
        ,APBD.dblTotal   
        ,APBD.dblTax  
        ,0 AS dblCommodityTotal  
        ,Payment.dblAmountPaid  
        ,Payment.strPaymentInfo  
        ,Payment.ysnPosted AS ysnPaid  
        ,Payment.dtmDatePaid  
     FROM  dbo.tblAPBill APB  
        INNER JOIN dbo.tblAPBillDetail APBD  ON APBD.intBillId = APB.intBillId  
        INNER JOIN dbo.tblAPBillDetailTax APBDT ON APBD.intBillDetailId = APBDT.intBillDetailId  
        INNER JOIN dbo.tblAPVendor V ON APB.intEntityVendorId = V.intEntityId  
        INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId  
        INNER JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId AND ysnDefaultContact = 1  
        LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = APB.intPayToAddressId  
        INNER JOIN dbo.tblICItem IE ON IE.intItemId = APBD.intItemId  
        LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APBD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId  
        LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId   
        LEFT JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId  
        LEFT JOIN dbo.tblICCommodity C ON C.intCommodityId = IE.intCommodityId  
        INNER JOIN tblSMTaxCode TC ON APBDT.intTaxCodeId = TC.intTaxCodeId  
        INNER JOIN dbo.tblSMTaxClass TCS ON TC.intTaxClassId = TCS.intTaxClassId  
        LEFT JOIN dbo.tblSCDeliverySheet SS ON SS.intDeliverySheetId = IRE.intSourceId  
        LEFT JOIN dbo.tblGRCustomerStorage CS ON CS.intCustomerStorageId = APBD.intCustomerStorageId  
     CROSS APPLY(  
        SELECT TOP 1   
            B1.dtmDatePaid,  
            B1.dblAmountPaid,  
            B1.ysnPosted,  
            B1.strPaymentInfo  
            FROM dbo.tblAPPayment B1  
        INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId  
        LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId   
        WHERE B.intBillId = APB.intBillId   
          -- AND intPaymentMethodId = 7 --WILL SHOW TRANSACTION THAT WAS PAID USING CHECK ONLY  
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
     WHERE    
        APB.ysnPosted = 1   
         AND Payment.ysnPosted = 1   
         AND APBDT.ysnCheckOffTax = 1 --SHOW ONLY ALL THE CHECK OFF TAX REGARDLESS OF SOURCE TRANSACTION  
) mainQuery  
GROUP BY   
   intBillId  
  ,strBillId  
  ,strVendorId  
  ,intEntityVendorId  
  ,strVendorName  
  ,strVendorAddress  
  ,strVendorCity  
  ,strVendorState  
  ,strVendorZipCode  
  ,strVendorCounty
  ,strEmail2  
  ,strPhone  
  ,strCounty  
  ,strTaxCode  
  ,strTaxCodeDesc  
  ,strCalculationMethod  
  ,dblTaxRate  
  --,dblTaxAmount  
  --,dblQtyReceived  
  --,strCommodityCode  
  --strItemNo  
  --intTicketId  
  --strTicketNumber  
  ,strDeliverySheetNumber  
  ,strVendorOrderNumber  
  ,strPaymentInfo  
  ,dtmBillDate  
  ,dtmDatePaid  
  ,dblAmountPaid   
  --,dblTax  
  ,dblCommodityTotal  
  ,ysnPaid  
  
   --SELECT      
 --       D.intBillId  
 --      ,D.strBillId  
 --      ,V.strVendorId  
 --      ,B1.intEntityVendorId  
 --      ,strVendorName =  E.strName  
 --      ,strVendorAddress = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL))  
 --     ,ISNULL(EL.strCity, 'N/A') AS strVendorCity  
 --     ,ISNULL(EL.strState, 'N/A') AS strVendorState  
 --     ,ISNULL(EL.strZipCode,'N/A') AS strVendorZipCode  
 --     ,ISNULL(vendor.strEmail, vendor.strEmail2) AS strEmail2  
 --     ,ISNULL(vendor.strPhone, vendor.strPhone2) AS strPhone  
 --      ,B1.dtmDatePaid  
 --      ,B1.dblAmountPaid  
 --      ,B1.ysnPosted  
 --      FROM dbo.tblAPPayment B1  
 --  INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId  
 --  LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId   
 --  INNER JOIN tblAPBill D ON D.intBillId = B.intBillId  
 --  INNER JOIN dbo.tblAPVendor V ON D.intEntityVendorId = V.intEntityId  
 --  INNER JOIN dbo.tblEMEntity E ON E.intEntityId = V.intEntityId  
 --  INNER JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId AND ysnDefaultContact = 1  
 --  LEFT JOIN dbo.tblEMEntityLocation EL ON (EL.intEntityId = E.intEntityId) AND (EL.intEntityLocationId = D.intShipFromId)  AND ysnDefaultLocation  =1   
 --  OUTER APPLY (  
 --   SELECT TOP 1   
 --     strEmail,  
 --     strEmail2,  
 --     strPhone,  
 --     strPhone2   
 --   FROM tblEMEntity E1  
 --   WHERE E1.intEntityId = EC.intEntityContactId   
 --  ) vendor  
 --  WHERE B1.intPaymentMethodId = 7 --WILL SHOW TRANSACTION THAT WAS PAID USING CHECK ONLY  
 --  ORDER BY dtmDatePaid DESC  