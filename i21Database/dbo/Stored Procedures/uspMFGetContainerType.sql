CREATE PROCEDURE uspMFGetContainerType(@intManufacturingProcessId int,@intLocationId int)
AS
BEGIN
	Declare @intAttributeId int,@strContainerType nvarchar(MAX)
	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Container Type'
	
	Select @strContainerType=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId
	
	SELECT intContainerTypeId
		,strDisplayMember
		,ysnDefault
	FROM dbo.tblICContainerType CT
	Where CT.strDisplayMember IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@strContainerType, ',')
			)
	ORDER BY strDisplayMember
END
Go