--IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntityContacts]') AND type in (N'U')) 
--BEGIN	
	
--	DECLARE @intEntityId as int
--	DECLARE @intContactId as int
--	DECLARE @intEntityToContactId as int
--	DECLARE @intDefaultContactId as int
--	DECLARE @strDefaultContactName as nvarchar(50)
--	DECLARE @strContactName as nvarchar(50)
--	--Declare temporary table for table tblEntityContacts
--	DECLARE @tempEntityContacts table (
--		intEntityId int,
--		strName nvarchar(50),
--		strTitle nvarchar(max),
--		strDepartment nvarchar(max),
--		strMobile nvarchar(max),
--		strPhone nvarchar(max),
--		strEmail nvarchar(max),
--		strPhone2 nvarchar(max),
--		strEmail2 nvarchar(max),
--		strFax nvarchar(max),
--		strNotes nvarchar(max),
--		intEntityContactId int	
--	)
	
--	--Insert data from tblEntities to temporary table
--	INSERT INTO @tempEntityContacts
--	select
--	A.intEntityId,
--	B.strName,
--	strTitle,
--	strDepartment,
--	strMobile,
--	strPhone,
--	B.strEmail,
--	strPhone2,
--	strEmail2,
--	strFax,
--	strNotes,
--	intEntityContactId
--	from 
--	tblEntity A
--	inner join tblEntityContacts B on A.intEntityId = B.intEntityId
	
	
--	WHILE EXISTS (SELECT TOP 1 1 FROM @tempEntityContacts)
--	BEGIN
	
--		--Get the name of the default contact person
--		set @strDefaultContactName = ''
--		select Top 1
--		@strDefaultContactName = A.strName
--		from 
--		@tempEntityContacts A
--		inner join tblAPVendor B on A.intEntityContactId = B.intDefaultContactId
		
--		--Get the current Contact Name and the Entity Id assoiciated with it		
--		select  TOP 1 
--		@strContactName = strName,
--		@intEntityId = intEntityId
--		from @tempEntityContacts

--		--Insert the Contact Person in tblEntity
--		INSERT INTO tblEntity 
--		(strName, strWebsite, strInternalNotes)
--		SELECT TOP 1
--		strName,
--		'',
--		''
--		FROM @tempEntityContacts
		
--		--Get the Id created on the insert above
--		set @intContactId = @@IDENTITY
		
--		--Insert other data to tblEntityContact
--		INSERT INTO tblEntityContact
--		(intEntityId,
--		strTitle,
--		strDepartment,
--		strMobile,
--		strPhone,
--		strEmail,
--		strPhone2,
--		strEmail2,
--		strFax,
--		strNotes)
--		SELECT TOP 1
--		intEntityId = @intContactId,
--		strTitle,
--		strDepartment,
--		strMobile,
--		strPhone,
--		strEmail,
--		strPhone2,
--		strEmail2,
--		strFax,
--		strNotes
--		FROM @tempEntityContacts
		
--		--Insert the associated contact to the entity
--		INSERT INTO tblEntityToContact
--		(intEntityId, intContactId)
--		VALUES
--		(@intEntityId, @intContactId)
		
--		--SET @intDefaultContactId = @@IDENTITY
		
	
--		--This is to update the intDefaultContactId of tblAPVendor
--		IF @strDefaultContactName != ''
--		BEGIN
--			--Get the default id from tblEntityToContact
--			SELECT 
--			@intDefaultContactId = B.intEntityToContactId 
--			FROM tblEntity A
--			INNER JOIN tblEntityToContact B ON A.intEntityId = B.intContactId
--			WHERE A.strName = @strDefaultContactName 
			
--			IF @intDefaultContactId IS NOT NULL
--			BEGIN
--				UPDATE tblAPVendor set intDefaultContactId = @intDefaultContactId WHERE intEntityId = @intEntityId
--			END
--		END
		
--		DELETE TOP (1) FROM @tempEntityContacts
--	END
	
--	--Drop the table once data were transfered
--	DROP TABLE tblEntityContacts
--END