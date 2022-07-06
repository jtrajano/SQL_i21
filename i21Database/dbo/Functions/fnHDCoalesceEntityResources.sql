CREATE FUNCTION [dbo].[fnHDCoalesceEntityResources](@intEntityId int)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strEmails nvarchar(max);

	select
		@strEmails = coalesce(@strEmails + ',', '') +  b.strEmail
	from
		tblHDTimeEntryResources a
	inner join tblEMEntity b on b.intEntityId = a.intResourcesEntityId
	where
		a.intEntityId = @intEntityId
		and b.strEmail is not null
		and ltrim(rtrim(b.strEmail)) <> ''

	return @strEmails

END