GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'PurchaseContract')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('PurchaseContract'
           ,''
           ,1
           ,'Contract Management'
           ,1
           ,1)           
END           
GO
GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'SaleContract')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('SaleContract'
           ,''
           ,1
           ,'Contract Management'
           ,1
           ,1)          
END           
GO
GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'DPContract')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('DPContract'
           ,''
           ,1
           ,'Contract Management'
           ,1
           ,1)
END           
GO