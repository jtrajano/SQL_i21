﻿CREATE VIEW [dbo].[vyuICGetCompanyPreference]
AS

SELECT 
	ic.* 
	-- Get the company preference from the other modules that is related with IC. 
	,ysnImposeReversalTransaction = CAST(0 AS BIT) --rk.ysnImposeReversalTransaction
FROM 
	tblICCompanyPreference ic
	OUTER APPLY (
		SELECT TOP 1 
			rk.*
		FROM 
			tblRKCompanyPreference rk
	) rk 