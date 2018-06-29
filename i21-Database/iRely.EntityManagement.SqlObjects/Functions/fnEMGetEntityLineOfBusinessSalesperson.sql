CREATE FUNCTION [dbo].[fnEMGetEntityLineOfBusinessSalesperson]
(
	@intEntityId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	
	
	DECLARE @uniqueId TABLE(
		id int
	)
	
	insert into @uniqueId (id) 
	select distinct c.intEntityId
		from tblEMEntityLineOfBusiness a			
			join tblEMEntity b
				on a.intEntityId = b.intEntityId
			JOIN [tblEMEntity] c
				on c.intEntityId = a.intEntitySalespersonId
	where a.intEntityId = @intEntityId

	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(strName)) 
		from tblEMEntity where intEntityId in ( select id from @uniqueId )

	RETURN @col
END