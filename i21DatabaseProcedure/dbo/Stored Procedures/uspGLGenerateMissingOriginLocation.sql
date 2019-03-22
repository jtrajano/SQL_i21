CREATE PROCEDURE [dbo].[uspGLGenerateMissingOriginLocation]
(@userName NVARCHAR(50))
AS
INSERT INTO glprcmst (glprc_sub_acct,glprc_desc,glprc_user_id,glprc_user_rev_dt,glprc_active_yn)
SELECT glact_acct9_16,glact_acct9_16,@userName,REPLACE(CONVERT(NVARCHAR(10), GETDATE(),102),'.',''),'Y' 
FROM glactmst WHERE glact_acct9_16 not in(SELECT glprc_sub_acct FROM glprcmst)
GROUP BY glact_acct9_16

