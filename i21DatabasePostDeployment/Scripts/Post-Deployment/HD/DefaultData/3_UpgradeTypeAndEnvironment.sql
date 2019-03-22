/*--------Default data for ticket upgrade types--------*/

if not exists (select * from tblHDUpgradeType where strType = 'Upgrade')
begin
	INSERT INTO [dbo].[tblHDUpgradeType]
			   ([strType]
			   ,[strDescription]
			   ,[intConcurrencyId])
		 VALUES
			   ('Upgrade'
			   ,'Upgrade'
			   ,1)
end

if not exists (select * from tblHDUpgradeType where strType = 'Conversion')
begin
	INSERT INTO [dbo].[tblHDUpgradeType]
			   ([strType]
			   ,[strDescription]
			   ,[intConcurrencyId])
		 VALUES
			   ('Conversion'
			   ,'Conversion'
			   ,1)
end


/*--------Default data for ticket upgrade environment--------*/

if not exists (select * from tblHDUpgradeEnvironment where strEnvironment = 'Production')
begin
	INSERT INTO [dbo].[tblHDUpgradeEnvironment]
			   ([strEnvironment]
			   ,[strDescription]
			   ,[intConcurrencyId])
		 VALUES
			   ('Production'
			   ,'Production Environment'
			   ,1)
end

if not exists (select * from tblHDUpgradeEnvironment where strEnvironment = 'Test')
begin
	INSERT INTO [dbo].[tblHDUpgradeEnvironment]
			   ([strEnvironment]
			   ,[strDescription]
			   ,[intConcurrencyId])
		 VALUES
			   ('Test'
			   ,'Test Environment'
			   ,1)
end