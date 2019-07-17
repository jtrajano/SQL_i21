CREATE VIEW [dbo].[vyuCTBookItem]
	AS 


select 
	intId = CAST(ROW_NUMBER() OVER (ORDER BY c.intBookId, c.intItemId) AS INT), 
	c.intBookId,
	c.strBook,
	c.strBookDescription,
	c.ysnActive,
	c.intItemId,
	c.intBundleId
from 
(

select 
		a.intBookId, 
		a.strBook, 
		a.strBookDescription, 
		a.ysnActive,
		-99 as intItemId,
		-99 as intBundleId
	from tblCTBook as a

union all
select 
		a.intBookId, 
		a.strBook, 
		a.strBookDescription, 
		a.ysnActive,
		b.intItemId,
		-99 as intBundleId
	from tblCTBook as a
	join tblICItemBook b
		on a.intBookId = b.intBookId

union all

select 
		a.intBookId, 
		a.strBook, 
		a.strBookDescription, 
		a.ysnActive,
		b.intItemId,
		d.intItemId as intBundleId
	from tblCTBook as a
	join tblICItemBook b
		on a.intBookId = b.intBookId	
	JOIN vyuICGetBundleItem	d
		ON	d.intBundleItemId =	b.intItemId
	
) c