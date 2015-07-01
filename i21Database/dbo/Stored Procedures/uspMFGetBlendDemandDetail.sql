CREATE PROCEDURE [dbo].[uspMFGetBlendDemandDetail]
	@dtmFromDate Date,
	@dtmToDate Date,
	@intItemId int,
	@intLocationId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @intBlenderId int
DECLARE @strBlenderName NVARCHAR(50)
DECLARE @dblBlenderCapacity NUMERIC(18,6)
DECLARE @intDefaultCellId INT

--Get Default Belnder/Machine
SELECT TOP 1 @intBlenderId=a.intMachineId,@strBlenderName=b.strName,@dblBlenderCapacity=c.dblMachineCapacity 
FROM tblMFItemMachine a 
JOIN tblMFMachine b on a.intMachineId=b.intMachineId 
JOIN tblMFMachinePackType c on b.intMachineId=c.intMachineId
WHERE a.intItemId=@intItemId AND a.intLocationId=@intLocationId ORDER BY a.ysnDefault DESC

--Get Default Mfg. Cell
SELECT @intDefaultCellId=b.intManufacturingCellId FROM tblICItemFactory a 
JOIN tblICItemFactoryManufacturingCell b ON a.intItemFactoryId=b.intItemFactoryId 
WHERE a.intItemId=@intItemId AND a.intFactoryId=@intLocationId AND b.ysnDefault=1

--Demand Details
 SELECT
	bd.intBlendDemandId,       
	i.intItemId,
	@intLocationId AS intLocationId,    
	bd.strDemandNo,
    bd.strOrderType,
    bd.strOrderNo,
	bd.dtmDueDate,
	i.strItemNo,
	bd.dblQuantity,
	u.intUnitMeasureId AS intUOMId,
	u.strUnitMeasure AS strUOM,
	mc.strCellName strFGManufacturingCell,
	m.strName strFGMachine,
	@intBlenderId AS intBlenderId,          
	@strBlenderName AS strDefaultBlender,
	ISNULL(i.intReceiveLife * @dblBlenderCapacity,0) dblBlenderSize,
	ROUND(bd.dblQuantity/CASE WHEN (ISNULL(i.intReceiveLife * @dblBlenderCapacity,0) = 0) THEN 1 ELSE ISNULL(i.intReceiveLife * @dblBlenderCapacity,0) END,3) dblEstNoOfBlendSheet,
	@intDefaultCellId AS intDefaultCellId
 FROM tblMFBlendDemand bd
 JOIN tblICItem i ON bd.intItemId=i.intItemId AND bd.intLocationId=@intLocationId
 JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId AND iu.ysnStockUnit=1
 JOIN tblICUnitMeasure u ON iu.intUnitMeasureId=u.intUnitMeasureId
 LEFT JOIN tblMFManufacturingCell mc ON bd.intManufacturingCellId=mc.intManufacturingCellId
 LEFT JOIN tblMFMachine m ON bd.intMachineId=m.intMachineId
 WHERE bd.intItemId=@intItemId AND bd.intStatusId=1  AND bd.dtmDueDate BETWEEN @dtmFromDate  AND  @dtmToDate   
 ORDER BY bd.dtmDueDate 

 --Blend Sheet Details
	SELECT  distinct
	w.intWorkOrderId AS intBlendSheetId,      
	m.strName AS strMachine,
	mc.strCellName AS strManufacturingCell,
	br.strDemandNo,
	br.dtmDueDate,
	w.dblQuantity,
	um.strUnitMeasure AS strUOM,
	w.strWorkOrderNo AS strBlendSheetNo
	FROM tblMFWorkOrder w       
	JOIN tblICItem i ON i.intItemId=w.intItemId
	JOIN tblMFBlendRequirement br ON br.intBlendRequirementId=w.intBlendRequirementId AND br.intLocationId=@intLocationId
	JOIN tblMFManufacturingCell mc ON br.intManufacturingCellId=mc.intManufacturingCellId
	LEFT JOIN tblMFMachine m ON m.intMachineId=br.intMachineId
	JOIN tblICItemUOM iu ON iu.intItemUOMId = w.intItemUOMId
	JOIN tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	WHERE w.intItemId=@intItemId AND w.intStatusId <> 13
	ORDER BY br.dtmDueDate

 --Lots At Staging
  SELECT DISTINCT pl.intParentLotId AS intLotId 
				 ,pl.strParentLotNumber  AS strLotNo    
				 ,pl.strParentLotAlias AS strLotAlias
				 ,sub.strSubLocationName AS strSubLocation
			     ,sum(l.dblWeight)  dblQuantity
				 ,um.strUnitMeasure AS strUOM
				 ,sl.strName AS strStorageLocation
 FROM tblICLot l      
 JOIN tblICItem i ON i.intItemId=l.intItemId AND l.intLocationId=@intLocationId
 JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intWeightUOMId
 JOIN tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
 JOIN tblICStorageLocation sl On sl.intStorageLocationId = l.intStorageLocationId
 JOIN tblICStorageUnitType sut ON sut.intStorageUnitTypeId = sl.intStorageUnitTypeId
 JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId=l.intSubLocationId
 JOIN tblICParentLot pl ON pl.intParentLotId=l.intParentLotId
 WHERE sut.strInternalCode='PROD_STAGING' AND l.intItemId=@intItemId AND ISNULL(l.dblWeight,0) <> 0      
 group by pl.intParentLotId,pl.strParentLotNumber,pl.strParentLotAlias,sub.strSubLocationName,um.strUnitMeasure,sl.strName
 Order by pl.strParentLotNumber

  --Lots At Storage
  SELECT DISTINCT pl.intParentLotId AS intLotId 
				 ,pl.strParentLotNumber  AS strLotNo    
				 ,pl.strParentLotAlias AS strLotAlias
				 ,sub.strSubLocationName AS strSubLocation
			     ,sum(l.dblWeight)  dblQuantity
				 ,um.strUnitMeasure AS strUOM
				 ,sl.strName AS strStorageLocation
 FROM tblICLot l      
 JOIN tblICItem i ON i.intItemId=l.intItemId AND l.intLocationId=@intLocationId
 JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intWeightUOMId
 JOIN tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
 JOIN tblICStorageLocation sl On sl.intStorageLocationId = l.intStorageLocationId
 JOIN tblICStorageUnitType sut ON sut.intStorageUnitTypeId = sl.intStorageUnitTypeId
 JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId=l.intSubLocationId
 JOIN tblICParentLot pl ON pl.intParentLotId=l.intParentLotId
 WHERE sut.strInternalCode='STORAGE' AND l.intItemId=@intItemId AND ISNULL(l.dblWeight,0) <> 0      
 group by pl.intParentLotId,pl.strParentLotNumber,pl.strParentLotAlias,sub.strSubLocationName,um.strUnitMeasure,sl.strName
 Order by pl.strParentLotNumber