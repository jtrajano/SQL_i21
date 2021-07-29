﻿CREATE VIEW [dbo].[vyuSMLabels]
AS

SELECT DISTINCT strLabel FROM (
	SELECT strLabel from tblSMScreenLabel WHERE strLabel NOT IN 
		('-', '$', '%', '% / $', '&nbsp', '(i21.ModuleMgr.Grain.isSCRemote) ? From Server', ')', '...', '+', '=', '0', '', '0.00', '00000000', 
		 '(!i21.ModuleMgr.SystemManager.getCompanyPreference(ysnLegacyIntegration) ? Terms Code', '(***) ****-****', '{     hidden', '{getFormTitle - {current.strItemNo',
		 '{pgePreviewTitle', '{setCategoryLabel', '{setCustomerFieldLabel', '{setDescriptionMark', '{setShipToFieldLabel', '{title' )
		UNION
	SELECT strMenuName strLabel from tblSMMasterMenu
) Labels