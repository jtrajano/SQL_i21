CREATE VIEW [dbo].[vyuSMLabels]
AS

SELECT DISTINCT strLabel FROM (  
	SELECT strLabel from tblSMScreenLabel WHERE strLabel NOT IN   
	  ('-', '$', '%', '% / $', '&nbsp', '(i21.ModuleMgr.Grain.isSCRemote) ? From Server', ')', '...', '+', '=', '0', '', '0.00', '00000000',   
	   '(!i21.ModuleMgr.SystemManager.getCompanyPreference(ysnLegacyIntegration) ? Terms Code', '(***) ****-****', '{     hidden', '{getFormTitle - {current.strItemNo',  
	   '{pgePreviewTitle', '{setCategoryLabel', '{setCustomerFieldLabel', '{setDescriptionMark', '{setShipToFieldLabel', '{title' )  
		UNION  
	SELECT strMenuName strLabel from tblSMMasterMenu  
		UNION
	SELECT strScreenName FROM tblSMScreen
		UNION
	SELECT strModule FROM tblSMModule
		UNION
	SELECT strTabName FROM tblSMCustomTab
		UNION
	SELECT strControlName from tblSMCustomTabDetail
        UNION
    SELECT TRIM(strReminder + ' ' + strType) FROM tblSMReminderList
        UNION
    SELECT strControlName FROM tblSMControl
        UNION
    SELECT strGridLayoutName FROM tblSMGridLayout where strGrid = 'grdSearch'
) Labels WHERE ISNULL(strLabel, '') <> '' ORDER BY strLabel
