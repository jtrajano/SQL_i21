print 'Fix Vendor Bad Data '
if not exists(select top 1 1 from tblEntityPreferences where strPreference = 'Fix Vendor Bad Data' and strValue = '1')
begin
	print 'Fix Vendor Bad Data Starting '
	exec('update b set b.ysnDefaultContact = 1
	from tblAPVendor a
		join tblEntityToContact b
			on a.intEntityVendorId = b.intEntityId 			
		where a.intDefaultContactId <> b.intEntityContactId 
			and a.intDefaultContactId is not null
			and (select count(intEntityId)  
				from tblEntityToContact 
					where intEntityId = a.intEntityVendorId 
						and ysnDefaultContact = 1
						group by intEntityId ) is null')
	EXEC(
		'INSERT INTO tblEntityPreferences ( strPreference, strValue)
			VALUES (''Fix Vendor Bad Data'',''1'') ')

	print 'Fix Vendor Bad Data Ending'
end 