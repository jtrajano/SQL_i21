CREATE FUNCTION [dbo].[fnHDCoalesceEntityResources](@intEntityId int)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strEmails nvarchar(max);

	select
		@strEmails = coalesce(@strEmails + ',', '') +  b.strEmail
	from
		tblHDTimeEntryResources a
		,tblEMEntity b
	where
		a.intEntityId = @intEntityId
		and b.intEntityId = a.intResourcesEntityId
		and b.strEmail is not null
		and ltrim(rtrim(b.strEmail)) <> ''

	return @strEmails

END