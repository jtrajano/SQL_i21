CREATE PROCEDURE  [dbo].[uspFRDTemplateAuditLog]  
	@intEntityId AS INT,  
	@successfulCount AS INT = 0 OUTPUT  
AS  
BEGIN  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
   	
	DECLARE @intId INT  
  							
------------------For Setup For 21.1 and Below  
		SET @intId = (SELECT MAX(intRowId) FROM tblFRRow)  	
		EXEC    dbo.uspSMAuditLog  
		@keyValue           = @intId,                          
		@screenName         = 'FinancialReportDesigner.view.RowDesigner',  
		@entityId           = @intEntityId,  
		@actionType         = 'Created',  
		@actionIcon         = 'small-new-plus',  
		@changeDescription  = '',  
		@fromValue          = '',  
		@toValue            = '',  
		@details            = ''     

		SET @intId = (SELECT MAX(intColumnId) FROM tblFRColumn)  
		EXEC    dbo.uspSMAuditLog  
		@keyValue           = @intId,                          
		@screenName         = 'FinancialReportDesigner.view.ColumnDesigner',  
		@entityId           = @intEntityId,  
		@actionType         = 'Created',  
		@actionIcon         = 'small-new-plus',  
		@changeDescription  = '',  
		@fromValue          = '',  
		@toValue            = '',  
		@details            = ''     

		SET @intId = (SELECT MAX(intReportId) FROM tblFRReport)  
		EXEC    dbo.uspSMAuditLog  
		@keyValue           = @intId,                          
		@screenName         = 'FinancialReportDesigner.view.ReportBuilder',  
		@entityId           = @intEntityId,  
		@actionType         = 'Created',  
		@actionIcon         = 'small-new-plus',  
		@changeDescription  = '',  
		@fromValue          = '',  
		@toValue            = '',  
		@details            = ''   

------------------For Setup For 21.2 and Higher
	--INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
	--		SELECT 1, '', 'Created', 'Created - Record: ' + CAST(@intReportId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
 
	--EXEC uspSMSingleAuditLog
	--	@screenName     = 'FinancialReportDesigner.view.ReportBuilder',
	--	@recordId       = @intReportId,
	--	@entityId       = @intEntityId,
	--	@AuditLogParam  = @SingleAuditLogParam        
	
	SELECT 1 
END  
