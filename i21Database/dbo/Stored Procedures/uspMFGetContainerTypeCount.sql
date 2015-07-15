CREATE PROCEDURE uspMFGetContainerTypeCount(@intManufacturingProcessId int,@intLocationId int,@strContainerTypeName nvarchar(50)='%')
AS
BEGIN
	Declare @intAttributeId int,@strContainerType nvarchar(MAX)
	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Container Type'
	
	Select @strContainerType=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId
	
	SELECT Count(*) ContainerTypeCount
	FROM dbo.tblICContainerType CT
	Where CT.strDisplayMember IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@strContainerType, ',')
			)
	AND CT.strDisplayMember LIKE @strContainerTypeName+'%'
END
Go