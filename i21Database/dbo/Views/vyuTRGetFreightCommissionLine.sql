CREATE VIEW vyuTRGetFreightCommissionLine      

AS

SELECT lr.strOrigin,      
    ldh.strDestination,      
    strDeliveryType = CASE       
        WHEN ISNULL(lr.strOrigin, ISNULL(OtherItem.strOrigin, '')) = 'Terminal' AND ldh.strDestination = 'Customer' THEN 'Terminal to Customer'       
        WHEN ISNULL(lr.strOrigin, ISNULL(OtherItem.strOrigin, '')) = 'Location' AND ldh.strDestination = 'Customer' THEN 'Location to Customer'   
        WHEN ISNULL(lr.strOrigin, ISNULL(OtherItem.strOrigin, '')) = 'Terminal' AND ldh.strDestination = 'Location' THEN 'Terminal to Location'   
        WHEN ISNULL(lr.strOrigin, ISNULL(ldd.strBillOfLading, '')) != '' AND ldh.strDestination = 'Customer' THEN 'Terminal to Customer'
        WHEN ISNULL(lr.strOrigin, ISNULL(ldd.strBillOfLading, '')) = '' AND ldh.strDestination = 'Customer' AND ldd.intLoadDistributionDetailId IS NOT NULL THEN 'Other Charge'       
        ELSE ''      
        END,      
    intDriverId = lh.intDriverId,      
    strDriverName = E.strName,      
    dtmLoadDateTime = lh.dtmLoadDateTime,      
    strMovement = CASE WHEN ISNULL(ldd.strBillOfLading, '') != '' THEN ldd.strBillOfLading ELSE ai.strInvoiceNumber END,      
    strVendor = CASE      
        WHEN lr.strOrigin = 'Terminal' THEN ISNULL(v.strVendorId,'') + '  ' + ISNULL(elr.strName,'') + CHAR(13) + char(10) + ISNULL(eel.strLocationName,'') + '  ' + ISNULL(tcn.strTerminalControlNumber,'')  
        WHEN lr.strOrigin = 'Location' THEN cl.strLocationName      
        END,      
    strSupplyPoint = CASE      
        WHEN lr.strOrigin = 'Terminal' THEN CHAR(13) + char(10) + eel.strLocationName + CHAR(13) + char(10) + tcn.strTerminalControlNumber      
        WHEN lr.strOrigin = 'Location' THEN NULL      
        END,      
    strCustomerNumber = CASE       
        WHEN ldh.strDestination = 'Customer' THEN ac.strCustomerNumber + ' ' + ace.strName      
        WHEN ldh.strDestination = 'Location' THEN NULL      
        END,      
    strCustomerName = CASE       
        WHEN ldh.strDestination = 'Customer' THEN ac.strCustomerNumber + ' ' + ace.strName      
        WHEN ldh.strDestination = 'Location' THEN accl.strLocationName      
        END,      
    intItemId = ldd.intItemId,      
    strItemNo = ii.strItemNo + ' - ' + ii.strDescription,      
    intItemCategoryId = ii.intCategoryId,      
    strItemCategory = ic.strCategoryCode,      
    strItemDescription = ii.strDescription,      
    dblUnits = ldd.dblUnits,      
    dblPrice = ldd.dblPrice,      
    intInvoiceId = ai.intInvoiceId,    
    strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, CompanySetup.strAddress, CompanySetup.strCity, CompanySetup.strState, CompanySetup.strZip, CompanySetup.strCountry, NULL, 0) COLLATE Latin1_General_CI_AS        
    , strCompanyName = CompanySetup.strCompanyName        
    , lh.intLoadHeaderId      
    , ldh.intLoadDistributionHeaderId      
    , ldd.intLoadDistributionDetailId    
    , ldd.strReceiptLink      
    , dblFreightRate = ldd.dblFreightRate    
    , dblFreight = ldd.dblFreightUnit    
    , dblSurcharge = ldd.dblDistSurcharge  
    , lh.intShipViaId  
FROM tblTRLoadDistributionDetail ldd      
    LEFT JOIN tblTRLoadDistributionHeader ldh on ldd.intLoadDistributionHeaderId = ldh.intLoadDistributionHeaderId      
    LEFT JOIN tblSMCompanyLocation accl ON accl.intCompanyLocationId = ldh.intCompanyLocationId      
    LEFT JOIN tblARInvoice ai ON ai.intInvoiceId = ldh.intInvoiceId      
    LEFT JOIN tblTRLoadReceipt lr ON lr.strReceiptLine = ldd.strReceiptLink AND lr.intLoadHeaderId = ldh.intLoadHeaderId AND lr.intItemId = ldd.intItemId      
    LEFT JOIN tblEMEntity elr ON elr.intEntityId = lr.intTerminalId      
    LEFT JOIN tblAPVendor v ON v.intEntityId = lr.intTerminalId      
    LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = lr.intCompanyLocationId      
       
    LEFT JOIN tblTRSupplyPoint sp ON sp.intSupplyPointId = lr.intSupplyPointId      
    LEFT JOIN tblTFTerminalControlNumber tcn ON tcn.intTerminalControlNumberId = sp.intTerminalControlNumberId      
    LEFT JOIN tblEMEntityLocation eel ON eel.intEntityLocationId = sp.intEntityLocationId      
    LEFT JOIN tblTRLoadHeader lh ON lh.intLoadHeaderId = ldh.intLoadHeaderId      
    LEFT JOIN tblEMEntity E ON E.intEntityId = lh.intDriverId      
    LEFT JOIN tblARCustomer ac ON ac.intEntityId = ldh.intEntityCustomerId      
    LEFT JOIN tblEMEntity ace ON ace.intEntityId = ac.intEntityId      
    LEFT JOIN tblICItem ii ON ldd.intItemId = ii.intItemId      
    LEFT JOIN tblICCategory ic ON ic.intCategoryId = ii.intCategoryId      
    CROSS APPLY (SELECT TOP 1 * FROM tblSMCompanySetup) CompanySetup
    --For Other Items 
    CROSS APPLY (
    SELECT TOP 1 strOrigin FROM tblTRLoadReceipt LR1 
        LEFT JOIN tblTRLoadDistributionDetail LDD2 ON LDD2.strReceiptLink = LR1.strReceiptLine
        LEFT JOIN tblTRLoadDistributionHeader LDH2 ON LDH2.intLoadHeaderId = LR1.intLoadHeaderId AND LDH2.intLoadDistributionHeaderId = LDD2.intLoadDistributionHeaderId
    WHERE LDH2.intLoadDistributionHeaderId = ldh.intLoadDistributionHeaderId
    ) OtherItem
      
      
      
     
WHERE       
lh.ysnPosted = 1 
    AND lh.intDriverId IS NOT NULL         
    AND (ISNULL(ldd.dblFreightRate, 0) != 0       
        OR ISNULL(ldd.dblDistSurcharge, 0) != 0       
        OR ISNULL(ldd.dblComboFreightRate, 0) != 0       
        OR (RTRIM(LTRIM(ISNULL(ldd.strReceiptLink, ''))) = '')   
    )    
  