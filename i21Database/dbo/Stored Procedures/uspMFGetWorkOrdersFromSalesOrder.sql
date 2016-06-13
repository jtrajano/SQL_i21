CREATE PROCEDURE [dbo].[uspMFGetWorkOrdersFromSalesOrder]
	@intSalesOrderId int ,
	@intSalesOrderDetailId int,
	@intItemId int,
	@intManufacturingProcessId int,
	@dblQuantity numeric(18,6)
AS

Declare @intLocationId int
Declare @intAttributeTypeId int
Declare @intCellId int
Declare @dblBlendBinSize numeric(18,6)
Declare @strCellName nvarchar(50)
Declare @dtmOrderDate DateTime
Declare @intNoOfWO int
Declare @intOrigNoOfWO int
Declare @dblPerBlendSheetQty numeric(18,6)

Declare @tblWO As table
(
	intWorkOrderId int,
	strWorkOrderNo nvarchar(50),
	dblQuantity numeric(18,6),
	dtmDueDate datetime,
	intCellId int,
	strCellName nvarchar(50)
)

Select @intLocationId=intCompanyLocationId,@dtmOrderDate=dtmDueDate From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

Select @intAttributeTypeId=mp.intAttributeTypeId 
From tblMFManufacturingProcess mp
Where mp.intManufacturingProcessId=@intManufacturingProcessId

--Get Default Cell
Select TOP 1 @intCellId=ifc.intManufacturingCellId,@strCellName=mc.strCellName 
From tblICItemFactoryManufacturingCell ifc Join tblICItemFactory tf on ifc.intItemFactoryId=tf.intItemFactoryId 
Join tblMFManufacturingCell mc on ifc.intManufacturingCellId=mc.intManufacturingCellId
Where tf.intItemId=@intItemId And tf.intFactoryId=@intLocationId Order by ifc.ysnDefault Desc

--Get Bin Size Using Default Cell And Machine
Select TOP 1 @dblBlendBinSize=mp.dblMachineCapacity 
From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId
Join tblMFPackType pk on mp.intPackTypeId=pk.intPackTypeId 
Where pk.intPackTypeId=(Select intPackTypeId From tblICItem Where intItemId=@intItemId)
And mc.intManufacturingCellId=@intCellId

--Existing WOs
If Exists(Select 1 From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId And intItemId=@intItemId And intManufacturingProcessId=@intManufacturingProcessId)
	Begin
		Select w.intWorkOrderId,w.strWorkOrderNo,w.dblQuantity,w.dtmExpectedDate AS dtmDueDate,mc.strCellName,br.strDemandNo 
		From tblMFWorkOrder w Join tblMFManufacturingCell mc on w.intManufacturingCellId=mc.intManufacturingCellId
		Left Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId
		Where intSalesOrderLineItemId=@intSalesOrderDetailId And w.intItemId=@intItemId And w.intManufacturingProcessId=@intManufacturingProcessId
	End
Else
Begin --New WOs
	If @intAttributeTypeId=2 --Blending
		Begin
			If ISNULL(@dblBlendBinSize,0)>0
			Begin
				If @dblQuantity <= @dblBlendBinSize
					Begin
						Set @dblPerBlendSheetQty=@dblQuantity
						Set @intNoOfWO=1	
					End
				Else
					Begin
						Set @intNoOfWO=@dblQuantity / @dblBlendBinSize
						Set @dblPerBlendSheetQty=@dblBlendBinSize
								
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

			Select * From @tblWO
		End
	Else
		Select 0 AS intWorkOrderId,'' AS strWorkOrderNo,@dblQuantity AS dblQuantity,@dtmOrderDate AS dtmDueDate,@intCellId AS intCellId,@strCellName AS strCellName
End