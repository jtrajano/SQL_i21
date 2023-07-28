--liquibase formatted sql

-- changeset Von:fnCRMCoalesceEntityType.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCRMCoalesceEntityType](@intEntityId int)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strEntityType nvarchar(max);
	SELECT
		@strEntityType = COALESCE(@strEntityType COLLATE Latin1_General_CI_AS + ', ', '') + tblEMEntityType.strType COLLATE Latin1_General_CI_AS
	FROM
		tblEMEntityType
	WHERE
		tblEMEntityType.intEntityId = @intEntityId

	return @strEntityType COLLATE Latin1_General_CI_AS

END



