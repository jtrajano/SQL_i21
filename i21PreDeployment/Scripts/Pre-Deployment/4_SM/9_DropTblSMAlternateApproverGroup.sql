
PRINT 'BEGIN Drop of table tblSMAlternateApproverGroup.'
PRINT 'The table tblSMAlternateApproverGroup is going to be re-created as tblSMApproverGroup'
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSMAlternateApproverGroup]'))
	DROP TABLE [dbo].[tblSMAlternateApproverGroup]
GO
PRINT 'END Drop of table tblSMAlternateApproverGroup'