CREATE VIEW [dbo].[vyuCTBookItem]
	AS 


select 
	intId = CAST(ROW_NUMBER() OVER (ORDER BY c.intBookId, c.intItemId) AS INT), 
	c.intBookId,
	c.strBook,
	c.strBookDescription,
	c.ysnActive,
	c.intItemId
from 
(

select 
		a.intBookId, 
		a.strBook, 
		a.strBookDescription, 
		a.ysnActive,
		-99 as intItemId
	from tblCTBook as a

union all
select 
		a.intBookId, 
		a.strBook, 
		a.strBookDescription, 
		a.ysnActive,
		b.intItemId
	from tblCTBook as a
	join tblICItemBook b
		on a.intBookId = b.intBookId

) c