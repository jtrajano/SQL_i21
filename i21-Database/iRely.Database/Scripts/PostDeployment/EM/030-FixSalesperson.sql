PRINT '*** Start Fix Salesperson***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Fix Salesperson')
BEGIN
	PRINT '***Execute***'
		declare @SalesPersons table(
		intEntitiySalespersonId		int
	)

	insert into @SalesPersons
	select a.intEntityId from tblARSalesperson a
		join tblEMEntity b
			on a.[intEntityId] = b.intEntityId	
		where a.[intEntityId] not in (select intEntityId from tblEMEntityToContact)

	declare @Name nvarchar(100)
	declare @Email nvarchar(100)
	declare @Phone nvarchar(100)
	declare @Mobile nvarchar(100)

	declare @CurrentId int
	declare @EntityContactId int
	declare @EntityLocationId int

	declare @UsId int
	declare @DefaultContry int
	select @UsId = intCountryID from tblSMCountry where strCountry = 'United States'
	select top 1 @DefaultContry = isnull(intDefaultCountryId, @UsId) from tblSMCompanyPreference
	while exists(select top 1 1 from @SalesPersons)
	begin
		select top 1 @CurrentId = intEntitiySalespersonId from @SalesPersons
	 
		select top 1 
			@Name = strName, 
			@Phone = strPhone, 
			@Email = strEmail, 
			@Mobile = strMobile 
		from tblEMEntity where intEntityId = @CurrentId



		insert into tblEMEntity( strName, strContactNumber, strEmail)
		values(@Name, '', @Email)

		set @EntityContactId = @@IDENTITY
	
		insert into tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
		values (@EntityContactId, @Phone, @DefaultContry)


		insert into tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)
		values (@EntityContactId, @Mobile, @DefaultContry)

		insert into tblEMEntityToContact(intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
		values(@CurrentId, @EntityContactId, 1, 0)

		insert into tblEMEntityLocation(intEntityId, strLocationName, ysnDefaultLocation)
		values(@CurrentId, @Name, 1)

		delete from @SalesPersons where intEntitiySalespersonId = @CurrentId
	end


	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Fix Salesperson', 1)
END
PRINT '*** End Fix Salesperson***'
