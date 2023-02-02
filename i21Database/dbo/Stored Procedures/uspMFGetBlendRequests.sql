CREATE PROCEDURE [dbo].[uspMFGetBlendRequests]
	@intWorkOrderId int = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

If @intWorkOrderId=0
	Select a.intBlendRequirementId,a.strDemandNo,a.intItemId,b.strItemNo,b.strDescription,(a.dblQuantity - ISNULL(a.dblIssuedQty,0)) dblQuantity,
	c.intItemUOMId,d.strUnitMeasure AS strUOM,a.dtmDueDate,a.intLocationId,
	a.intManufacturingCellId AS intManufacturingCellId,
	a.intMachineId,a.dblBlenderSize,g.dblStandardCost,mc.strCellName,r.intManufacturingProcessId,
	CASE Month(GETDATE()) 
			WHEN 1 THEN bg.dblJan WHEN 2 THEN bg.dblFeb WHEN 3 THEN bg.dblMar WHEN 4 THEN bg.dblApr WHEN 5 THEN bg.dblMay WHEN 6 THEN bg.dblJun 
			WHEN 7 THEN bg.dblJul WHEN 8 THEN bg.dblAug WHEN 9 THEN bg.dblSep WHEN 10 THEN bg.dblOct WHEN 11 THEN bg.dblNov WHEN 12 THEN bg.dblDec 
		END AS dblAffordabilityCost,
	CompanyLocation.strLocationName AS strCompanyLocationName
	,a.strReferenceNo AS strERPOrderNo
	from tblMFBlendRequirement a 
	Join tblICItem b on a.intItemId=b.intItemId 
	Join tblICItemUOM c on b.intItemId=c.intItemId and a.intUOMId=c.intUnitMeasureId 
	Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId 
	Left Join tblMFRecipe e on a.intItemId=e.intItemId And a.intLocationId=e.intLocationId And e.ysnActive=1 
	Left Join tblICItemLocation f on b.intItemId=f.intItemId and f.intLocationId=a.intLocationId
	Left Join tblICItemPricing g on g.intItemId=b.intItemId And g.intItemLocationId=f.intItemLocationId
	Left Join tblMFManufacturingCell mc on a.intManufacturingCellId=mc.intManufacturingCellId
	Left Join tblMFRecipe r on a.intItemId=r.intItemId AND a.intLocationId=r.intLocationId AND r.ysnActive=1
	Left Join tblMFBudget bg on a.intItemId=bg.intItemId AND a.intLocationId=bg.intLocationId AND bg.intYear=YEAR(GETDATE()) AND bg.intBudgetTypeId=2
	left join tblSMCompanyLocation AS CompanyLocation ON a.intLocationId = CompanyLocation.intCompanyLocationId
	Where a.intStatusId=1

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
		 , ISNULL(NULLIF(f.strERPOrderNo, ''), a.strReferenceNo) AS strERPOrderNo
		 , ISNULL(WorkOrderStatus.strName, 'Not Released')	AS strWorkOrderStatus
	FROM tblMFBlendRequirement a 
	JOIN tblICItem b ON a.intItemId = b.intItemId 
	JOIN tblICItemUOM c ON b.intItemId = c.intItemId AND a.intUOMId = c.intUnitMeasureId 
	JOIN tblICUnitMeasure d ON c.intUnitMeasureId = d.intUnitMeasureId 
	LEFT JOIN tblMFRecipe e ON a.intItemId = e.intItemId AND a.intLocationId = e.intLocationId AND e.ysnActive=1 
	JOIN tblMFWorkOrder f ON a.intBlendRequirementId = f.intBlendRequirementId
	LEFT JOIN tblICItemLocation g ON b.intItemId = g.intItemId AND g.intLocationId = a.intLocationId
	LEFT JOIN tblICItemPricing h ON h.intItemId = b.intItemId AND g.intItemLocationId = h.intItemLocationId
	LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON a.intLocationId = CompanyLocation.intCompanyLocationId
	OUTER APPLY (SELECT WorkOrderStatus.strName
				 FROM tblMFWorkOrder AS WorkOrder
				 JOIN tblMFWorkOrderStatus AS WorkOrderStatus ON WorkOrder.intStatusId = WorkOrderStatus.intStatusId
				 WHERE WorkOrder.intBlendRequirementId = a.intBlendRequirementId) AS WorkOrderStatus
	WHERE f.intWorkOrderId = @intWorkOrderId

--Negative means BlendRequirementId
If @intWorkOrderId<0
	Select a.intBlendRequirementId,a.strDemandNo,a.intItemId,b.strItemNo,b.strDescription,
	Case When (a.dblQuantity - ISNULL(a.dblIssuedQty,0))<=0 then 0 Else (a.dblQuantity - ISNULL(a.dblIssuedQty,0)) End AS dblQuantity,
	c.intItemUOMId,d.strUnitMeasure AS strUOM,a.dtmDueDate,a.intLocationId,a.intManufacturingCellId,
	h.dblStandardCost,
	CompanyLocation.strLocationName AS strCompanyLocationName
	,a.strReferenceNo AS strERPOrderNo
	from tblMFBlendRequirement a 
	Join tblICItem b on a.intItemId=b.intItemId 
	Join tblICItemUOM c on b.intItemId=c.intItemId and a.intUOMId=c.intUnitMeasureId 
	Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId 
	Left Join tblMFRecipe e on a.intItemId=e.intItemId And a.intLocationId=e.intLocationId And e.ysnActive=1 
	Left Join tblICItemLocation g on b.intItemId=g.intItemId and g.intLocationId=a.intLocationId
	Left Join tblICItemPricing h on h.intItemId=b.intItemId And g.intItemLocationId=h.intItemLocationId
	left join tblSMCompanyLocation AS CompanyLocation ON a.intLocationId = CompanyLocation.intCompanyLocationId
	Where a.intBlendRequirementId=ABS(@intWorkOrderId)