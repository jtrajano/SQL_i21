CREATE FUNCTION [dbo].[fnHDCoalesceEntityResources](@intEntityId int)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strEmails nvarchar(max);

	select
		@strEmails = coalesce(@strEmails + ',', '') +  b.strEmail COLLATE Latin1_General_CI_AS
	from
		tblHDTimeEntryResources a
	inner join tblEMEntity b on b.intEntityId = a.intResourcesEntityId
	where
		a.intEntityId = @intEntityId
		and b.strEmail is not null
		and ltrim(rtrim(b.strEmail)) <> ''

	return @strEmails COLLATE Latin1_General_CI_AS

END

GO