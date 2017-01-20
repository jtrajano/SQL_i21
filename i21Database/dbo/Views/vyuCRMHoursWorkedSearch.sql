CREATE VIEW [dbo].[vyuCRMHoursWorkedSearch]
	AS
		select
			a.*
			,strAgentName = b.strName
			,strCreatedBy = c.strName
			,d.strItemNo
			,e.strInvoiceNumber
		from
			tblCRMHoursWorked a
			left join tblEMEntity b on b.intEntityId = a.intEntityId
			left join tblEMEntity c on c.intEntityId = a.intCreatedByEntityId
			left join tblICItem d on d.intItemId = a.intItemId
			left join tblARInvoice e on e.intInvoiceId = a.intInvoiceId
