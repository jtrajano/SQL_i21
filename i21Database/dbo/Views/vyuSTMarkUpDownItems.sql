CREATE VIEW [dbo].[vyuSTMarkUpDownItems]
AS

select strItemNo
, strDescription
, strUpcCode
, strLongUPCCode
, intItemId
, intLocationId
, dblSalePrice 
from vyuICGetItemPricing 
