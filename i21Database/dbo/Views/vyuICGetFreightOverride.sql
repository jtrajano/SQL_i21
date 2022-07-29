CREATE VIEW [dbo].[vyuICGetFreightOverride]      
 AS       
      
SELECT     
  fo.intFreightOverrideId    
 ,fo.intItemId    
 ,Item.strItemNo    
 ,fo.intFreightOverrideItemId    
 ,ItemFO.strItemNo  AS strFreightOverrideItemNo  
 ,ItemFO.strDescription AS strDescription  
 ,SMLocation.intCompanyLocationId    
 ,SMLocation.strLocationName  
 ,fo.ysnActive    
    
FROM tblICFreightOverride fo    
 INNER JOIN tblSMCompanyLocation SMLocation ON SMLocation.intCompanyLocationId = fo.intCompanyLocationId      
 INNER JOIN tblICItem Item ON Item.intItemId = fo.intItemId 
 INNER JOIN tblICItem ItemFO ON ItemFO.intItemId = fo.intFreightOverrideItemId
