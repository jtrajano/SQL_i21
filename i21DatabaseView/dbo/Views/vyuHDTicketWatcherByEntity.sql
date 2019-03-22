CREATE VIEW [dbo].[vyuHDTicketWatcherByEntity]
	AS
		select
			intTicketWatcherId
			,intTicketId
			,strTicketNumber
			,intUserId
			,intUserEntityId
			,intConcurrencyId
			,ysnContact = (case when intEntityContactId is null then convert(bit,0) else convert(bit,1) end)
		from
		(
			select
				a.intTicketWatcherId
				,a.intTicketId
				,a.strTicketNumber
				,a.intUserId
				,a.intUserEntityId
				,a.intConcurrencyId
				,b.intEntityContactId
			from
				tblHDTicketWatcher a
				left join
					tblEMEntityToContact b
				on
					b.intEntityContactId = a.intUserEntityId
		) as result
