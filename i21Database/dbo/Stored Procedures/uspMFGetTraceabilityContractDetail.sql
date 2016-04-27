CREATE PROCEDURE [dbo].[uspMFGetTraceabilityContractDetail]
	@intContractId int,
	@intDirectionId int
AS

SET NOCOUNT ON;

Select 'Contract' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.strVendor, 2 AS intImageTypeId,'C' AS strType
FROM (  
Select DISTINCT '' AS strTransactionName,c.intContractHeaderId intLotId,c.strContractNumber strLotNumber,'' strLotAlias,c.intItemId,c.strItemNo,c.strItemDescription strDescription,
0 intCategoryId,'' strCategoryCode,c.dblDetailQuantity dblQuantity,'' strUOM,
c.dtmContractDate AS dtmTransactionDate,c.strVendorId strVendor
from vyuCTContractDetailView c 
--Join tblICItem i on c.intItemId=i.intItemId
--Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
--Join tblICItemUOM iu on c.i=iu.intItemUOMId
--Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Where c.intContractHeaderId=@intContractId) t
group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.strVendor

