CREATE VIEW [dbo].[vyuHDProjectLink]
	AS
		with parentproject as (
			select intProjectId = a.intDetailProjectId, intParentProjectId = a.intProjectId, strParentProjectName = b.strProjectName from tblHDProjectDetail a, tblHDProject b where b.intProjectId = a.intProjectId
		)
		select
			a.*
			,strEntityName = b.strName
			,strContactName = c.strName
			,strTicketStatus = e.strStatus
			,strTicketType = g.strType
			,strInternalProjectManager = j.strName
			,strInternalSalesPerson = k.strName
			,strCustomerProjectManager = l.strName
			,strCustomerLeadershipSponsor = m.strName
			,strTargetVersion = n.strVersionNo
			,intTicketProductId = (select top 1 o.intProductId from tblARCustomerProductVersion o where o.intCustomerId = a.intCustomerId)
			,intParentProjectId = (select top 1 intParentProjectId from parentproject where intProjectId = a.intProjectId)
			,strParentProjectName = (select top 1 strParentProjectName from parentproject where intProjectId = a.intProjectId)
		from
			tblHDProject a
			left join tblEMEntity b on b.intEntityId = a.intCustomerId
			left join tblEMEntity c on c.intEntityId = a.intCustomerContactId
			left join tblHDTicketStatus e on e.intTicketStatusId = a.intTicketStatusId
			left join tblHDTicketType g on g.intTicketTypeId = a.intTicketTypeId
			left join tblEMEntity j on j.intEntityId = a.intInternalProjectManager
			left join tblEMEntity k on k.intEntityId = a.intInternalSalesPerson
			left join tblEMEntity l on l.intEntityId = a.intCustomerProjectManager
			left join tblEMEntity m on m.intEntityId = a.intCustomerLeadershipSponsor
			left join tblHDVersion n on n.intVersionId = a.intTargetVersionId