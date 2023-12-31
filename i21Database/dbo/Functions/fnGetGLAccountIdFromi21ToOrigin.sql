﻿
CREATE FUNCTION fnGetGLAccountIdFromi21ToOrigin(@inti21AccountID AS INT)	
RETURNS CHAR(16) 
AS
BEGIN 

	DECLARE @charAccountID CHAR(16)

	SELECT	@charAccountID = CAST(strExternalId AS CHAR(16)) 
	FROM	dbo.tblGLCOACrossReference 
	WHERE	inti21Id = @inti21AccountID

	RETURN @charAccountID COLLATE SQL_Latin1_General_CP1_CS_AS
END