﻿-- Create a integration compliant stored procedure. 
-- There is another stored procedure of the same name in the i21Database project. 
-- If there is an integration with the origin system, this stored procedure will be used. 
-- Otherwise, the stored procedure in the i21Database will be used. 

GO
IF	EXISTS(select top 1 1 from sys.procedures where name = 'uspCMUpdateOriginNextCheckNo')
	AND (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AP') = 1
	AND EXISTS (select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst_origin' )
BEGIN 
	DROP PROCEDURE uspCMUpdateOriginNextCheckNo


	EXEC ('
		CREATE PROCEDURE [dbo].[uspCMUpdateOriginNextCheckNo]
			@strNextCheckNumber NVARCHAR(20)
			,@intBankAccountId INT 
		AS

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF
  
		UPDATE	dbo.apcbkmst_origin
		SET		apcbk_next_chk_no = CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber,8) AS INT)
		FROM	dbo.apcbkmst_origin O INNER JOIN dbo.tblCMBankAccount f
					ON f.strCbkNo = O.apcbk_no COLLATE Latin1_General_CI_AS
		WHERE	f.intBankAccountId = @intBankAccountId
				AND ISNULL(@strNextCheckNumber, '''') <> ''''
				AND O.apcbk_next_chk_no <= CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber,8) AS INT)
	')

END