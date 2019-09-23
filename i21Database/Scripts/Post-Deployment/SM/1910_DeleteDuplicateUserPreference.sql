print 'START DELETE DUPLICATE USER PREFERENCE'

EXEC(
'with cte as
(
	select ROW_NUMBER() over(partition by intEntityUserSecurityId order by intEntityUserSecurityId) as [pk], intEntityUserSecurityId
	from tblSMUserPreference 
) 
delete cte where [pk] > 1

'
)
print 'END DELETE DUPLICATE USER PREFERENCE'