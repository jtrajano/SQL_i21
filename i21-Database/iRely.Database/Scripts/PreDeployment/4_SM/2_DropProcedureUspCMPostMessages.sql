
PRINT 'BEGIN Drop of procedure uspCMPostMessages.'
PRINT 'The SP uspCMPostMessages is going to be re-created as uspSMErrorMessages'
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCMPostMessages]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[uspCMPostMessages]
GO
PRINT 'END Drop of procedure uspCMPostMessages'