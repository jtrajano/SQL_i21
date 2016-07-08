CREATE VIEW [dbo].[vyuSTMarkUpDownItems]
AS

select A.strItemNo
,A.strDescription
,A.strUpcCode
,A.strLongUPCCode
,A.intItemId
,A.intLocationId
,B.intStoreId
,B.intStoreNo
,A.dblSalePrice 
from vyuICGetItemPricing A
inner join tblSTStore  B
on A.intLocationId  = B.intCompanyLocationId

inner join vyuICGetItemLocation C
on A.intItemUOMId = C.intIssueUOMId

where C.intItemLocationId =  A.intItemLocationId