CREATE VIEW [dbo].[vyuGRSellOffsiteNotMapped]
AS
SELECT    
 intSellOffsiteId					= SO.intSellOffsiteId
,intEntityId						= SO.intEntityId
,strEntityName						= E.strName
,intItemId							= SO.intItemId
,strItemNo							= Item.strItemNo
,intCompanyLocationId				= SO.intCompanyLocationId
,strLocationName					= L.strLocationName
,intCompanyLocationSubLocationId	= SO.intCompanyLocationSubLocationId
,strSubLocationName					= SLOC.strSubLocationName
FROM tblGRSellOffsite SO
JOIN tblICItem Item ON Item.intItemId = SO.intItemId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId= SO.intCompanyLocationId
JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=SO.intCompanyLocationSubLocationId  
JOIN tblEMEntity E ON E.intEntityId = SO.intEntityId
