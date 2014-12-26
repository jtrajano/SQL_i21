
GO
IF NOT EXISTS(SELECT * FROM [dbo].[tblSMStartingNumber] WHERE [strTransactionType] = 'Notes Receivable')
BEGIN
INSERT INTO [dbo].[tblSMStartingNumber]
           ([strTransactionType]
           ,[strPrefix]
           ,[intNumber]
           ,[strModule]
           ,[ysnEnable]
           ,[intConcurrencyId])
     VALUES
           ('Notes Receivable'
           ,'NR-'
           ,1
           ,'Notes Receivable'
           ,1
           ,1)
           
END           
GO
