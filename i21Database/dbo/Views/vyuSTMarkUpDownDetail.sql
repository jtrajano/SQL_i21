CREATE VIEW [dbo].[vyuSTMarkUpDownDetail]
AS

select C.intMarkUpDownDetailId
, A.intMarkUpDownId
, D.strUpcCode
, E.strCategoryCode
, C.strMarkUpOrDown
, C.intQty
, C.dblRetailPerUnit
, C.dblTotalRetailAmount
, C.dblTotalCostAmount
, C.strReason

from tblSTMarkUpDown A inner join tblSTStore B
on A.intStoreId = B.intStoreId

inner join tblSTMarkUpDownDetail C
on A.intMarkUpDownId = C.intMarkUpDownId

inner join tblICItemUOM D
on D.intItemUOMId = C.intItemUOMId

left join tblICCategory E
on E.intCategoryId =  C.intCategoryId

