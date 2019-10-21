CREATE PROCEDURE [dbo].[uspSMApplyOriginMenusIcon]
AS
BEGIN
	UPDATE tblSMMasterMenu SET strIcon = 'small-menu-origins' 
	WHERE strType = 'Folder' AND strCommand <> '' AND strCommand NOT IN ('i21', 'FinancialReportDesigner', 'HelpDesk')
END