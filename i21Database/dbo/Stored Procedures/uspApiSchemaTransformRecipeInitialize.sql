CREATE PROCEDURE [dbo].[uspApiSchemaTransformRecipeInitialize]

AS

--Default Configuration for Blending Process 
--Add WIP Sub Location 
Insert Into tblSMCompanyLocationSubLocation(intCompanyLocationId,strSubLocationName,strSubLocationDescription,strClassification)
Select intCompanyLocationId,'Default WIP','Default WIP','WIP' 
From tblSMCompanyLocation
Where intCompanyLocationId not in (Select intCompanyLocationId From tblSMCompanyLocationSubLocation Where strSubLocationName='Default WIP')

--Add Cell 
Insert Into tblMFManufacturingCell(strCellName,strDescription,intSubLocationId,intLocationId,ysnActive,intConcurrencyId)
Select 'Default','Default',csl.intCompanyLocationSubLocationId,cl.intCompanyLocationId,1,0
From tblSMCompanyLocation cl join tblSMCompanyLocationSubLocation csl on cl.intCompanyLocationId=csl.intCompanyLocationId AND csl.strSubLocationName='Default WIP'
Where cl.intCompanyLocationId not in (Select intLocationId From tblMFManufacturingCell mc Where strCellName='Default')

--Add Machine 
Insert Into tblMFMachine(strName,strDescription,intSubLocationId,intLocationId,ysnActive,intConcurrencyId)
Select 'Default','Default',csl.intCompanyLocationSubLocationId,cl.intCompanyLocationId,1,0
From tblSMCompanyLocation cl join tblSMCompanyLocationSubLocation csl on cl.intCompanyLocationId=csl.intCompanyLocationId AND csl.strSubLocationName='Default WIP'
Where cl.intCompanyLocationId not in (Select intLocationId From tblMFMachine mc Where strName='Default')

--Add PackType 
If Not Exists (Select 1 From tblMFPackType Where strPackName='Default')
Insert Into tblMFPackType(strPackName,strDescription)
Select 'Default','Default'

--Add PackType to Cell 
Insert Into tblMFManufacturingCellPackType(intManufacturingCellId,intPackTypeId,dblLineCapacity,intLineCapacityUnitMeasureId)
Select intManufacturingCellId,(Select TOP 1 intPackTypeId From tblMFPackType Where strPackName='Default'),200000,
(Select intUnitMeasureId From tblICUnitMeasure Where strUnitMeasure='GALLON')
From tblMFManufacturingCell Where strCellName='Default'
and intManufacturingCellId not in (Select intManufacturingCellId From tblMFManufacturingCellPackType)

--Add PackType to Machine 
Insert Into tblMFMachinePackType(intMachineId,intPackTypeId,dblMachineCapacity,intMachineUOMId)
Select intMachineId,(Select TOP 1 intPackTypeId From tblMFPackType Where strPackName='Default'),200000,
(Select intUnitMeasureId From tblICUnitMeasure Where strUnitMeasure='GALLON')
From tblMFMachine Where strName='Default'
and intMachineId not in (Select intMachineId From tblMFMachinePackType)

--Add Blending Process 
If Not Exists (Select 1 From tblMFManufacturingProcess Where intAttributeTypeId=2 AND strProcessName='Blending') 
Insert Into tblMFManufacturingProcess(strProcessName,strDescription,intAttributeTypeId,intCreatedUserId,intLastModifiedUserId)
Select 'Blending','Blending',2,1,1

--Add Attributes to Process 
Insert Into tblMFManufacturingProcessAttribute(intManufacturingProcessId,intAttributeId,intLocationId,strAttributeValue,intLastModifiedUserId)
Select (Select intManufacturingProcessId From tblMFManufacturingProcess Where intAttributeTypeId=2 AND strProcessName='Blending'),at.intAttributeId,cl.intCompanyLocationId,
Case When at.strSQL like '%False%' Then 'False' Else '' End,1
From tblSMCompanyLocation cl cross join (Select * From tblMFAttribute Where intAttributeTypeId=2) at
Where Convert(varchar(100),cl.intCompanyLocationId) + Convert(varchar(100),at.intAttributeId) not in 
(Select Convert(varchar(100),intLocationId) + Convert(varchar(100),intAttributeId) From tblMFManufacturingProcessAttribute 
Where intManufacturingProcessId = (Select intManufacturingProcessId From tblMFManufacturingProcess Where intAttributeTypeId=2 AND strProcessName='Blending'))