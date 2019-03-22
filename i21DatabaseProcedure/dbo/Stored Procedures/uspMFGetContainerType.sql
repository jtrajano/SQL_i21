CREATE PROCEDURE uspMFGetContainerType(@intManufacturingProcessId int,@intLocationId int,@strContainerTypeName nvarchar(50)='%',@intContainerTypeId int=0)
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
	AND CT.strDisplayMember LIKE @strContainerTypeName+'%'
	AND CT.intContainerTypeId =(CASE WHEN @intContainerTypeId >0 THEN @intContainerTypeId ELSE CT.intContainerTypeId END)
	ORDER BY strDisplayMember
END
Go