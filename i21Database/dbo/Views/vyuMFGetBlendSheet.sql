CREATE VIEW [dbo].[vyuMFGetBlendSheet]
AS 
Select w.intWorkOrderId,w.strWorkOrderNo,i.strItemNo,i.strDescription,
w.dblQuantity,um.strUnitMeasure AS strUOM,w.dtmExpectedDate,w.intStatusId,w.ysnUseTemplate
from tblMFWorkOrder w 
Join tblICItem i on w.intItemId=i.intItemId 
Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId 
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
