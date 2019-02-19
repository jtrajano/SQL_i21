﻿CREATE PROCEDURE [dbo].[uspMFGetWorkOrdersFromSalesOrder]
	@intSalesOrderId int ,
	@intSalesOrderDetailId int,
	@intItemId int,
	@intManufacturingProcessId int,
	@dblQuantity numeric(18,6),
	@intCellId int=0,
	@intMachineId int=0,
	@dblMachineCapacity numeric(18,6)=0,
	@intMachineCapacityUOMId int=0
AS

Declare @intLocationId int
Declare @intAttributeTypeId int
Declare @strCellName nvarchar(50)
Declare @dtmOrderDate DateTime=GETDATE()
Declare @intNoOfWO int
Declare @intOrigNoOfWO int
Declare @dblPerBlendSheetQty numeric(18,6)
Declare @intItemUOMId int
Declare @intMachineCapacityItemUOMId int
Declare @strMachineName nvarchar(50)
Declare @strUOM nvarchar(50)

Declare @tblWO As table
(
	intWorkOrderId int,
	strWorkOrderNo nvarchar(50),
	dblQuantity numeric(18,6),
	dtmDueDate datetime,
	intCellId int,
	strCellName nvarchar(50)
)

Select @intLocationId=intCompanyLocationId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

Select @intItemUOMId=intItemUOMId From tblSOSalesOrderDetail Where intSalesOrderDetailId=@intSalesOrderDetailId

--if the item does not belong to the SO, it is the recipe input item (next level recipe), use stock uom
If Not Exists (Select 1 From tblSOSalesOrderDetail Where intSalesOrderDetailId=@intSalesOrderDetailId AND intItemId=@intItemId)
	Select @intItemUOMId=intItemUOMId From tblICItemUOM where intItemId=@intItemId AND ysnStockUnit=1

Select @strCellName=strCellName From tblMFManufacturingCell Where intManufacturingCellId=@intCellId

Select @intAttributeTypeId=mp.intAttributeTypeId 
From tblMFManufacturingProcess mp
Where mp.intManufacturingProcessId=@intManufacturingProcessId

--Get Default Cell
If ISNULL(@intCellId,0)=0
Begin
	Select TOP 1 @intCellId=ifc.intManufacturingCellId,@strCellName=mc.strCellName 
	From tblICItemFactoryManufacturingCell ifc Join tblICItemFactory tf on ifc.intItemFactoryId=tf.intItemFactoryId 
	Join tblMFManufacturingCell mc on ifc.intManufacturingCellId=mc.intManufacturingCellId
	Where tf.intItemId=@intItemId And tf.intFactoryId=@intLocationId Order by ifc.ysnDefault Desc

	--Get Bin Size Using Default Cell And Machine
	Select TOP 1 @dblMachineCapacity=mp.dblMachineCapacity,@intMachineCapacityUOMId=mp.intMachineUOMId,@intMachineId=m.intMachineId 
	From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
	Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
	Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId
	Where mc.intManufacturingCellId=@intCellId
End

Select @intMachineCapacityItemUOMId=intItemUOMId From tblICItemUOM Where intItemId=@intItemId AND intUnitMeasureId=@intMachineCapacityUOMId

Select @strMachineName=strName From tblMFMachine Where intMachineId=@intMachineId

--Convert Qty to Capacity UOM
If @intAttributeTypeId=2 --Blending
Begin
	If ISNULL(@intMachineCapacityItemUOMId,0) >0
	Begin
		Select @dblQuantity=dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId,@intMachineCapacityItemUOMId,@dblQuantity)
		Select @strUOM=strUnitMeasure From tblICUnitMeasure Where intUnitMeasureId=@intMachineCapacityUOMId
	End
	Else
		Select @strUOM=strUnitMeasure From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId Where iu.intItemUOMId=@intItemUOMId
End
	Select @strUOM=strUnitMeasure From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId Where iu.intItemUOMId=@intItemUOMId

--Existing WOs
If Exists(Select 1 From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId And intItemId=@intItemId And intManufacturingProcessId=@intManufacturingProcessId)
	Begin
		Select CONVERT(INT, ROW_NUMBER() OVER(ORDER BY intWorkOrderId ASC)) AS intRowNo,w.intWorkOrderId,w.strWorkOrderNo,w.dblQuantity,w.dtmExpectedDate AS dtmDueDate,mc.strCellName,br.strDemandNo,um.strUnitMeasure AS strUOM,w.dtmPlannedDate,w.intPlannedShiftId,s.strShiftName AS strPlannedShiftName,mp.intAttributeTypeId
		From tblMFWorkOrder w Join tblMFManufacturingCell mc on w.intManufacturingCellId=mc.intManufacturingCellId
		Left Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId
		Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
		Left Join tblMFShift s on w.intPlannedShiftId=s.intShiftId
		Join tblMFManufacturingProcess mp on w.intManufacturingProcessId=mp.intManufacturingProcessId
		Where intSalesOrderLineItemId=@intSalesOrderDetailId And w.intItemId=@intItemId And w.intManufacturingProcessId=@intManufacturingProcessId
	End
Else
Begin --New WOs
	If @intAttributeTypeId=2 --Blending
		Begin
			If ISNULL(@dblMachineCapacity,0)>0
			Begin
				If @dblQuantity <= @dblMachineCapacity
					Begin
						Set @dblPerBlendSheetQty=@dblQuantity
						Set @intNoOfWO=1	
					End
				Else
					Begin
						Set @intNoOfWO=@dblQuantity / @dblMachineCapacity
						Set @dblPerBlendSheetQty=@dblMachineCapacity
								
					End
				
				Set @intOrigNoOfWO=@intNoOfWO

				While (@intNoOfWO > 0)
				Begin
					Insert into @tblWO(intWorkOrderId,strWorkOrderNo,dblQuantity,dtmDueDate,intCellId,strCellName)
					values(0,'',@dblPerBlendSheetQty,@dtmOrderDate,@intCellId,@strCellName)

					Set @intNoOfWO = @intNoOfWO - 1	
				End

				--Add the remaining Qty
				If (@dblQuantity - (@dblPerBlendSheetQty * @intOrigNoOfWO)) > 0 
					Insert into @tblWO(intWorkOrderId,strWorkOrderNo,dblQuantity,dtmDueDate,intCellId,strCellName)
					values(0,'',(@dblQuantity - (@dblPerBlendSheetQty * @intOrigNoOfWO)),@dtmOrderDate,@intCellId,@strCellName)
			End
			Else
			Begin
					Insert into @tblWO(intWorkOrderId,strWorkOrderNo,dblQuantity,dtmDueDate,intCellId,strCellName)
					values(0,'',@dblQuantity,@dtmOrderDate,@intCellId,@strCellName)
			End

			Select CONVERT(INT, ROW_NUMBER() OVER(ORDER BY intWorkOrderId ASC)) AS intRowNo,*,@intMachineId AS intMachineId,@strMachineName AS strMachineName,ISNULL(@dblMachineCapacity,0.0) AS dblMachineCapacity,@strUOM AS strUOM From @tblWO
		End
	Else
		Select CONVERT(INT, ROW_NUMBER() OVER(ORDER BY @dtmOrderDate ASC)) AS intRowNo,0 AS intWorkOrderId,'' AS strWorkOrderNo,@dblQuantity AS dblQuantity,@dtmOrderDate AS dtmDueDate,@intCellId AS intCellId,@strCellName AS strCellName,@strUOM AS strUOM,0 AS intMachineId,0.0 AS dblMachineCapacity
End