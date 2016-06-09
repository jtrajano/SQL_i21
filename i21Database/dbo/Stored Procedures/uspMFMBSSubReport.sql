CREATE PROCEDURE [dbo].[uspMFMBSSubReport]
	@intBlendRequirementId int=0,
	@ysnShowPrice BIT=0,
	@intBatchId int=0
AS

DECLARE @strCompanyName NVARCHAR(100)
	,@strCompanyAddress NVARCHAR(100)
	,@strCity NVARCHAR(25)
	,@strState NVARCHAR(50)
	,@strZip NVARCHAR(12)
	,@strCountry NVARCHAR(25)

If @intBlendRequirementId=0
	Begin
		Select 0 intNoofDecimalPlaces,'' strBlendItemNo,''strBlendItemDesc,'' strDemandNo,'' strLotAlias,'' strRawItemNo, 0.0 dblCost,0.0 dblWeightPerQty,0.0	dblTotalIssuedQuantity,
		'' strUOM,0	intTotalRow,0.0	dblTotal,0.0 dblTotalBlend,'' strGrade,'' strChop,'' strGarden,0.0 dblTestResult,''	strLocationName,CAST(0 AS BIT) ysnShowPrice,0 intBatchId,
		'' strNoOfBlendSheet,0.0 dblTestResultSum,0 intUOMCount,null	[1], null [2],	null [3],null [4],null	[5],null [6],null	[7],null	[8],null	[9],null	[10],null	[11],null	[12],null	[13],	null [14],null	[15],null	[16],null	[17],null	[18],null	[19],null	[20], 
		'' S1,''	S2,''	S3,''	S4,''	S5,''	S6,''	S7,''	S8,''	S9,''	S10,''	S11,''	S12,''	S13,''	S14,''	S15,''	S16,''	S17,''	S18,''	S19,''	S20
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
		,@strCountry AS strCompanyCountry
		return
	End

Declare @intNoofDecimalPlaces int=3
DECLARE @intNoofBlendSheet INT    
Declare @intPropertyId int
Declare @intUOMCount int  

SELECT TOP 1 @strCompanyName = strCompanyName
	,@strCompanyAddress = strAddress
	,@strCity = strCity
	,@strState = strState
	,@strZip = strZip
	,@strCountry = strCountry
FROM dbo.tblSMCompanySetup

DECLARE @tblWO TABLE (
	 intRowNo INT identity(1, 1)
	,intWorkOrderId INT
	,strLotId NVARCHAR(max)
	)

DECLARE @tblWOFinal TABLE (
	 intRowNo INT
	,intWorkOrderId INT
	,strLotId NVARCHAR(max)
	,intBatchId INT
	)

INSERT INTO @tblWO (intWorkOrderId)
SELECT DISTINCT intWorkOrderId
FROM tblMFWorkOrder
WHERE intBlendRequirementId=@intBlendRequirementId And intStatusId <> 2

DECLARE @intMinRowNo INT
	,@strParentLotId NVARCHAR(max)
	,@intWorkOrderId INT

SELECT @intMinRowNo = Min(intRowNo) FROM @tblWO

WHILE @intMinRowNo IS NOT NULL
BEGIN
	SET @strParentLotId = ''
	SET @intWorkOrderId = NULL

	SELECT @intWorkOrderId = intWorkOrderId
	FROM @tblWO
	WHERE intRowNo = @intMinRowNo

	If exists(select * FROM tblMFWorkOrderInputParentLot WHERE intWorkOrderId = @intWorkOrderId)
	Begin
		SELECT @strParentLotId = @strParentLotId + Ltrim(intParentLotId) + ','
		FROM tblMFWorkOrderInputParentLot
		WHERE intWorkOrderId = @intWorkOrderId
		ORDER BY intParentLotId
	End

	If exists(select * FROM tblMFWorkOrderInputLot WHERE intWorkOrderId = @intWorkOrderId)
	Begin
		SELECT @strParentLotId = @strParentLotId + Ltrim(intLotId) + ','
		FROM tblMFWorkOrderInputLot
		WHERE intWorkOrderId = @intWorkOrderId
		ORDER BY intLotId
	End

	UPDATE @tblWO SET strLotId = @strParentLotId
	WHERE intRowNo = @intMinRowNo

	SELECT @intMinRowNo = Min(intRowNo)
	FROM @tblWO
	WHERE intRowNo > @intMinRowNo
END

INSERT INTO @tblWOFinal (
	intRowNo
	,intWorkOrderId
	,strLotId
	,intBatchId
	)
SELECT intRowNo
	,intWorkOrderId
	,strLotId
	,RANK() OVER (
		ORDER BY strLotId
		)
FROM @tblWO

UPDATE a
SET intBatchId = b.intRowNo
FROM @tblWOFinal a
INNER JOIN @tblWOFinal b ON a.intBatchId = b.intBatchId

DELETE    
FROM @tblWOFinal    
WHERE intBatchId <> @intBatchId    
    
SELECT @intNoofBlendSheet = Count(*)    
FROM @tblWOFinal    

If exists(select * FROM tblMFWorkOrderInputParentLot WHERE intWorkOrderId = (Select TOP 1 intWorkOrderId From tblMFWorkOrder Where intBlendRequirementId=@intBlendRequirementId))
Begin
SELECT *    
INTO #tempOutput1    
FROM (    
 SELECT 0 AS intNoofDecimalPlaces    
  ,i.strItemNo AS strBlendItemNo
  ,i.strDescription AS strBlendItemDesc
  ,br.strDemandNo
  ,p.strParentLotNumber AS strLotAlias
  ,i1.strItemNo + '-' + i1.strDescription AS strRawItemNo
  ,ROUND((l.dblLastCost * 100), 2) AS dblCost    
  ,l.dblWeightPerQty
  ,wc.dblIssuedQuantity
  ,SUM(wc.dblIssuedQuantity) OVER (    
   PARTITION BY br.strDemandNo    
   ,l.strLotAlias ,l.intItemId
   ) dblTotalIssuedQuantity    
  ,u.strUnitMeasure AS strUOM    
  ,(    
   SELECT COUNT(*)    
   FROM tblMFWorkOrder w1    
   WHERE w1.intBlendRequirementId = @intBlendRequirementId    
   ) AS intTotalRow    
  ,ROUND(SUM(wc.dblQuantity) OVER (    
    PARTITION BY br.strDemandNo    
    ,l.strLotAlias,l.intItemId     
    ), 0) AS dblTotal    
  ,ROUND((SUM(wc.dblQuantity) OVER (          
   PARTITION BY br.strDemandNo          
   ,l.strLotAlias          
   ) * l.dblLastCost),@intNoofDecimalPlaces) AS dblTotalBlend    
  ,'' AS strGrade
  ,'' AS strChop
  ,l.strGarden  
  ,(ISNULL((CONVERT(FLOAT, qm.strPropertyValue)), 0)) AS dblTestResult
  ,cl.strLocationName
  ,@ysnShowPrice AS ysnShowPrice
  ,ft.intRowNo    
  ,ft.intBatchId    
  ,Ltrim(@intNoofBlendSheet) + ' of ' + Ltrim((    
    SELECT COUNT(*)    
    FROM tblMFWorkOrder w1    
    WHERE w1.intBlendRequirementId = @intBlendRequirementId    
     AND w1.intStatusId <> 2 
    )) AS strNoOfBlendSheet    
  ,ROUND(SUM(l.dblWeightPerQty * wc.dblIssuedQuantity * (ISNULL((CONVERT(FLOAT, qm.strPropertyValue)), 0))) OVER (PARTITION BY strDemandNo) / SUM(l.dblWeightPerQty * wc.dblIssuedQuantity) OVER (PARTITION BY strDemandNo), 2) dblTestResultSum    
 ,0 as intUOMCount     
 FROM tblMFWorkOrder w    
 JOIN tblICItem i ON w.intItemId = i.intItemId
 JOIN tblMFBlendRequirement br ON w.intBlendRequirementId = br.intBlendRequirementId    
 JOIN tblMFWorkOrderInputParentLot wc ON w.intWorkOrderId = wc.intWorkOrderId
 JOIN tblICItemUOM iu ON iu.intItemUOMId = wc.intItemIssuedUOMId
 JOIN tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
 JOIN tblICParentLot p ON p.intParentLotId = wc.intParentLotId
 JOIN tblICLot l ON l.intParentLotId = p.intParentLotId
 JOIN tblICItem i1 ON i1.intItemId = wc.intItemId
 JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = br.intLocationId
 JOIN @tblWOFinal ft ON ft.intWorkOrderId = wc.intWorkOrderId    
 LEFT JOIN tblQMTestResult qm ON qm.intProductValueId = p.intParentLotId
  AND qm.intPropertyId = @intPropertyId    
  AND qm.intProductTypeId = 11    
  AND qm.intSampleId = (    
   SELECT MAX(intSampleId)    
   FROM tblQMTestResult    
   WHERE intProductValueId = l.intParentLotId   
    AND intProductTypeId = 11    
   )    
 WHERE br.intBlendRequirementId=@intBlendRequirementId    
  AND w.intStatusId <> 2   
  AND l.intLotId = (    
   SELECT TOP 1 intLotId    
   FROM tblICLot    
   WHERE intParentLotId = p.intParentLotId    
    AND intItemId = wc.intItemId    
   ORDER BY dblWeight DESC    
   )    
  
 ) AS SourceTable    
PIVOT(Sum(dblIssuedQuantity) FOR intRowNo IN (    
    [1]    
   ,[2]    
   ,[3]    
   ,[4]    
   ,[5]    
   ,[6]    
   ,[7]    
   ,[8]    
   ,[9]    
   ,[10]    
   ,[11]    
   ,[12]    
   ,[13]    
   ,[14]    
   ,[15]    
   ,[16]    
   ,[17]    
   ,[18]    
   ,[19]    
   ,[20]    
   )) AS PivotTable    
End

If exists(select * FROM tblMFWorkOrderInputLot WHERE intWorkOrderId = (Select TOP 1 intWorkOrderId From tblMFWorkOrder Where intBlendRequirementId=@intBlendRequirementId))
Begin
SELECT *    
INTO #tempOutput2    
FROM (    
 SELECT 0 AS intNoofDecimalPlaces    
  ,i.strItemNo AS strBlendItemNo
  ,i.strDescription AS strBlendItemDesc
  ,br.strDemandNo
  ,l.strLotNumber AS strLotAlias
  ,i1.strItemNo + '-' + i1.strDescription AS strRawItemNo
  ,ROUND((l.dblLastCost * 100), 2) AS dblCost    
  ,l.dblWeightPerQty
  ,wc.dblIssuedQuantity
  ,SUM(wc.dblIssuedQuantity) OVER (    
   PARTITION BY br.strDemandNo    
   ,l.strLotAlias ,l.intItemId
   ) dblTotalIssuedQuantity    
  ,u.strUnitMeasure AS strUOM    
  ,(    
   SELECT COUNT(*)    
   FROM tblMFWorkOrder w1    
   WHERE w1.intBlendRequirementId = @intBlendRequirementId    
   ) AS intTotalRow    
  ,ROUND(SUM(wc.dblQuantity) OVER (    
    PARTITION BY br.strDemandNo    
    ,l.strLotAlias,l.intItemId     
    ), 0) AS dblTotal    
  ,ROUND((SUM(wc.dblQuantity) OVER (          
   PARTITION BY br.strDemandNo          
   ,l.strLotAlias          
   ) * l.dblLastCost),@intNoofDecimalPlaces) AS dblTotalBlend    
  ,'' AS strGrade
  ,'' AS strChop
  ,l.strGarden  
  ,(ISNULL((CONVERT(FLOAT, qm.strPropertyValue)), 0)) AS dblTestResult
  ,cl.strLocationName
  ,@ysnShowPrice AS ysnShowPrice
  ,ft.intRowNo    
  ,ft.intBatchId    
  ,Ltrim(@intNoofBlendSheet) + ' of ' + Ltrim((    
    SELECT COUNT(*)    
    FROM tblMFWorkOrder w1    
    WHERE w1.intBlendRequirementId = @intBlendRequirementId    
     AND w1.intStatusId <> 2 
    )) AS strNoOfBlendSheet    
  ,ROUND(SUM(l.dblWeightPerQty * wc.dblIssuedQuantity * (ISNULL((CONVERT(FLOAT, qm.strPropertyValue)), 0))) OVER (PARTITION BY strDemandNo) / SUM(l.dblWeightPerQty * wc.dblIssuedQuantity) OVER (PARTITION BY strDemandNo), 2) dblTestResultSum    
 ,0 as intUOMCount     
 FROM tblMFWorkOrder w    
 JOIN tblICItem i ON w.intItemId = i.intItemId
 JOIN tblMFBlendRequirement br ON w.intBlendRequirementId = br.intBlendRequirementId    
 JOIN tblMFWorkOrderInputLot wc ON w.intWorkOrderId = wc.intWorkOrderId
 JOIN tblICItemUOM iu ON iu.intItemUOMId = wc.intItemIssuedUOMId
 JOIN tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
 JOIN tblICLot l ON l.intLotId = wc.intLotId
 JOIN tblICItem i1 ON i1.intItemId = wc.intItemId
 JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = br.intLocationId
 JOIN @tblWOFinal ft ON ft.intWorkOrderId = wc.intWorkOrderId    
 LEFT JOIN tblQMTestResult qm ON qm.intProductValueId = l.intParentLotId
  AND qm.intPropertyId = @intPropertyId    
  AND qm.intProductTypeId = 6    
  AND qm.intSampleId = (    
   SELECT MAX(intSampleId)    
   FROM tblQMTestResult    
   WHERE intProductValueId = l.intParentLotId   
    AND intProductTypeId = 6    
   )    
 WHERE br.intBlendRequirementId=@intBlendRequirementId    
  AND w.intStatusId <> 2   
  AND l.intLotId = (    
   SELECT TOP 1 intLotId    
   FROM tblICLot    
   WHERE intLotId = l.intLotId    
    AND intItemId = wc.intItemId    
   ORDER BY dblWeight DESC    
   )    
  
 ) AS SourceTable    
PIVOT(Sum(dblIssuedQuantity) FOR intRowNo IN (    
    [1]    
   ,[2]    
   ,[3]    
   ,[4]    
   ,[5]    
   ,[6]    
   ,[7]    
   ,[8]    
   ,[9]    
   ,[10]    
   ,[11]    
   ,[12]    
   ,[13]    
   ,[14]    
   ,[15]    
   ,[16]    
   ,[17]    
   ,[18]    
   ,[19]    
   ,[20]    
   )) AS PivotTable    
End

SELECT DISTINCT *    
INTO #tempOutput3    
FROM (    
 SELECT CASE     
   WHEN w.intKitStatusId = 7 --Kitted
    THEN 'PK'    
   WHEN w.intKitStatusId = 6 --Pre Kitted
    THEN CASE     
      WHEN w.intStatusId = 5 --Hold
       THEN 'O'    
      ELSE 'N'    
      END    
   WHEN w.intKitStatusId = 13 --Completed
    THEN 'P'    
   WHEN w.intKitStatusId = 8 --Kit Transferred
    THEN 'T'    
   WHEN w.intKitStatusId = 12 --Staged
    THEN 'S'    
   END AS strKitStatus    
  ,'S' + RTRIM(intRowNo) AS intRowNo
 FROM tblMFWorkOrder w    
 JOIN @tblWOFinal ft ON ft.intWorkOrderId=w.intWorkOrderId
 WHERE w.intBlendRequirementId=@intBlendRequirementId
  ) t    
PIVOT(Min(strKitStatus)    
  FOR intRowNo IN (    
    [S1]    
   ,[S2]    
   ,[S3]    
   ,[S4]    
   ,[S5]    
   ,[S6]    
   ,[S7]    
   ,[S8]    
   ,[S9]    
   ,[S10]    
   ,[S11]    
   ,[S12]    
   ,[S13]    
   ,[S14]    
   ,[S15]    
   ,[S16]    
   ,[S17]    
   ,[S18]    
   ,[S19]    
   ,[S20]    
   )) AS PivotTable    
 
If exists(select * FROM tblMFWorkOrderInputParentLot WHERE intWorkOrderId = (Select TOP 1 intWorkOrderId From tblMFWorkOrder Where intBlendRequirementId=@intBlendRequirementId))
Begin
	Select @intUOMCount=Count(DISTINCT strUOM) from #tempOutput1
	Update #tempOutput1 set intUOMCount=@intUOMCount      
    
	SELECT *
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
	,@strCountry AS strCompanyCountry	    
	FROM #tempOutput1 t    
	JOIN #tempOutput3 t1 ON 1 = 1
End

If exists(select * FROM tblMFWorkOrderInputLot WHERE intWorkOrderId = (Select TOP 1 intWorkOrderId From tblMFWorkOrder Where intBlendRequirementId=@intBlendRequirementId))
Begin
	Select @intUOMCount=Count(DISTINCT strUOM) from #tempOutput2
	Update #tempOutput2 set intUOMCount=@intUOMCount      
    
	SELECT *    
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
	,@strCountry AS strCompanyCountry
	FROM #tempOutput2 t    
	JOIN #tempOutput3 t1 ON 1 = 1
End
