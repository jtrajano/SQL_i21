﻿CREATE VIEW [dbo].[vyuMFCustomTrialBlendSheet]
AS 
/****************************************************************
	Title: Custom Trial Blend Sheet
	Description: Custom Report Intended for Ekaterra Unilever
	JIRA: MFG-4572
	Created By: Jonathan Valenzuela
	Date: 10/26/2022
*****************************************************************/
SELECT WorkOrder.intWorkOrderId
	 , CompanyLocation.strLocationName				-- Plant
	 , WorkOrder.strReferenceNo						-- Order Nbr
	 , Item.strItemNo								-- Blend Code
	 , WorkOrder.dtmCreated							-- Date Created
	 , BlendRequirement.dblEstNoOfBlendSheet		-- Mixes
	 , WorkOrderInputLotQuantity.dblIssuedQuantity	-- Parts
	 , BlendRequirement.dblBlenderSize				-- Net Wt per mix
	 , WorkOrder.dblQuantity						-- Total Blend Wt
FROM tblMFWorkOrder AS WorkOrder
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON WorkOrder.intLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblICItem AS Item ON WorkOrder.intItemId = Item.intItemId
LEFT JOIN tblMFBlendRequirement AS BlendRequirement ON WorkOrder.intBlendRequirementId = BlendRequirement.intBlendRequirementId
LEFT JOIN tblMFWorkOrderInputLot AS WorkOrderInputLot ON WorkOrder.intWorkOrderId = WorkOrderInputLot.intWorkOrderId
OUTER APPLY (SELECT SUM(dblIssuedQuantity) AS dblIssuedQuantity
			 FROM tblMFWorkOrderInputLot
			 WHERE intWorkOrderId = WorkOrder.intWorkOrderId) AS WorkOrderInputLotQuantity