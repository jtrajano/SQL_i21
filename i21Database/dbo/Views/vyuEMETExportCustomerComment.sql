CREATE VIEW [dbo].[vyuEMETExportCustomerComment]
	AS 
	select 
		cust_id  = b.strEntityNo,
		comment_type = 'ETC',
		line_no = Right('0000' + cast(c.RecordKey as nvarchar), 4),
		comment = cast(c.Record as nvarchar(80))
	 from tblEMEntityMessage a
	join tblEMEntity b
		on a.intEntityId = b.intEntityId and a.strMessageType = 'Energy Trac'
	join vyuEMEntityType bb
		on b.intEntityId = bb.intEntityId and bb.Customer = 1
	CROSS APPLY dbo.fnCFSplitString(a.strMessage, char(10)) c