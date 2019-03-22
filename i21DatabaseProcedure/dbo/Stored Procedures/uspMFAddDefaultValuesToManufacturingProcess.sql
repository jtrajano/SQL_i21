CREATE PROCEDURE [dbo].[uspMFAddDefaultValuesToManufacturingProcess]
	@intManufacturingProcessId int 
AS
BEGIN
    SET NoCount ON

	Declare @intAttributeTypeId INT,
			@intUserId INT

	Select @intAttributeTypeId=intAttributeTypeId,@intUserId=intCreatedUserId 
	From tblMFManufacturingProcess Where intManufacturingProcessId=@intManufacturingProcessId

	Insert Into tblMFManufacturingProcessAttribute(intManufacturingProcessId,intAttributeId,strAttributeValue,intLocationId,
				intLastModifiedUserId,dtmLastModified,intConcurrencyId)
	Select @intManufacturingProcessId,dv.intAttributeId,dv.strAttributeDefaultValue,cl.intCompanyLocationId,
			@intUserId,GETDATE(),1	 
	From tblMFAttributeDefaultValue dv Cross Join tblSMCompanyLocation cl 
	Where cl.intCompanyLocationId not in (Select intLocationId From tblMFManufacturingProcessAttribute Where intManufacturingProcessId=@intManufacturingProcessId)
	And intAttributeTypeId=@intAttributeTypeId
END
