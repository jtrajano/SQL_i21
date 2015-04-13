
GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'Shipping Instructions')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('Shipping Instructions'
           ,'SI-'
           ,1
           ,'Logistics'
           ,1
           ,1)
END           
GO

GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'Allocations')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('Allocations'
           ,'AL-'
           ,1
           ,'Logistics'
           ,1
           ,1)
END           
GO

GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'Load Schedule')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('Load Schedule'
           ,'LS-'
           ,1
           ,'Logistics'
           ,1
           ,1)
END           
GO

GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'Generate Loads')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('Generate Loads'
           ,'GL-'
           ,1
           ,'Logistics'
           ,1
           ,1)
END           
GO
