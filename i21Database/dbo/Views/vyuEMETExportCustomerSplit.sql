CREATE VIEW [dbo].[vyuEMETExportCustomerSplit]
	AS 
	select 
		sploc = dd.strLocationNumber,
		splot = a.strSplitNumber,
		spcust = f.strEntityNo,
		spprct = e.dblSplitPercent,
		spcomt = a.strDescription


	from tblEMEntitySplit a
		join tblEMEntity b
			on a.intEntityId = b.intEntityId	
		join vyuEMEntityType c
			on a.intEntityId = c.intEntityId 
				and ( c.Customer = 1)
		join tblEMEntityLocation d
			on a.intEntityId = d.intEntityId and d.ysnDefaultLocation = 1
		join tblSMCompanyLocation dd
			on d.intWarehouseId = dd.intCompanyLocationId
		left join tblEMEntitySplitDetail e
			on a.intSplitId = e.intSplitId
		left join tblEMEntity f
			on e.intEntityId = f.intEntityId
	
	
