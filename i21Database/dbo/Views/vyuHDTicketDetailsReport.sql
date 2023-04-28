﻿CREATE VIEW [dbo].[vyuHDTicketDetailsReport]
	AS
			select
			strCustomerNumber
			,strCustomerName
			,strContactName
			,intTicketId
			,strTicketNumber
			,strCommentBy
			,strCommentByLocation
			,dtmCommentDate
			,strComment = REPLACE(strComment,'./Export/CRM/', ((select top 1 isnull(stri21Link, '.') from tblHDSetting) + '/Export/CRM/'))
			,intTicketCommentId
			,strDraft
		from
		(
	    select
			ltrim(rtrim(entity.strEntityNo)) strCustomerNumber
			,ltrim(rtrim(entity.strName)) strCustomerName
			,ltrim(rtrim(entityContact.strName)) strContactName
			,t.intTicketId
			,t.strTicketNumber
			,v.strCreatedFullName strCommentBy --+ (case u.strCustomer when 'i21 User' then ' (Agent)' else ' (User)' end) strCommentBy
			,v.strCreatedLocation strCommentByLocation
			,DATENAME(DW, tc.dtmCreated)+', '+CONVERT(VARCHAR(20), tc.dtmCreated, 100) COLLATE Latin1_General_CI_AS dtmCommentDate
			,'<div style="font-family:Segoe UI;font-size:14px;">' + (case when tc.ysnEncoded = 1 and SUBSTRING(tc.strComment,1,3) = '1AE' then dbo.fnHDDecodeComment(substring(tc.strComment,4,len(tc.strComment)-3)) else tc.strComment end) + '</div>' strComment
			,tc.intTicketCommentId
			,(case tc.ysnSent when 1 then 'Sent' else 'Draft' end) COLLATE Latin1_General_CI_AS strDraft
        from
			tblHDTicket t
			inner join tblHDTicketComment tc on tc.intTicketId = t.intTicketId
			left outer join tblEMEntity entity on entity.intEntityId = t.intCustomerId
			left outer join tblEMEntity entityContact on entityContact.intEntityId = t.intCustomerContactId
			--left outer join vyuHDUserDetail u on u.intEntityId = tc.intCreatedUserEntityId
			inner join vyuHDTicketCommentLink v on v.intTicketCommentId = tc.intTicketCommentId
		) as result
GO
