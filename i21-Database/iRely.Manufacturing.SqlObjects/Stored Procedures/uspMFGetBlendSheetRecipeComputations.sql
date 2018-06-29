CREATE PROCEDURE [dbo].[uspMFGetBlendSheetRecipeComputations]
@intWorkOrderId int,
@intTypeId int
AS
SELECT rc.intWorkOrderRecipeComputationId,rc.intWorkOrderId,rc.intTestId,t.strTestName,
rc.intPropertyId,p.strPropertyName,rc.intMethodId,cm.strName AS strMethodName,
rc.dblComputedValue,rc.dblMinValue,rc.dblMaxValue
 From tblMFWorkOrderRecipeComputation rc 
Join tblQMProperty p on rc.intPropertyId=p.intPropertyId
Join tblQMTest t on rc.intTestId=t.intTestId
Join tblMFWorkOrderRecipeComputationMethod cm on rc.intMethodId=cm.intMethodId
Where intWorkOrderId=@intWorkOrderId And intTypeId=@intTypeId
