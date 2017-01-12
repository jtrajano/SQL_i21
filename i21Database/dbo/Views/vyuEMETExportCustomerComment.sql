CREATE VIEW [dbo].[vyuEMETExportCustomerComment]
	AS 
	select 
		cust_id  = b.strEntityNo,
		comment_type = 'ETC',
		line_no = Right('0000' + cast(c.RecordKey as nvarchar), 4),
		comment = cast(c.Record as nvarchar(80)),
		iscust =  CASE WHEN (SELECT TOP 1 1 FROM tblEMEntityType where intEntityId = b.intEntityId and strType = 'Customer') = 1 THEN  1 ELSE 0 END
	 from tblEMEntityMessage a
	join tblEMEntity b
		on a.intEntityId = b.intEntityId and a.strMessageType = 'Energy Trac'
	CROSS APPLY dbo.fnCFSplitString(a.strMessage, char(10)) c