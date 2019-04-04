CREATE VIEW [dbo].[vyuHDTimeEntryTimeOffNotification]
	AS
		select
		intId = convert(int,ROW_NUMBER() over (order by b.intEntityId))
		,b.intEntityId
		,a.intTimeOffRequestId
		--,strFullName = ltrim(rtrim(isnull(b.strFirstName, ''))) + ' ' + ltrim(rtrim(isnull(b.strMiddleName,''))) + ' ' + ltrim(rtrim(isnull(b.strLastName,''))) COLLATE Latin1_General_CI_AS
		,strFullName = be.strName
		,a.dtmDateFrom
		,a.dtmDateTo
		,c.intTypeTimeOffId
		,c.strTimeOff
		,c.strDescription
		,dtmDateNow = getdate()
		,intDateNow = convert(int, convert(nvarchar(8), getDate(), 112))
		,strDateNowName = DATENAME(weekday,getdate()) COLLATE Latin1_General_CI_AS
		,intDateNowPart = DATEpart(weekday,getdate())
		,intEntityRecipientId = e.intEntityId
		,strRecipientFullName = ltrim(rtrim(e.strName))
		,strRecipientEmail = g.strEmail
		,ysnSent = isnull(h.ysnSent,convert(bit,0))
		,h.dtmDateSent
		from
		tblPRTimeOffRequest a
		join tblPREmployee b on b.intEntityId = a.intEntityEmployeeId and b.ysnActive = convert(bit,1)
		join tblEMEntity be on be.intEntityId = b.intEntityId
		join tblPRTypeTimeOff c on c.intTypeTimeOffId = a.intTypeTimeOffId
		left join tblHDTimeEntryResources d on d.intEntityId = a.intEntityEmployeeId
		left join tblEMEntity e on e.intEntityId = d.intResourcesEntityId
		left join tblEMEntityToContact f on f.intEntityId = e.intEntityId and f.ysnDefaultContact = convert(bit,1)
		left join tblEMEntity g on g.intEntityId = f.intEntityContactId
		left join tblHDTimeEntryTimeOffNotification h on h.intTimeOffRequestId = a.intTimeOffRequestId and convert(int, convert(nvarchar(8), h.dtmDateCreated, 112)) = convert(int, convert(nvarchar(8), getdate(), 112))
		where
		convert(int, convert(nvarchar(8), getdate(), 112)) >= convert(int, convert(nvarchar(8), a.dtmDateFrom, 112))
		and convert(int, convert(nvarchar(8), getdate(), 112)) <= convert(int, convert(nvarchar(8), a.dtmDateTo, 112))
		and DATEpart(weekday,getdate()) between 2 and 6
