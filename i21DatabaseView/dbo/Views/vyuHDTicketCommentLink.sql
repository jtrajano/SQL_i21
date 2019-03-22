﻿CREATE VIEW [dbo].[vyuHDTicketCommentLink]
	AS
	select
		a.*
		,strCreatedFullName = c.strName + (case when b.strLocation is null then ' (User)' else ' (Agent)' end)
		,strCreatedLocation = (case when b.strLocation is null then e.strLocationName else b.strLocation end)
		,imgCreatedPhoto = c.imgPhoto
		,strMessage = (case when a.dtmSent is null then 'Draft' else dbo.fnHDTicketCommentSentMessage(a.dtmSent, GETDATE()) end)  COLLATE Latin1_General_CI_AS
	from
		tblHDTicketComment a
		left join tblEMEntity c on c.intEntityId = a.intCreatedUserEntityId
		left join tblEMEntityToContact d on d.intEntityContactId = a.intCreatedUserEntityId
		left join tblEMEntityLocation e on e.intEntityLocationId = d.intEntityLocationId
		left join tblSMUserSecurity b on b.intEntityId = a.intCreatedUserEntityId
