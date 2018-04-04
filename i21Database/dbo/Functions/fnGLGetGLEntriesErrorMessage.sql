-- =============================================
-- Author:		Trajano, Jeffrey
-- Create date: 3-14-2018
-- Description:	Error Messages for Posting
-- =============================================

CREATE FUNCTION [dbo].[fnGLGetGLEntriesErrorMessage] ()
	RETURNS @tbl TABLE (
		intErrorCode INT, 
		strMessage NVARCHAR(150) COLLATE Latin1_General_CI_AS
	)
AS
BEGIN
	INSERT INTO @tbl 
	-- Add the SELECT statement with parameter references here
	SELECT 60001 ,'Invalid G/L account id found.'  UNION ALL
	SELECT 60002 ,'Invalid G/L temporary table.'  UNION ALL
	SELECT 60003 ,'Debit and credit amounts are not balanced.'  UNION ALL
	SELECT 60004 ,'Unable to find an open fiscal year period to match the transaction date.'  UNION ALL
	SELECT 60005 ,'G/L entries are expected. Cannot continue because it is missing.'  UNION ALL
	SELECT 60006 ,'The transaction is already posted.'  UNION ALL
	SELECT 60007 ,'The transaction is already unposted.'  UNION ALL
	SELECT 60008 ,'You cannot {0} transactions you did not create. Please contact your local administrator.'  UNION ALL
	SELECT 60009 ,'Unable to find an open fiscal year period for {0} module to match the transaction date.'  UNION ALL
	SELECT 60010 ,'Unable to recalculate summary. General Ledger Detail has out of balance transactions.'  UNION ALL
	SELECT 60011 ,'Fiscal period for {0} is {1}'  UNION ALL
	SELECT 60012 ,'Fiscal period of reverse date for {0} is {1}'  UNION ALL
	SELECT 60013 ,'Foreign debit and credit amounts are not balanced.'  UNION ALL
	SELECT 60014 ,'{0} is linked to an Origin Account which is not allowed to be deleted.'  UNION ALL
	SELECT 60015 ,'Unable to post/unpost with an inactive account {0}' UNION ALL
	SELECT 60016 ,'Foreign Debit and credit amounts are not balanced.' 
	RETURN
END
