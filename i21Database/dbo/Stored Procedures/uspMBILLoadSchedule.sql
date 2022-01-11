CREATE Procedure [dbo].[uspMBILLoadSchedule]                 
 @intDriverId as int                 
as                 
begin             
  
      
Delete from tblMBILLoadSchedule Where intLoadId not in (Select intLoadId from tblMBILLongTruckHeader where intDriverEntityId = @intDriverId) and intDriverEntityId = @intDriverId      
      
insert into                
  tblMBILLoadSchedule(                
        intLoadId,                
        intLoadDetailId,                
  intDriverEntityId,                
        strLoadNumber,       
  strTrailerNo,    
        strType,      
        intItemId,                
        strItemNo,                
        strItemDescription,                
        dblQuantity,                
        strItemUOM,                
        dblGross,                
        dblTare,                
        dblNet,                
        strWeightItemUOM,                
        intEntityId,                
        strName,                
        intEntityLocationId,                
        strShipName,                
        strAddress,                
        strCity,                
        strCountry,                
        strState,                
        strZipCode,                
        strEmail,                
        strPhone,                
        strMobile,                
        intCompanyLocationId,                
        strCompanyLocationName,                
        strCompanyLocationAddress,                
  strCompanyLocationCity,                
        strCompanyLocationCountry,                
        strCompanyLocationState,                
        strCompanyLocationZipCode,                
        strCompanyLocationMail,                
        strCompanyLocationPhone,                
        dtmSchedulePullDate,                
        dtmScheduleDeliveryDate,                
        strBOL,                
        strPONumber,                
  dblCompanyLocationLongitude,                
  dblCompanyLocationLatitude,                
  dblLongitude,                
  dblLatitude,              
  strTruckNo,  
  intTruckId,  
  strCompanyName                
    )                
Select                
    v.*,b.strCompanyName                
from                
    (                
        Select                
            intLoadId,                
            intLoadDetailId,                
   intDriverEntityId,                
            strLoadNumber,      
   strTrailerNo1,    
            strType = 'Inbound',                
            intItemId,                
            strItemNo,                
            strItemDescription,                
            dblQuantity,                
            strItemUOM,                
            dblGross,                
            dblTare,                
            dblNet,                
            strWeightItemUOM,                
            intEntityId = intVendorEntityId,                
            strName = strVendor,                
            intEntityLocationId = intVendorEntityLocationId,                
            strShipName = strShipFrom,                
            strAddress = strShipFromAddress,                
            strCity = strShipFromCity,                
            strCountry = strShipFromCountry,                
            strState = strShipFromState,                
            strZipCode = strShipFromZipCode,                
            strEmail = strVendorEmail,                
            strPhone = strVendorPhone,                
            strMobile = strVendorMobile,                
            intCompanyLocationId = intPCompanyLocationId,                
            strCompanyLocationName = strPLocationName,                
            strCompanyLocationAddress = strPLocationAddress,                
      strCompanyLocationCity = strPLocationCity,                
            strCompanyLocationCountry = strPLocationCountry,                
            strCompanyLocationState = strPLocationState,                
            strCompanyLocationZipCode = strPLocationZipCode,                
            strCompanyLocationMail = strPLocationMail,                
            strCompanyLocationPhone = strPLocationPhone,              
            dtmSchedulePullDate = (Select dtmETAPOL from tblLGLoad eta Where a.intLoadId = eta.intLoadId),                
            dtmSCheduleDeliveryDate = (Select dtmETAPOD from tblLGLoad pod Where a.intLoadId = pod.intLoadId),                
            strBOL = '',                
            strPONumber = isnull(a.strExternalLoadNumber,a.strDetailVendorReference),                
    dblCompanyLocationLongitude = b.dblLongitude,                
    dblCompanyLocationLatitude = b.dblLatitude,                
    c.dblLongitude,                
    c.dblLatitude  ,          
    strTruckNo,          
 intTruckId = d.intTruckDriverReferenceId  
   From vyuLGLoadDetailView a                
  Left Join tblSMCompanyLocation b on a.intPCompanyLocationId = b.intCompanyLocationId                
  Left Join tblEMEntityLocation c on a.intVendorEntityLocationId = c.intEntityLocationId                
  Left Join tblSCTruckDriverReference d on a.strTruckNo = d.strData  
     where                
            isnull(ysnDispatched, 0) = 1                
            and intPurchaseSale = 1                
            and ysnInProgress = 0                
            and ISNULL(dblDeliveredQuantity, 0.000000) <= 0                
            and strTransUsedBy = 'Transport Load'                
                
        Union All                
                
        Select                
            intLoadId,                
            intLoadDetailId,                
   intDriverEntityId,                
            strLoadNumber,       
   strTrailerNo1,    
            strType = 'Outbound',               
            intItemId,                
            strItemNo,                
            strItemDescription,                
            dblQuantity,                
            strItemUOM,                
            dblGross,                
            dblTare,                
            dblNet,                
            strWeightItemUOM,                
   intCustomerEntityId,                
            strCustomer,                
            intCustomerEntityLocationId,                
            strShipTo,                
            strShipToAddress,                
            strShipToCity,                
            strShipToCountry,                
            strShipToState,                
            strShipToZipCode,                
            strCustomerEmail,                
            strCustomerPhone,                
            strCustomerMobile,                
            intSCompanyLocationId,                
            strSLocationName,                
            strSLocationAddress,                
   strSLocationCity,                
            strSLocationCountry,                
            strSLocationState,                
            strSLocationZipCode,                
            strSLocationMail,                
            strSLocationPhone,                
            dtmSchedulePullDate = (Select dtmETAPOL from tblLGLoad eta Where a.intLoadId = eta.intLoadId),                
            dtmSCheduleDeliveryDate = (Select dtmETAPOD from tblLGLoad pod Where a.intLoadId = pod.intLoadId),                
            strBOL = '',                
            strPONumber = isnull(a.strDetailCustomerReference,a.strCustomerReference),               
     dblCompanyLocationLongitude = b.dblLongitude,                
     dblCompanyLocationLatitude = b.dblLatitude,                
     c.dblLongitude,               
     c.dblLatitude,          
     strTruckNo,  
  intTruckId = d.intTruckDriverReferenceId  
        From vyuLGLoadDetailView a                
  left join tblSMCompanyLocation b on a.intSCompanyLocationId = b.intCompanyLocationId                
  Left join tblEMEntityLocation c on a.intCustomerEntityLocationId = c.intEntityLocationId                
  Left join tblSCTruckDriverReference d on a.strTruckNo = d.strData  
        Where intPurchaseSale = 2                
            and isnull(ysnDispatched, 0) = 1                
            and ysnInProgress = 0                
            and ISNULL(dblDeliveredQuantity, 0.000000) <= 0                
            and strTransUsedBy = 'Transport Load'                
union all            
                
        Select                
            intLoadId,                
            intLoadDetailId,                
   intDriverEntityId,                
            strLoadNumber,     
   strTrailerNo1,    
            strType = 'DropShip',               
            intItemId,                
            strItemNo,                
            strItemDescription,                
            dblQuantity,                
            strItemUOM,                
            dblGross,                
            dblTare,                
            dblNet,                
            strWeightItemUOM,         
   intEntityId = intVendorEntityId,                
            strName = strVendor,                
            intEntityLocationId = intVendorEntityLocationId,                
            strShipName = strShipFrom,                
            strAddress = strShipFromAddress,                
            strCity = strShipFromCity,                
            strCountry = strShipFromCountry,                
            strState = strShipFromState,                
            strZipCode = strShipFromZipCode,                
            strEmail = strVendorEmail,                
            strPhone = strVendorPhone,                
   strMobile = strVendorMobile,            
   intCustomerEntityLocationId,                
            strCustomer,               
            strShipToAddress,                
            strShipToCity,                
            strShipToCountry,                
            strShipToState,                
            strShipToZipCode,                
            strCustomerEmail,                
            strCustomerPhone,               
            dtmSchedulePullDate = (Select dtmETAPOL from tblLGLoad eta Where a.intLoadId = eta.intLoadId),                
            dtmSCheduleDeliveryDate = (Select dtmETAPOD from tblLGLoad pod Where a.intLoadId = pod.intLoadId),                
            strBOL = '',                
            strPONumber = isnull(a.strExternalLoadNumber,a.strDetailVendorReference),           
   dblCompanyLocationLongitude = b.dblLongitude,            
   dblCompanyLocationLatitude = b.dblLatitude,                
   c.dblLongitude,                
   c.dblLatitude  ,          
   strTruckNo        ,  
   intTruckId = intTruckDriverReferenceId  
   From vyuLGLoadDetailView a                
  left join tblSMCompanyLocation b on a.intSCompanyLocationId = b.intCompanyLocationId                
  Left join tblEMEntityLocation c on a.intCustomerEntityLocationId = c.intEntityLocationId                
  Left join tblSCTruckDriverReference d on a.strTruckNo = d.strData  
        Where intPurchaseSale = 3                
            and isnull(ysnDispatched, 0) = 1                
            and ysnInProgress = 0                
            and ISNULL(dblDeliveredQuantity, 0.000000) <= 0                
            and strTransUsedBy = 'Transport Load'                
    ) v                
left join tblSMCompanySetup b on 1 = 1                
Where intLoadId not in(select intLoadId from tblMBILLongTruckHeader)                 
end             
      