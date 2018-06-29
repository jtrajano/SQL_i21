
PRINT 'BEGIN Drop of table tblSMApproverConfigurationForTransaction.'
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSMApproverConfigurationForTransaction]'))
	DROP TABLE [dbo].[tblSMApproverConfigurationForTransaction]
GO
PRINT 'END Drop of table tblSMApproverConfigurationForTransaction'