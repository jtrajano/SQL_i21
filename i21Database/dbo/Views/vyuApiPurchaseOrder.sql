CREATE VIEW [dbo].[vyuApiPurchaseOrder]
AS
SELECT
      po.intPurchaseId
    , po.strPurchaseOrderNumber
    , v.strName AS strVendor
    , po.strVendorOrderNumber
    , po.intEntityVendorId AS intVendorEntityId
    , po.dtmDate
    , po.dtmExpectedDate
    , os.strStatus
    , po.intTermsId
    , st.strTerm
    , po.intShipFromId intShipFromLocationId
    , el.strLocationName strShipFromLocation
    , dbo.fnAPFormatAddress(v.strName, cl.strLocationName, po.strShipFromAttention, 
        po.strShipFromAddress, po.strShipFromCity, po.strShipFromState, 
        po.strShipFromZipCode, po.strShipFromCountry, po.strShipFromPhone) strShipFromFullAddress
    , po.strShipFromCity
    , po.strShipFromCountry
    , po.strShipFromPhone
    , po.strShipFromState
    , po.strShipFromZipCode
    , po.strShipFromAddress
    , po.intShipToId intShipToLocationId
    , cl.strLocationName strShipToLocation
    , dbo.fnAPFormatAddress(v.strName, cl.strLocationName, po.strShipToAttention, 
        po.strShipToAddress, po.strShipToCity, po.strShipToState, 
        po.strShipToZipCode, po.strShipToCountry, po.strShipToPhone) strShipToFullAddress
    , po.strShipToCity
    , po.strShipToCountry
    , po.strShipToPhone
    , po.strShipToState
    , po.strShipToZipCode
    , eu.strName strOrderedByFullName
    , eu.strUserName strOrderedByUsername
    , po.intShipViaId
    , sv.strShipVia
    , po.intContactId
    , ec.strName strContact
    , po.intFreightTermId
    , ft.strFreightTerm
    , po.intCurrencyId
    , c.strCurrency
    , po.ysnRecurring
    , po.strReference
    , po.dblTax
    , po.dblShipping
    , po.dblSubtotal
    , po.dblTotalWeight
    , po.dblTotal
FROM tblPOPurchase po
JOIN vyuAPVendor v ON v.intEntityId = po.intEntityVendorId
LEFT JOIN tblSMTerm st ON st.intTermID = po.intTermsId
LEFT JOIN tblEMEntityLocation el ON el.intEntityLocationId = po.intShipFromId
LEFT JOIN tblPOOrderStatus os ON os.intOrderStatusId = po.intOrderStatusId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = po.intShipToId
LEFT JOIN vyuRestApiEntityUsers eu ON eu.intEntityId = po.intOrderById
LEFT JOIN tblSMShipVia sv ON sv.intEntityId = po.intShipViaId
LEFT JOIN vyuEMEntityContact ec ON ec.intEntityContactId = po.intContactId
    AND ec.intEntityId = po.intEntityVendorId
LEFT JOIN tblSMFreightTerms ft ON ft.intFreightTermId = po.intFreightTermId
LEFT JOIN tblSMCurrency c ON c.intCurrencyID = po.intCurrencyId