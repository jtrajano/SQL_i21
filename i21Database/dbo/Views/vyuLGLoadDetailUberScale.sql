﻿CREATE VIEW vyuLGLoadDetailUberScale  
AS  
SELECT   
   Load.intLoadId  
  ,Load.[strLoadNumber]  
  ,LoadDetail.intLoadDetailId  
  ,LoadDetail.dblQuantity  
  ,LoadDetail.intVendorEntityId  
  ,LoadDetail.intCustomerEntityId  
  ,strVendor = VEN.strName  
  ,strShipFromAddress = VEL.strAddress  
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
FROM tblLGLoadDetail LoadDetail  
JOIN tblLGLoad Load ON Load.intLoadId = LoadDetail.intLoadId   
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LoadDetail.intVendorEntityId  
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LoadDetail.intVendorEntityLocationId  
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