CREATE VIEW [dbo].[vyuHDTicketWatcher]
	AS
		select w.intTicketWatcherId, w.intTicketId, w.strTicketNumber, w.intUserId, w.intUserEntityId, w.intConcurrencyId, wc.strName, wc.strRoleName
		from
			tblHDTicketWatcher w,
			(
				select intEntityId, strName, strRoleName = isnull(strRoleName, '<font color="red"><i>No i21 access</i></font>') from
				(
					select a.intEntityId, strName = a.strName, strRoleName = (select top 1 c.strName from tblSMUserRole c where c.intUserRoleID = b.intUserRoleID)
					from tblEMEntity a, tblSMUserSecurity b
					where
					b.intEntityId = a.intEntityId
					union all
					select a.intEntityId, strName = a.strName, strRoleName = (select top 1 c.strName from tblSMUserRole c where c.intUserRoleID = d.intEntityRoleId)
					from tblEMEntityToContact d, tblEMEntity a
					where
					a.intEntityId = d.intEntityContactId
				) as role
			) as wc
		where wc.intEntityId = w.intUserEntityId
