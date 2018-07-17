print 'Fix Vendor Bad Data '
if not exists(select top 1 1 from [tblEMEntityPreferences] where strPreference = 'Fix Vendor Bad Data' and strValue = '1')
begin
	print 'Fix Vendor Bad Data Starting '
	exec('update b set b.ysnDefaultContact = 1
	from tblAPVendor a
		join tblEMEntityToContact b
			on a.intEntityId = b.intEntityId 			
		where a.intDefaultContactId <> b.intEntityContactId 
			and a.intDefaultContactId is not null
			and (select count(intEntityId)  
				from tblEMEntityToContact 
					where intEntityId = a.intEntityId 
						and ysnDefaultContact = 1
						group by intEntityId ) is null')
	EXEC(
		'INSERT INTO tblEMEntityPreferences ( strPreference, strValue)
			VALUES (''Fix Vendor Bad Data'',''1'') ')

	print 'Fix Vendor Bad Data Ending'
end 