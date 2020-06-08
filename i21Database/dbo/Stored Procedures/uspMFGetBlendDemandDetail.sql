CREATE PROCEDURE [dbo].[uspMFGetBlendDemandDetail]
	@dtmFromDate Date,
	@dtmToDate Date,
	@intItemId int,
	@intLocationId int
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @intBlenderId int
DECLARE @strBlenderName NVARCHAR(50)
DECLARE @dblBlenderCapacity NUMERIC(18,6)
DECLARE @intDefaultCellId INT
DECLARE @strDefaultCellName NVARCHAR(50)
DECLARE @dblDensity Numeric(18,6)
DECLARE @dblBlenderSize Numeric(18,6)
DECLARE @strItemNo NVARCHAR(50)
DECLARE @intPackTypeId int
DECLARE @strPackName NVARCHAR(50)
DECLARE @strErrMsg NVARCHAR(MAX)

Select @dblDensity=Case When ISNULL(dblDensity,0)=0 then 1.0 Else dblDensity End, 
@strItemNo=strItemNo,@intPackTypeId=intPackTypeId
From tblICItem Where intItemId=@intItemId

If ISNULL(@intPackTypeId,0)=0
	Begin
		Set @strErrMsg='Pack Type is not configured for item ' + @strItemNo + '.'
		RaisError(@strErrMsg,16,1)
	End

--Get Default Mfg. Cell
SELECT @intDefaultCellId=b.intManufacturingCellId,@strDefaultCellName=mc.strCellName FROM tblICItemFactory a 
JOIN tblICItemFactoryManufacturingCell b ON a.intItemFactoryId=b.intItemFactoryId 
JOIN tblMFManufacturingCell mc ON b.intManufacturingCellId=mc.intManufacturingCellId
WHERE a.intItemId=@intItemId AND a.intFactoryId=@intLocationId AND b.ysnDefault=1

--Get Default Belnder/Machine
Select TOP 1 @intBlenderId=m.intMachineId,@strBlenderName=m.strName,@dblBlenderCapacity=ISNULL(mp.dblMachineCapacity,0)
From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId
Where mc.intManufacturingCellId=@intDefaultCellId

If @intBlenderId is null
	Begin
		Set @strErrMsg='Machine is not configured for item ' + @strItemNo + '.'
		RaisError(@strErrMsg,16,1)
	End

If @dblBlenderCapacity=0
Begin
	Set @strErrMsg='Machine capacity is 0 for ' + '''' + @strBlenderName + '''' + '.'
	RaisError(@strErrMsg,16,1)
End

Set @dblBlenderSize=@dblDensity * @dblBlenderCapacity

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
	@dblBlenderSize AS dblBlenderSize,
	ROUND(bd.dblQuantity/CASE WHEN @dblBlenderSize = 0 THEN 1 ELSE @dblBlenderSize END,3) dblEstNoOfBlendSheet,
	@intDefaultCellId AS intDefaultCellId,
	@strDefaultCellName AS strDefaultCellName
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
	w.dtmExpectedDate AS dtmDueDate ,
	IsNULL(w.dblQuantity,0) AS dblQuantity,
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
	ORDER BY w.dtmExpectedDate

  --Lots At Storage
  SELECT DISTINCT pl.intParentLotId AS intLotId 
				 ,pl.strParentLotNumber  AS strLotNo    
				 ,IsNULL(pl.strParentLotAlias,'') AS strLotAlias
				 ,sub.strSubLocationName AS strSubLocation
			     ,sum(l.dblQty)  dblQuantity
				 ,um.strUnitMeasure AS strUOM
				 ,sl.strName AS strStorageLocation
 FROM tblICLot l      
 JOIN tblICItem i ON i.intItemId=l.intItemId AND l.intLocationId=@intLocationId
 JOIN tblICItemUOM iu ON iu.intItemUOMId = IsNULL(l.intWeightUOMId,l.intItemUOMId)
 JOIN tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
 JOIN tblICStorageLocation sl On sl.intStorageLocationId = l.intStorageLocationId
 JOIN tblICStorageUnitType sut ON sut.intStorageUnitTypeId = sl.intStorageUnitTypeId
 JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId=l.intSubLocationId
 JOIN tblICParentLot pl ON pl.intParentLotId=l.intParentLotId
 WHERE sut.strInternalCode='STORAGE' AND l.intItemId=@intItemId AND ISNULL(l.dblQty,0) <> 0      
 group by pl.intParentLotId,pl.strParentLotNumber,pl.strParentLotAlias,sub.strSubLocationName,um.strUnitMeasure,sl.strName
 Order by pl.strParentLotNumber

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
 
 END TRY  
  
BEGIN CATCH  
 SET @strErrMsg = ERROR_MESSAGE()  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  
END CATCH  