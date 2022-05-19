PRINT 'Import Vendor Location Scripts'
GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportVendorLocations')
	DROP PROCEDURE uspAPImportVendorLocations
GO


--IF  (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
EXEC(
'

CREATE PROCEDURE [dbo].[uspAPImportVendorLocations]
	@VendorId NVARCHAR(50) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @defaultCurrencyPref INT = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId > 0);

--IF(@Update = 0 AND @VendorId IS NULL)
BEGIN	
	
INSERT [dbo].[tblEMEntityLocation]    
([intEntityId], 
[strLocationName], 
[strAddress], 
[strCity], 
[strCountry], 
[strState], 
[strZipCode], 
[strNotes],  
[intShipViaId], 
[intTermsId], 
[intWarehouseId], 
[ysnDefaultLocation])


SELECT 
	ENT.intEntityId, 
	CAST (RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
				 ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name))) + '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
				 END,'''')) + ''_'' + CAST(A4GLIdentity AS NVARCHAR(100)) as NVARCHAR(50)),
	dbo.fnTrim(ISNULL(ssvnd_addr_1,'')) + CHAR(10) + dbo.fnTrim(ISNULL(ssvnd_addr_2,'')),
	ssvnd_city,
	''United States'' as [strCountry],
	ssvnd_st,
	dbo.fnTrim(ssvnd_zip),
	NULL,
	NULL,
	ISNULL(CASE WHEN ssvnd_terms_disc_pct = 0 AND ssvnd_terms_due_day = 0 AND ssvnd_terms_disc_day = 0 AND ssvnd_terms_cutoff_day = 0 THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'')
		 WHEN ssvnd_terms_type = ''D'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE dblDiscountEP = ssvnd_terms_disc_pct AND intBalanceDue = ssvnd_terms_due_day AND intDiscountDay = ssvnd_terms_disc_day)
		 WHEN ssvnd_terms_type = ''P'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE intBalanceDue = ssvnd_terms_due_day
																				      AND intDiscountDay = ssvnd_terms_disc_day
				                                                                      AND intDayofMonthDue = ssvnd_terms_cutoff_day)
		ELSE (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'') END, 
		(SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'') ) AS [intTermsId],
	NULL AS [intWarehouseId],
	0 AS [ysnDefaultLocation]
from ssvndmst  
inner join tblEMEntity ENT on ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
where   ssvnd_pay_to is not null and ssvnd_vnd_no <> ssvnd_pay_to AND ETYP.strType = ''Vendor''

and (
RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
   ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
+ '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
END,'''')) + ''_'' + CAST(A4GLIdentity AS NVARCHAR) not in (select strLocationName COLLATE Latin1_General_CI_AS  from tblEMEntityLocation ))
	
SET @Total = @@ROWCOUNT

END

')
END
