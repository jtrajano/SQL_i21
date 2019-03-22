CREATE VIEW [dbo].[vyuMFGetKitDemand]
AS
Select w.intBlendRequirementId,br.strDemandNo,w.intWorkOrderId,w.strWorkOrderNo,i.strItemNo,i.strDescription,
br.intLocationId,cl.strLocationName,w.intKitStatusId 
from tblMFWorkOrder w 
Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId 
Join tblICItem i on w.intItemId=i.intItemId 
Join tblSMCompanyLocation cl on br.intLocationId=cl.intCompanyLocationId
Where w.intKitStatusId in (6,7,12,8) And w.ysnKittingEnabled=1 And w.intStatusId in (9,10,11,12)