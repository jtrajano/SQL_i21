CREATE FUNCTION [dbo].[fnEMGetEmployeeDepartment]
(
	@intEntityEmployeeId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(b.strDepartment)) 
		from tblPREmployeeDepartment a			
			join tblPRDepartment b
				on a.intDepartmentId = b.intDepartmentId
	where a.intEntityEmployeeId = @intEntityEmployeeId
	RETURN @col
END
