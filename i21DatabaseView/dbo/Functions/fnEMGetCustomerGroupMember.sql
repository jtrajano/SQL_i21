CREATE FUNCTION [dbo].[fnEMGetCustomerGroupMember]
(
	@intCustomerGroupId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(strName)) from 
			tblARCustomerGroupDetail b				
			join tblEMEntity c
				on c.intEntityId = b.intEntityId
			where b.intCustomerGroupId = @intCustomerGroupId
	RETURN @col
END
