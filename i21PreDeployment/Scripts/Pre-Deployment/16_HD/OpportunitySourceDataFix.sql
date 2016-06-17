
GO
	PRINT N'Start fixing HD Opportunity Source existing data.'
GO

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblHDOpportunitySource')
	begin
		update tblHDOpportunitySource set tblHDOpportunitySource.strSource = tblHDOpportunitySource.strSource+'_'+convert(nvarchar(20),tblHDOpportunitySource.intOpportunitySourceId) where tblHDOpportunitySource.strSource in (
			select strSource from (
				select s1.strSource, cnt = count(s1.strSource) from tblHDOpportunitySource s1 group by s1.strSource
			) as f where cnt > 1
		)
	end

GO
	PRINT N'End fixing HD Opportunity Source existing data.'
GO