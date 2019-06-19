print 'Start filling up Name and Description for Entity User'


exec('declare @table table
(
 [intTransactionId] INT,
 [FullName] NVARCHAR(MAX) NULL,
 [UserName] NVARCHAR(MAX) NULL
)

INSERT INTO @table
select  
distinct
tblSMTransaction.intTransactionId,
tblSMUserSecurity.strUserName as ''Login Name'',
tblEMEntity.strName as ''User Name''
from tblSMAudit tblSMAudit
inner join tblSMLog tblSMLog on tblSMLog.intLogId = tblSMAudit.intLogId
inner join tblEMEntity B on B.intEntityId = tblSMLog.intEntityId
left join tblSMTransaction tblSMTransaction on tblSMTransaction.intTransactionId = tblSMLog.intTransactionId
inner join tblEMEntity on tblEMEntity.intEntityId = tblSMTransaction.intRecordId
inner join tblSMUserSecurity tblSMUserSecurity on tblSMUserSecurity.intEntityId = tblEMEntity.intEntityId
inner join tblSMScreen tblSMScreen on tblSMScreen.intScreenId = tblSMTransaction.intScreenId
where (tblSMScreen.strNamespace like ''%EntityManagement.view.Entity%'' ) and (ISNULL(tblSMTransaction.strName,'''') = '''' OR isnull(tblSMTransaction.strDescription,'''') = '''')


WHILE EXISTS(SELECT TOP 1 1 FROM @table)
	begin
		declare @intTransId INT = (SELECT TOP 1 intTransactionId from @table)
		declare @fullname NVARCHAR(MAX) = (SELECT TOP 1 FullName from @table)
		declare @username nvarchar(max) = (select top 1 UserName from @table)

		update tblSMTransaction set strName = @fullname, strDescription = @username where intTransactionId = @intTransId

		delete from @table where intTransactionId = @intTransId
		
	end')


print 'End filling up Name and Description for Entity User'