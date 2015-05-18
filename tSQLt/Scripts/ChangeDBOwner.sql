DECLARE @user varchar(50)

SELECT  @user = quotename(SL.Name)
FROM	master..sysdatabases SD inner join master..syslogins SL
		ON  SD.SID = SL.SID
WHERE	SD.Name = DB_NAME()

EXEC('exec sp_changedbowner ' + @user)
GO