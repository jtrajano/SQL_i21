CREATE VIEW [dbo].[vyuSMLabels]
AS

SELECT DISTINCT strLabel FROM (  
	SELECT strLabel from tblSMScreenLabel 
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
    SELECT LTRIM(RTRIM(strReminder + ' ' + strType)) FROM tblSMReminderList
        UNION
	SELECT LTRIM(RTRIM(strReminder + ' ' + strType + 's')) FROM tblSMReminderList WHERE strReminder NOT IN ('i21')
		UNION
	SELECT DISTINCT LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(strMessage,'{0}', ''), '{1}',''), '{2}', ''))) FROM tblSMReminderList where strReminder NOT IN ('Email')
		UNION
    SELECT strControlName FROM tblSMControl
        UNION
	SELECT strActionType FROM vyuSMAuditLogPanel
		UNION
    SELECT strGridLayoutName FROM tblSMGridLayout where strGrid = 'grdSearch'
) Labels WHERE strLabel NOT IN   
	  (' ', '-', '$', '%', '% / $', '&nbsp', '(i21.ModuleMgr.Grain.isSCRemote) ? From Server', ')', '...', '+', '=', '0', '', '0.00', '00000000',   
	   '(!i21.ModuleMgr.SystemManager.getCompanyPreference(ysnLegacyIntegration) ? Terms Code', '(***) ****-****', '{     hidden', '{getFormTitle - {current.strItemNo',  
	   '{pgePreviewTitle', '{setCategoryLabel', '{setCustomerFieldLabel', '{setDescriptionMark', '{setShipToFieldLabel', '{title', ' a record', ' count' )

