
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


GO
IF NOT EXISTS (SELECT 1 FROM dbo.tblNRNoteTransType WHERE intNoteTransTypeId = 1)
INSERT INTO [dbo].[tblNRNoteTransType]
           ([intNoteTransTypeId]
           ,[strNoteTransTypeName]
           ,[intConcurrencyId])
     VALUES
           (1
           ,'Invoice'
           ,0)
GO
IF NOT EXISTS (SELECT 1 FROM dbo.tblNRNoteTransType WHERE intNoteTransTypeId = 2)
INSERT INTO [dbo].[tblNRNoteTransType]
           ([intNoteTransTypeId]
           ,[strNoteTransTypeName]
           ,[intConcurrencyId])
     VALUES
           (2
           ,'Fee'
           ,0)
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tblNRNoteTransType WHERE intNoteTransTypeId = 3)
INSERT INTO [dbo].[tblNRNoteTransType]
           ([intNoteTransTypeId]
           ,[strNoteTransTypeName]
           ,[intConcurrencyId])
     VALUES
           (3
           ,'Interest'
           ,0)
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tblNRNoteTransType WHERE intNoteTransTypeId = 4)
INSERT INTO [dbo].[tblNRNoteTransType]
           ([intNoteTransTypeId]
           ,[strNoteTransTypeName]
           ,[intConcurrencyId])
     VALUES
           (4
           ,'Payment'
           ,0)
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tblNRNoteTransType WHERE intNoteTransTypeId = 5)
INSERT INTO [dbo].[tblNRNoteTransType]
           ([intNoteTransTypeId]
           ,[strNoteTransTypeName]
           ,[intConcurrencyId])
     VALUES
           (5
           ,'Amount Drawn'
           ,0)
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tblNRNoteTransType WHERE intNoteTransTypeId = 6)
INSERT INTO [dbo].[tblNRNoteTransType]
           ([intNoteTransTypeId]
           ,[strNoteTransTypeName]
           ,[intConcurrencyId])
     VALUES
           (6
           ,'Payment Reversal'
           ,0)
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tblNRNoteTransType WHERE intNoteTransTypeId = 7)
INSERT INTO [dbo].[tblNRNoteTransType]
           ([intNoteTransTypeId]
           ,[strNoteTransTypeName]
           ,[intConcurrencyId])
     VALUES
           (7
           ,'Adjustment'
           ,0)
GO


