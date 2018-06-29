PRINT '*** Checking for duplicate location name***'
IF (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'strLocationName' and object_id = OBJECT_ID(N'tblEMEntityLocation')))
	AND (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intEntityId' and object_id = OBJECT_ID(N'tblEMEntityLocation')))
	AND  (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intEntityLocationId' and object_id = OBJECT_ID(N'tblEMEntityLocation')))
BEGIN

	EXEC('

		DECLARE @LocationTable Table(
			intEntityId int,
			strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
			intCount int
		)
		insert into @LocationTable
		select intEntityId, strLocationName, count(strLocationName) from tblEMEntityLocation group by intEntityId, strLocationName having(count(strLocationName)) > 1 order by strLocationName 


		IF EXISTS(SELECT TOP 1 1 FROM @LocationTable)
		BEGIN
			PRINT ''EXECUTE''

			UPDATE tblEMEntityLocation SET strLocationName = RTRIM(strLocationName) + '' '' + cast(intEntityLocationId as nvarchar)
			where cast(intEntityId as nvarchar) + ''.'' + strLocationName in (select cast(intEntityId as nvarchar) + ''.'' + strLocationName COLLATE Latin1_General_CI_AS from @LocationTable)
		END

	')



END

PRINT '*** Checking for duplicate location name***'

