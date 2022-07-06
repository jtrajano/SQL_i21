CREATE VIEW vyuLGLoadDetailUberScale  
AS  
SELECT     
   DISTINCT      
   Load.intLoadId      
  ,Load.[strLoadNumber]      
  ,Load.[intPurchaseSale]  
  ,LoadDetail.intLoadDetailId    
  ,LoadDetail.dblQuantity    
  ,LoadDetail.intVendorEntityId    
  ,LoadDetail.intCustomerEntityId    
  ,strVendor = VEN.strName    
  ,strCustomer = CEN.strName
  ,strShipFrom = VEL.strAddress    
  ,strShipFromAddress = VEL.strAddress    
  ,strShipFromCity = VEL.strCity  
  ,strShipFromCountry = VEL.strCountry  
  ,strShipFromState = VEL.strState  
  ,strShipFromZipCode = VEL.strZipCode  
  ,strShipTo = CEL.strAddress    
  ,strShipToAddress = CEL.strAddress    
  ,strShipToCity = CEL.strCity  
  ,strShipToCountry = CEL.strCountry  
  ,strShipToState = CEL.strState  
  ,strShipToZipCode = CEL.strZipCode 
  ,strPContractNumber = PHeader.strContractNumber    
  ,strSContractNumber = SHeader.strContractNumber    
  ,Commodity.strCommodityCode AS strCommodity    
  ,UOM.strUnitMeasure AS strItemUOM    
  ,strHauler = Hauler.strName    
  ,strHaulerPhone = Hauler.strPhone  
  ,LSI.strLoadNumber AS strShippingInstructionNo    
  ,Item.intCommodityId  
  ,strSFarmNumber = SEF.strFarmNumber  
  ,strPFarmNumber = PEF.strFarmNumber    
  ,intDriverEntityId = Load.intDriverEntityId
FROM tblLGLoadDetail LoadDetail    
JOIN tblLGLoad Load ON Load.intLoadId = LoadDetail.intLoadId     
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LoadDetail.intVendorEntityId    
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LoadDetail.intCustomerEntityId  
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LoadDetail.intVendorEntityLocationId    
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId 
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId    
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId    
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LoadDetail.intSContractDetailId    
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId    
LEFT JOIN tblEMEntityFarm     SEF ON SEF.intFarmFieldId     =  SDetail.intFarmFieldId  
LEFT JOIN tblEMEntityFarm     PEF ON PEF.intFarmFieldId     =  PDetail.intFarmFieldId  
LEFT JOIN tblICItem Item On Item.intItemId = LoadDetail.intItemId    
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId    
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId    
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId    
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = Load.intHaulerEntityId     
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = Load.intLoadShippingInstructionId 