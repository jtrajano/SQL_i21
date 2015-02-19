-- Create a integration compliant stored procedure. 
-- There is another stored procedure of the same name in the i21Database project. 
-- If there is an integration with the origin system, this stored procedure will be used. 
-- Otherwise, the stored procedure in the i21Database will be used. 


CREATE PROCEDURE uspCMUpdateOriginNextCheckNo
	@strNextCheckNumber NVARCHAR(20)
	,@intBankAccountId INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
  
UPDATE	dbo.apcbkmst_origin
SET		apcbk_next_chk_no = CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber) AS INT) + 1
FROM	dbo.apcbkmst_origin O INNER JOIN dbo.tblCMBankAccount f
			ON f.strCbkNo = O.apcbk_no COLLATE Latin1_General_CI_AS
WHERE	f.intBankAccountId = @intBankAccountId
		AND ISNULL(@strNextCheckNumber, '') <> ''
		AND O.apcbk_next_chk_no <= CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber) AS INT)  