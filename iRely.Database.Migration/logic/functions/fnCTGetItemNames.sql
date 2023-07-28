--liquibase formatted sql

-- changeset Von:fnCTGetItemNames.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetItemNames]
	(@intInvPlngReportMasterID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strItemNames NVARCHAR(MAX)

	SET @strItemNames = ''

	SELECT @strItemNames = @strItemNames + I.strItemNo + ', '
	FROM tblCTInvPlngReportMaterial RM
	JOIN tblICItem I ON I.intItemId = RM.intItemId
	WHERE RM.intInvPlngReportMasterID = @intInvPlngReportMasterID
	
	IF LEN(@strItemNames) > 0
		SET @strItemNames = Left(@strItemNames, LEN(@strItemNames) - 1)

	RETURN @strItemNames
END



