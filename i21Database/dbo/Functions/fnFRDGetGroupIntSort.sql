CREATE FUNCTION dbo.fnFRDGetGroupIntSort ( @Type VARCHAR(MAX),@intParentGroupId INT)    
RETURNS INT    
AS    
BEGIN    
DECLARE @intSort INT          
 set @intSort = ( select top 1 intSort from tblGLAccountGroup  where strAccountType = @Type and intParentGroupId = @intParentGroupId  and isnull(intSort,0) <> 0 group by intParentGroupId,intSort )  
 return @intSort  
END