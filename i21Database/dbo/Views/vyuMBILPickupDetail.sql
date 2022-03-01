CREATE view vyuMBILPickupDetail        
as              
SELECT  detail.intPickupDetailId        
       ,detail.intLoadDetailId        
       ,detail.intLoadHeaderId        
       ,detail.intEntityId        
       ,detail.intEntityLocationId        
       ,detail.intCompanyLocationId        
       ,load.strType        
       ,load.strLoadNumber        
       ,detail.intItemId        
       ,item.strDescription        
       ,item.strItemNo        
       ,detail.dblQuantity        
       ,detail.dblPickupQuantity        
       ,detail.strRack        
       ,detail.strBOL      
       ,detail.strNote      
       ,detail.dtmPickupFrom        
       ,detail.dtmPickupTo        
       ,detail.dtmActualPickupFrom        
       ,detail.dtmActualPickupTo        
       ,detail.ysnPickup    
       ,detail.strPONumber    
FROM tblMBILPickupDetail detail              
INNER JOIN tblMBILLoadHeader load on detail.intLoadHeaderId = load.intLoadHeaderId        
INNER JOIN tblICItem item on detail.intItemId = item.intItemId        
LEFT join tblEMEntity entity on detail.intEntityId = entity.intEntityId                
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = detail.intSellerId              
LEFT JOIN tblEMEntity Salesperson ON Salesperson.intEntityId = detail.intSalespersonId              
left join tblEMEntityLocation location on detail.intEntityLocationId = location.intEntityLocationId and detail.intEntityId = location.intEntityId                
left join tblSMCompanyLocation companylocation on detail.intCompanyLocationId = companylocation.intCompanyLocationId                
left join tblSMCompanySetup company on 1=1 