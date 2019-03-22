CREATE FUNCTION [dbo].[fnEMGetEmployeeSupervisor]
(
	@intEntityEmployeeId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(b.strName)) 
		from tblPREmployeeSupervisor a			
			join tblEMEntity b
				on a.intSupervisorId = b.intEntityId
	where a.intEntityEmployeeId = @intEntityEmployeeId
	RETURN @col
END
