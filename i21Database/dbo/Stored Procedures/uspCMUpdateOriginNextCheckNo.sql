-- Create a i21-only compliant stored procedure. 
-- There is another stored procedure of the same name in the Integration project. 
-- If there is no integration, this stored procedure will be used. 
-- Otherwise, the stored procedure in the integration will be used.
 
CREATE PROCEDURE uspCMUpdateOriginNextCheckNo
	@strNextCheckNumber NVARCHAR(20)
	,@intBankAccountId INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
-- This is intentionally a blank stored procedure. 
-- Look for its equivalent in the integration project. 