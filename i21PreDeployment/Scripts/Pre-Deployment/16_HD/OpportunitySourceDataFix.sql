
GO
	PRINT N'Start fixing HD Opportunity Source existing data.'
GO

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblHDSalesPipeStatus')
	begin
		exec('
			if exists (select * from tblHDSalesPipeStatus where strOrder is null or ltrim(rtrim(strOrder)) = '''')
			begin
				update tblHDSalesPipeStatus set strOrder = convert(nvarchar(20),intSalesPipeStatusId);
			end
		')
	end

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblCRMSalesPipeStatus')
	begin
		exec('
			if exists (select * from tblCRMSalesPipeStatus where strOrder is null or ltrim(rtrim(strOrder)) = '''')
			begin
				update tblCRMSalesPipeStatus set strOrder = convert(nvarchar(20),intSalesPipeStatusId);
			end
		')
	end

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblHDOpportunitySource')
	begin
		exec('update tblHDOpportunitySource set tblHDOpportunitySource.strSource = tblHDOpportunitySource.strSource+''_''+convert(nvarchar(20),tblHDOpportunitySource.intOpportunitySourceId) where tblHDOpportunitySource.strSource in (
			select strSource from (
				select s1.strSource, cnt = count(s1.strSource) from tblHDOpportunitySource s1 group by s1.strSource
			) as f where cnt > 1
		)')
	end

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblHDModule')
	begin
		IF EXISTS(SELECT * FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblHDModule' AND COLUMN_NAME = 'intSMModuleId')
		begin
			exec('update tblHDModule set tblHDModule.intSMModuleId = 15 where tblHDModule.intSMModuleId = 92')
		end
	end

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblHDModule')
	begin
		IF EXISTS(SELECT * FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblHDModule' AND COLUMN_NAME = 'intSMModuleId')
		begin
			update tblHDModule set tblHDModule.intSMModuleId = 15 where tblHDModule.intSMModuleId = 92
		end
	end

GO
	PRINT N'End fixing HD Opportunity Source existing data.'
GO