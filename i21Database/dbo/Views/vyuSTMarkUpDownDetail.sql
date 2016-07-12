CREATE VIEW [dbo].[vyuSTMarkUpDownDetail]
AS

select C.intMarkUpDownDetailId
, A.intMarkUpDownId
, strItemNo = (CASE WHEN C.intCategoryId <> 0 THEN '' ELSE D.strItemNo END )
, intItemId = (CASE WHEN C.intCategoryId <>  0 THEN 0 ELSE D.intItemId END)
, strCategoryCode = (CASE WHEN C.intCategoryId = 0 and D.strItemNo is NULL THEN '' ELSE (select strCategoryCode from tblICCategory where intCategoryId =  C.intCategoryId)END )
,C.strMarkUpOrDown
, C.intQty
, C.dblRetailPerUnit
, C.dblTotalRetailAmount
, C.dblTotalCostAmount
, C.strReason


from tblSTMarkUpDown A 
inner join tblSTStore B
on A.intStoreId = B.intStoreId

inner join tblSTMarkUpDownDetail C
on A.intMarkUpDownId = C.intMarkUpDownId

left join  vyuSTMarkUpDownItems D
on C.intItemId = D.intItemId

and A.intStoreId =  D.intStoreId