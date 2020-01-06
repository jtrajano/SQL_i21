print 'Start updating Sites empty Fill Method to Will Call';
go

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSite]') AND type in (N'U')) 
begin
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMFillMethod]') AND type in (N'U')) 
	begin

		if exists (SELECT * FROM sys.indexes  WHERE name='IX_tblTMSite_intFillMethodId' AND object_id = OBJECT_ID('[dbo].[tblTMSite]'))
		begin
			exec('drop index tblTMSite.IX_tblTMSite_intFillMethodId');
		end

		exec('
			update a
			set
				a.intFillMethodId = (
										select
											top 1 b.intFillMethodId
										from
											tblTMFillMethod b
										where
											b.strFillMethod = ''Will Call''
									)
			from
				tblTMSite a
			where
				a.intFillMethodId is null
				or a.intFillMethodId not in (
											 select
												b.intFillMethodId
											from
												tblTMFillMethod b
										 )
		');
	end
end
go

print 'End updating Sites empty Fill Method to Will Call';
go