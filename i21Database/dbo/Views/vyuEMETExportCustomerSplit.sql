CREATE VIEW [dbo].[vyuEMETExportCustomerSplit]
	AS 
	select 
		sploc = d.strLocationName,
		splot = a.strSplitNumber,
		spcust = f.strEntityNo,
		spprct = e.dblSplitPercent,
		spcomt = a.strDescription,
		spiscust = CASE WHEN (SELECT TOP 1 1 FROM tblEMEntityType where intEntityId = f.intEntityId and strType = 'Customer') = 1 THEN  1 ELSE 0 END

	from tblEMEntitySplit a
		join tblEMEntity b
			on a.intEntityId = b.intEntityId	
		join vyuEMEntityType c
			on a.intEntityId = c.intEntityId 
				and ( c.Customer = 1 or c.Vendor = 1)
		join tblEMEntityLocation d
			on a.intEntityId = d.intEntityId and d.ysnDefaultLocation = 1
		left join tblEMEntitySplitDetail e
			on a.intSplitId = e.intSplitId
		left join tblEMEntity f
			on e.intEntityId = f.intEntityId
	
