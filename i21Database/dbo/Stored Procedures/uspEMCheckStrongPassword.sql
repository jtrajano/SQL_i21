CREATE PROCEDURE [dbo].[uspEMCheckStrongPassword]
	@userId int 
AS
	declare @securityPolicyId int
	declare @password nvarchar(max)
	declare @len int
	declare @count int

	set @count = 1


	select @password = dbo.fnAESDecryptASym(strPassword) + 'x' from tblEMEntityCredential where intEntityId = @userId


	select @len = len(@password) - 1 
	declare @errorList table(
		defin nvarchar(100)
	)

	--get the user name security policy
	--get the data of that security policy
	IF OBJECT_ID('tempdb..#tmpSecPol') IS NOT NULL
		EXEC('DROP TABLE #tmpSecPol')

	select top 1 * into #tmpSecPol from tblSMSecurityPolicy where intSecurityPolicyId in (select top 1 intSecurityPolicyId from tblSMUserSecurity where intEntityUserSecurityId = @userId)


	--check per character definition (if this is a numeric, special character, upper case, lower case)
	declare @character_table table(
		char_value char(1),
		is_numeric bit,
		is_lower bit,
		is_upper bit,
		is_symbol bit
	)
	declare @cur_char char(1)
	declare @is_num bit
	declare @is_lower bit
	declare @is_upper bit
	declare @is_symbol bit


	while @count <= @len
	begin

		set @cur_char = SUBSTRING(@password, @count, 1)
		
		set @is_num = 0
		set @is_lower = 0
		set @is_upper = 0
		set @is_symbol = 0

		if @cur_char like '%[^a-zA-Z0-9]%'
		begin 
			set @is_symbol = 1
		end
		else if ISNUMERIC(@cur_char) = 1
		begin
			set @is_num = 1
		end
		else
		begin
		
			if @cur_char = LOWER(@cur_char)
			begin			
				set @is_lower = 1
			end
			else
			begin
				set @is_upper = 1
			end
		end


		insert into @character_table	
		select @cur_char, @is_num, @is_lower, @is_upper, @is_symbol

		set @count = @count + 1

	end

	IF OBJECT_ID('tempdb..#tmpConsoChar') IS NOT NULL
		EXEC('DROP TABLE #tmpConsoChar')

	select 
	
		char_value,
		char_count = count(char_value)

		into #tmpConsoChar

		from @character_table 
			group by char_value

	if (select count(*) from @character_table) < (select top 1 intMinPasswordLen from #tmpSecPol)
	begin
		insert into @errorList
		select top 1 'The minimum length for this field is ' + cast(intMinPasswordLen as nvarchar) + '.' from #tmpSecPol
	end

	if (select count(*) from @character_table) > (select top 1 intMaxPasswordLen from #tmpSecPol)
	begin
		insert into @errorList
		select top 1  'The maximum length for this field is ' + cast(intMaxPasswordLen as nvarchar) + '.' from #tmpSecPol
	end

	if( select max(char_count) from #tmpConsoChar ) > (select top 1 intMaxRepeatedChar from #tmpSecPol)
	begin
		insert into @errorList
		select top 1   'The maximum length for repeated character is ' + cast(intMaxRepeatedChar as nvarchar) + '.' from #tmpSecPol
	end

	--if( select min(char_count) from #tmpConsoChar ) < (select top 1 intMaxRepeatedChar from #tmpSecPol)
	--begin
	--	insert into @errorList
	--	select 'Minimum repeated length'
	--end

	if( select (count(char_value )) from #tmpConsoChar ) < (select top 1 intMinUniqueChar from #tmpSecPol)
	begin
		insert into @errorList
		select top 1   'There should be at least ' +   cast(intMinUniqueChar as nvarchar) + ' unique character.' from #tmpSecPol
	end

	if( select count(char_value) from @character_table where is_lower = 1 ) < (select top 1 intMinLowerCaseChar from #tmpSecPol)
	begin
		insert into @errorList
		select top 1   'There should be at least ' +   cast(intMinLowerCaseChar as nvarchar) + ' lower case  character.' from #tmpSecPol
	end

	if( select count(char_value) from @character_table where is_upper = 1 ) < (select top 1 intMinUpperCaseChar from #tmpSecPol)
	begin
		insert into @errorList
		select top 1   'There should be at least ' +   cast(intMinUpperCaseChar as nvarchar) + ' upper case  character.' from #tmpSecPol
	end

	if( select count(char_value) from @character_table where is_numeric = 1 ) < (select top 1 intMinNumericChar from #tmpSecPol)
	begin
		insert into @errorList
		select top 1   'There should be at least ' +   cast(intMinNumericChar as nvarchar) + ' numeric character.' from #tmpSecPol
	end


	if( select count(char_value) from @character_table where is_symbol = 1 ) < (select top 1 intMinSpecialCharacter from #tmpSecPol)
	begin
		insert into @errorList
		select top 1   'There should be at least ' +   cast(intMinSpecialCharacter as nvarchar) + ' special character.' from #tmpSecPol
	end

	select * from @errorList






