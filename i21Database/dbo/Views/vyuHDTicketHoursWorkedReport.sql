﻿CREATE VIEW [dbo].[vyuHDTicketHoursWorkedReport]
	AS
	    select distinct
			strCustomerNumber = ltrim(rtrim(entity.strEntityNo))
			,strCustomerName = ltrim(rtrim(entity.strName))
			,strContactName = ltrim(rtrim(entityContact.strName))
			,a.intTicketId
			,strTicketNumber = a.strTicketNumber
			,strAgent = ltrim(rtrim(entityCreator.strName))
			,intHours = b.intHours
			,dblHours = b.intHours
			,b.dblEstimatedHours
			,dtmDateCreated = b.dtmDate
			,strJobCode = c.strItemNo
			,ysnBillable = b.ysnBillable
			,bdlRate = b.dblRate
			,dblRate = b.dblRate
			,strDescription = b.strDescription
			,ysnExported = b.ysnBilled
			,strInvoiceNo = d.strInvoiceNumber
			,dtmDateExported = b.dtmBilled
			,b.intTicketHoursWorkedId
			,strServiceType = ''
        from
			tblHDTicket a
			inner join tblHDTicketHoursWorked b on b.intTicketId = a.intTicketId
			--left outer join tblHDJobCode c on c.intJobCodeId = b.intJobCodeId
			left outer join tblICItem c on c.intItemId = b.intItemId
			left outer join tblARInvoice d on d.intInvoiceId = b.intInvoiceId
			left outer join tblEMEntity entity on entity.intEntityId = a.intCustomerId
			left outer join tblEMEntity entityContact on entityContact.intEntityId = a.intCustomerContactId
			left outer join tblEMEntity entityCreator on entityCreator.intEntityId = b.intAgentEntityId
			left outer join tblEMEntityType typ on typ.intEntityId = b.intCreatedUserEntityId
