﻿CREATE PROCEDURE [dbo].[uspMFGetBlendRequests]
	@intWorkOrderId int = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @intWorkOrderId = 0
	SELECT a.intBlendRequirementId
		 , a.strDemandNo
		 , a.intItemId
		 , b.strItemNo
		 , b.strDescription
		 , (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) AS dblQuantity
		 , c.intItemUOMId
		 , d.strUnitMeasure AS strUOM
		 , a.dtmDueDate
		 , a.intLocationId
		 , a.intManufacturingCellId AS intManufacturingCellId
		 , a.intMachineId
		 , a.dblBlenderSize
		 , g.dblStandardCost
		 , mc.strCellName
		 , r.intManufacturingProcessId
		 , CASE MONTH(GETDATE()) WHEN 1 THEN bg.dblJan 
								 WHEN 2 THEN bg.dblFeb 
								 WHEN 3 THEN bg.dblMar 
								 WHEN 4 THEN bg.dblApr 
								 WHEN 5 THEN bg.dblMay 
								 WHEN 6 THEN bg.dblJun 
								 WHEN 7 THEN bg.dblJul 
								 WHEN 8 THEN bg.dblAug 
								 WHEN 9 THEN bg.dblSep 
								 WHEN 10 THEN bg.dblOct 
								 WHEN 11 THEN bg.dblNov 
								 WHEN 12 THEN bg.dblDec 
		   END AS dblAffordabilityCost
		 , CompanyLocation.strLocationName AS strCompanyLocationName
		 , a.strReferenceNo AS strERPOrderNo
		 , ri.dblUpperTolerance
		 , ri.dblLowerTolerance
		 , (ri.dblCalculatedUpperTolerance * (a.dblQuantity / e.dblQuantity)) dblUpperToleranceQty
		 , (ri.dblCalculatedLowerTolerance * (a.dblQuantity / e.dblQuantity)) dblLowerToleranceQty 
	FROM tblMFBlendRequirement a 
	JOIN tblICItem b ON a.intItemId = b.intItemId 
	JOIN tblICItemUOM c ON b.intItemId = c.intItemId AND a.intUOMId=c.intUnitMeasureId 
	JOIN tblICUnitMeasure d ON c.intUnitMeasureId = d.intUnitMeasureId 
	LEFT JOIN tblMFRecipe e ON a.intItemId = e.intItemId AND a.intLocationId = e.intLocationId AND e.ysnActive=1 
	LEFT JOIN tblICItemLocation f ON b.intItemId = f.intItemId AND f.intLocationId=a.intLocationId
	LEFT JOIN tblICItemPricing g ON g.intItemId = b.intItemId AND g.intItemLocationId=f.intItemLocationId
	LEFT JOIN tblMFManufacturingCell mc ON a.intManufacturingCellId = mc.intManufacturingCellId
	LEFT JOIN tblMFRecipe r ON a.intItemId = r.intItemId AND a.intLocationId=r.intLocationId AND r.ysnActive=1
	LEFT JOIN tblMFRecipeItem ri ON r.intRecipeId =ri.intRecipeId and a.intItemId = ri.intItemId and intRecipeItemTypeId =2 
	LEFT JOIN tblMFBudget bg ON a.intItemId = bg.intItemId AND a.intLocationId = bg.intLocationId AND bg.intYear = YEAR(GETDATE()) AND bg.intBudgetTypeId = 2
	LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON a.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE a.intStatusId = 1

--Positive means WorkOrderId
IF @intWorkOrderId > 0
	SELECT a.intBlendRequirementId
		 , a.strDemandNo
		 , a.intItemId
		 , b.strItemNo
		 , b.strDescription
		 , CASE WHEN (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) <= 0 THEN 0 
				ELSE (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) 
		   END AS dblQuantity
		 , c.intItemUOMId
		 , d.strUnitMeasure AS strUOM
		 , a.dtmDueDate
		 , a.intLocationId
		 , a.intManufacturingCellId
		 , h.dblStandardCost
		 , f.intManufacturingProcessId
		 , CompanyLocation.strLocationName AS strCompanyLocationName
		 , ISNULL(NULLIF(f.strERPOrderNo, ''), a.strReferenceNo)	AS strERPOrderNo
		 , ISNULL(WorkOrderStatus.strName, 'Not Released')			AS strWorkOrderStatus
		 , ISNULL(f.dblUpperTolerance, ri.dblUpperTolerance)		AS dblUpperTolerance
		 , ISNULL(f.dblLowerTolerance, ri.dblLowerTolerance)		AS dblLowerTolerance
		 , ISNULL(f.dblCalculatedUpperTolerance, (ri.dblCalculatedUpperTolerance * (a.dblQuantity / e.dblQuantity))) AS dblCalculatedUpperTolerance
		 , ISNULL(f.dblCalculatedLowerTolerance, (ri.dblCalculatedLowerTolerance * (a.dblQuantity / e.dblQuantity))) AS dblCalculatedLowerTolerance 
		 , f.ysnOverrideRecipe
	FROM tblMFBlendRequirement a 
	JOIN tblICItem b ON a.intItemId = b.intItemId 
	JOIN tblICItemUOM c ON b.intItemId = c.intItemId AND a.intUOMId = c.intUnitMeasureId 
	JOIN tblICUnitMeasure d ON c.intUnitMeasureId = d.intUnitMeasureId 
	LEFT JOIN tblMFRecipe e ON a.intItemId = e.intItemId AND a.intLocationId = e.intLocationId AND e.ysnActive=1 
	LEFT JOIN tblMFRecipeItem ri ON e.intRecipeId =ri.intRecipeId and e.intItemId = ri.intItemId and ri.intRecipeItemTypeId =2 
	JOIN tblMFWorkOrder f ON a.intBlendRequirementId = f.intBlendRequirementId
	LEFT JOIN tblICItemLocation g ON b.intItemId = g.intItemId AND g.intLocationId = a.intLocationId
	LEFT JOIN tblICItemPricing h ON h.intItemId = b.intItemId AND g.intItemLocationId = h.intItemLocationId
	LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON a.intLocationId = CompanyLocation.intCompanyLocationId
	OUTER APPLY (SELECT WorkOrderStatus.strName
				 FROM tblMFWorkOrder AS WorkOrder
				 JOIN tblMFWorkOrderStatus AS WorkOrderStatus ON WorkOrder.intStatusId = WorkOrderStatus.intStatusId
				 WHERE WorkOrder.intBlendRequirementId = a.intBlendRequirementId) AS WorkOrderStatus
	WHERE f.intWorkOrderId = @intWorkOrderId
	GROUP BY a.intBlendRequirementId
		 , a.strDemandNo
		 , a.intItemId
		 , b.strItemNo
		 , b.strDescription
		 , CASE WHEN (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) <= 0 THEN 0 
				ELSE (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) 
		   END 
		 , c.intItemUOMId
		 , d.strUnitMeasure 
		 , a.dtmDueDate
		 , a.intLocationId
		 , a.intManufacturingCellId
		 , h.dblStandardCost
		 , f.intManufacturingProcessId
		 , CompanyLocation.strLocationName 
		 , ISNULL(NULLIF(f.strERPOrderNo, ''), a.strReferenceNo)	
		 , ISNULL(WorkOrderStatus.strName, 'Not Released')			
		 , ISNULL(f.dblUpperTolerance, ri.dblUpperTolerance)		
		 , ISNULL(f.dblLowerTolerance, ri.dblLowerTolerance)		
		 , ISNULL(f.dblCalculatedUpperTolerance, (ri.dblCalculatedUpperTolerance * (a.dblQuantity / e.dblQuantity)))
		 , ISNULL(f.dblCalculatedLowerTolerance, (ri.dblCalculatedLowerTolerance * (a.dblQuantity / e.dblQuantity))) 
		 , f.ysnOverrideRecipe


--Negative means BlendRequirementId
IF @intWorkOrderId < 0
	SELECT a.intBlendRequirementId
		 , a.strDemandNo
		 , a.intItemId
		 , b.strItemNo
		 , b.strDescription
		 , CASE WHEN (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) <= 0 THEN 0 
				ELSE (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) 
		   END AS dblQuantity
		 , c.intItemUOMId
		 , d.strUnitMeasure AS strUOM
		 , a.dtmDueDate
		 , a.intLocationId
		 , a.intManufacturingCellId
		 , h.dblStandardCost
		 , CompanyLocation.strLocationName	AS strCompanyLocationName
		 , a.strReferenceNo					AS strERPOrderNo
		 , ri.dblUpperTolerance				AS dblUpperTolerance
		 , ri.dblLowerTolerance				AS dblLowerTolerance
		 , (ri.dblCalculatedUpperTolerance * (a.dblQuantity / e.dblQuantity)) AS dblCalculatedUpperTolerance
		 , (ri.dblCalculatedLowerTolerance * (a.dblQuantity / e.dblQuantity)) AS dblCalculatedLowerTolerance 
	FROM tblMFBlendRequirement a 
	JOIN tblICItem b ON a.intItemId = b.intItemId 
	JOIN tblICItemUOM c ON b.intItemId = c.intItemId AND a.intUOMId=c.intUnitMeasureId 
	JOIN tblICUnitMeasure d ON c.intUnitMeasureId = d.intUnitMeasureId 
	LEFT JOIN tblMFRecipe e ON a.intItemId = e.intItemId AND a.intLocationId = e.intLocationId AND e.ysnActive=1 
	LEFT JOIN tblMFRecipeItem ri ON e.intRecipeId =ri.intRecipeId and e.intItemId = ri.intItemId and ri.intRecipeItemTypeId =2 
	LEFT JOIN tblICItemLocation g ON b.intItemId = g.intItemId AND g.intLocationId = a.intLocationId
	LEFT JOIN tblICItemPricing h ON h.intItemId = b.intItemId AND g.intItemLocationId = h.intItemLocationId
	LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON a.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE a.intBlendRequirementId = ABS(@intWorkOrderId)
	GROUP BY a.intBlendRequirementId
		 , a.strDemandNo
		 , a.intItemId
		 , b.strItemNo
		 , b.strDescription
		 , CASE WHEN (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) <= 0 THEN 0 
				ELSE (a.dblQuantity - ISNULL(a.dblIssuedQty, 0)) 
		   END 
		 , c.intItemUOMId
		 , d.strUnitMeasure 
		 , a.dtmDueDate
		 , a.intLocationId
		 , a.intManufacturingCellId
		 , h.dblStandardCost
		 , CompanyLocation.strLocationName	
		 , a.strReferenceNo					
		 , ri.dblUpperTolerance				
		 , ri.dblLowerTolerance				
		 , (ri.dblCalculatedUpperTolerance * (a.dblQuantity / e.dblQuantity)) 
		 , (ri.dblCalculatedLowerTolerance * (a.dblQuantity / e.dblQuantity))