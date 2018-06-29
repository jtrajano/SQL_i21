
CREATE VIEW [dbo].[vyuCFSearchAccountVehicle]
AS

SELECT 
emEnt.strName AS strCustomerName
,arCust.strCustomerNumber as strCustomerNumber
,cfAccount.intCustomerId as intCustomerId
,cfVehicle.intVehicleId
,cfVehicle.intAccountId
,cfVehicle.strVehicleNumber
,cfVehicle.strCustomerUnitNumber
,cfVehicle.strVehicleDescription
,cfVehicle.strLicencePlateNumber
,cfVehicle.ysnCardForOwnUse
,cfVehicle.intExpenseItemId
,cfVehicle.ysnActive
,cfVehicle.intDaysBetweenService
,cfVehicle.intMilesBetweenService
,cfVehicle.intLastReminderOdometer
,cfVehicle.dtmLastReminderDate
,cfVehicle.dtmLastServiceDate
,cfVehicle.intLastServiceOdometer
,cfVehicle.strNoticeMessageLine1 as strNoticeMessageLine
,icItem.strItemNo as strItem
,icItem.strDescription as strItemDescription
,strDepartment =  cfDept.strDepartment
,cfVehicle.strComment
FROM   dbo.tblCFVehicle AS cfVehicle 
INNER JOIN dbo.tblCFAccount AS cfAccount ON cfAccount.intAccountId = cfVehicle.intAccountId 
INNER JOIN dbo.tblARCustomer AS arCust ON arCust.intEntityId = cfAccount.intCustomerId
INNER JOIN dbo.tblEMEntity AS emEnt ON emEnt.intEntityId = arCust.intEntityId
LEFT JOIN tblCFDepartment cfDept
	ON cfVehicle.intDepartmentId = cfDept.intDepartmentId
LEFT JOIN dbo.tblICItem AS icItem ON icItem.intItemId = cfVehicle.intExpenseItemId



