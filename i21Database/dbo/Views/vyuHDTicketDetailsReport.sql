CREATE VIEW [dbo].[vyuHDTicketDetailsReport]
	AS
	    select
			ltrim(rtrim(entity.strEntityNo)) strCustomerNumber
			,ltrim(rtrim(entity.strName)) strCustomerName
			,ltrim(rtrim(entityContact.strName)) strContactName
			,t.intTicketId
			,t.strTicketNumber
			,u.strFullName + (case u.strCustomer when 'i21 User' then ' (Agent)' else ' (User)' end) strCommentBy
			,u.strLocation strCommentByLocation
			,DATENAME(DW, tc.dtmCreated)+', '+CONVERT(VARCHAR(20), tc.dtmCreated, 100) dtmCommentDate
			,'<div style="font-family:Segoe UI;font-size:14px;">' + (case when tc.ysnEncoded = 1 and SUBSTRING(tc.strComment,1,3) = '1AE' then dbo.fnHDDecodeComment(substring(tc.strComment,4,len(tc.strComment)-3)) else tc.strComment end) + '</div>' strComment
			,tc.intTicketCommentId
			,(case tc.ysnSent when 1 then 'Sent' else 'Draft' end) strDraft
        from
			tblHDTicket t
			inner join tblHDTicketComment tc on tc.intTicketId = t.intTicketId
			left outer join tblEMEntity entity on entity.intEntityId = t.intCustomerId
			left outer join tblEMEntity entityContact on entityContact.intEntityId = t.intCustomerContactId
			left outer join vyuHDUserDetail u on u.intEntityId = tc.intCreatedUserEntityId
