CREATE VIEW [dbo].[vyuMFGetKitDemand]
AS
Select w.intBlendRequirementId,br.strDemandNo,w.intWorkOrderId,w.strWorkOrderNo,i.strItemNo,i.strDescription,
w.intLocationId,cl.strLocationName,w.intKitStatusId 
from tblMFWorkOrder w 
Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId 
Join tblICItem i on w.intItemId=i.intItemId 
Join tblSMCompanyLocation cl on w.intLocationId=cl.intCompanyLocationId
Where w.intKitStatusId in (6,7,12,8) And w.ysnKittingEnabled=1