CREATE view [dbo].[vyuMFGetItemSupplyTarget]
As
Select I.strItemNo, CL.strLocationName, IL.dblLeadTime As dblSupplyTarget,I.intCompanyId
from tblICItem I
JOIN tblICItemLocation IL on IL.intItemId=I.intItemId
JOIN tblSMCompanyLocation CL on CL.intCompanyLocationId=IL.intLocationId 
