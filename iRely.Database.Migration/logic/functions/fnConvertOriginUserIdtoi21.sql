--liquibase formatted sql

-- changeset Von:fnConvertOriginUserIdtoi21.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

-- This function retrieves the user id from Origin and tries to get its equivalent in i21. 
CREATE OR ALTER FUNCTION [dbo].[fnConvertOriginUserIdtoi21](@user_id AS NVARCHAR(MAX))
RETURNS INT
AS
BEGIN 

DECLARE @intUserId AS INT 

SELECT TOP 1 
		@intUserId = [intEntityId]
FROM	tblSMUserSecurity
WHERE	strUserName = LTRIM(RTRIM(@user_id)) 

RETURN @intUserId
		
END



