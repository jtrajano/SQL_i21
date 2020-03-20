print 'START DELETE DUPLICATE ENTITY PHONE NUMBER'

EXEC(
'with cte as
(
	select ROW_NUMBER() over(partition by intEntityId order by intEntityId) as [pk], intEntityId, strPhone
	from tblEMEntityPhoneNumber
) 
delete cte where [pk] > 1 and ISNULL([strPhone], '''') = ''''

'
)

print 'END DELETE DUPLICATE ENTITY PHONE NUMBER'