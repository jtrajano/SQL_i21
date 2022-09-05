﻿CREATE FUNCTION [dbo].[fnCRMCoalesceLinesOfBusiness](@intEntityCustomerId int)
RETURNS nvarchar(max)
AS
BEGIN

	declare @strLinesOfBusiness nvarchar(max);
	select
		@strLinesOfBusiness = COALESCE(@strLinesOfBusiness COLLATE Latin1_General_CI_AS + ', ', '') + b.strLineOfBusiness COLLATE Latin1_General_CI_AS
	--from 
	--	tblEMEntityLineOfBusiness a, tblSMLineOfBusiness b
	--where
	--	a.intEntityId = @intEntityCustomerId
	--	and b.intLineOfBusinessId = a.intLineOfBusinessId

	from tblEMEntityLineOfBusiness a
	inner join tblSMLineOfBusiness b on b.intLineOfBusinessId = a.intLineOfBusinessId
	where
		a.intEntityId = @intEntityCustomerId

	RETURN @strLinesOfBusiness COLLATE Latin1_General_CI_AS

END