CREATE PROCEDURE [dbo].[uspMFMBSReport]
@xmlParam NVARCHAR(MAX) = NULL
AS
	DECLARE @intBlendRequirementId	INT,
			@ysnShowPrice			BIT,
			@idoc					INT 
			
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
	EXEC sp_xml_preparedocument @idoc output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@idoc, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intBlendRequirementId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intBlendRequirementId'

	SELECT	@ysnShowPrice = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'ysnShowPrice'

DECLARE @strCompanyName NVARCHAR(100)
	,@strCompanyAddress NVARCHAR(100)
	,@strCity NVARCHAR(25)
	,@strState NVARCHAR(50)
	,@strZip NVARCHAR(12)
	,@strCountry NVARCHAR(25)

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

SELECT TOP 1 @strCompanyName = strCompanyName
	,@strCompanyAddress = strAddress
	,@strCity = strCity
	,@strState = strState
	,@strZip = strZip
	,@strCountry = strCountry
FROM dbo.tblSMCompanySetup

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

SELECT DISTINCT @intBlendRequirementId AS intBlendRequirementId
	,@ysnShowPrice AS ysnShowPrice
	,intBatchId
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
	,@strCountry AS strCompanyCountry	
FROM @tblWOFinal
ORDER BY intBatchId