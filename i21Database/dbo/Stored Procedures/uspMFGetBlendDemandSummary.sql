CREATE PROCEDURE [dbo].[uspMFGetBlendDemandSummary]
	@dtmFromDate Date,
	@dtmToDate Date,
	@intLocationId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT   
t.intItemId,  
t.strItemNo,  
t.strDescription AS strItemDesc,
t.intLocationId, 
t.DMTotal AS dblDemandTotal,  
ISNULL(t.BRTotal,0) AS [dblBRTotal],  
ISNULL(t.BSTotal,0) AS [dblBSTotal],  
ISNULL(t.StorageQty,0) [dblStorageQty],  
ISNULL(t.StagingQty,0) [dblStagingQty],  
(ISNULL(t.DMTotal,0)-((ISNULL(t.BRTotal,0))+(ISNULL(t.BSTotal,0)-ISNULL(t.ProducedQty,0))+ISNULL(t.StorageQty,0))) [dblNetDemandQty]  
FROM (  
SELECT  i.intItemId,i.strItemNo,i.strDescription,bd.intLocationId,SUM(bd.dblQuantity) as DMTotal,  
(SELECT SUM(dblQuantity) FROM tblMFBlendRequirement WHERE intItemId=i.intItemId AND intStatusId=1)  as BRTotal,  
(SELECT SUM(dblQuantity) FROM tblMFWorkOrder WHERE intItemId=i.intItemId AND intStatusId<>13)  as BSTotal,  
(SELECT SUM(dblProducedQuantity) FROM tblMFWorkOrder Where intItemId=i.intItemId)  as ProducedQty,  
(SELECT SUM(dblWeight) FROM tblICLot WHERE intLocationId=@intLocationId and intStorageLocationId IN (SELECT DISTINCT intStorageLocationId FROM tblICStorageLocation WHERE intStorageUnitTypeId in (Select intStorageUnitTypeId From tblICStorageUnitType Where UPPER(strInternalCode)='PROD_STAGING')) and intItemId=i.intItemId) AS StagingQty,    
(SELECT SUM(dblWeight) FROM tblICLot WHERE intLocationId=@intLocationId and intStorageLocationId IN (SELECT DISTINCT intStorageLocationId FROM tblICStorageLocation WHERE intStorageUnitTypeId in (Select intStorageUnitTypeId From tblICStorageUnitType Where UPPER(strInternalCode)='STORAGE')) and intItemId=i.intItemId) AS StorageQty 
FROM tblMFBlendDemand bd   
JOIN tblICItem i ON bd.intItemId=i.intItemId AND bd.intLocationId=@intLocationId
WHERE bd.intStatusId=1  AND bd.dtmDueDate is not null
AND bd.dtmDueDate BETWEEN @dtmFromDate  AND  @dtmToDate
GROUP BY i.intItemId,i.strItemNo,i.strDescription,bd.intLocationId) t

