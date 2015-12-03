CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetFIFO]
    @intLocationId INT,                            
    @intBlendRequirementId INT,    
    @dblQtyToProduce NUMERIC(18,6),                                  
    @strXml NVARCHAR(MAX)=NULL  
AS
BEGIN TRY      
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	SET NOCOUNT ON 
	 
    DECLARE @intBlendItemId INT
	DECLARE @strBlendItemNo NVARCHAR(50)
    DECLARE @dblRequiredQty NUMERIC(18,6)
    DECLARE @intMinRowNo INT
    DECLARE @intRecipeItemId INT
    DECLARE @intRawItemId INT
    DECLARE @strErrMsg NVARCHAR(MAX) 
	DECLARE @intIssuedUOMTypeId INT
	DECLARE @ysnMinorIngredient Bit
	DECLARE @dblPercentageIncrease NUMERIC(18,6)=0
	DECLARE @intNoOfSheets INT=1
	DECLARE @intStorageLocationId INT
	DECLARE @intRecipeId INT
	DECLARE @strBlenderName NVARCHAR(50)
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE	@dblAvailableQty NUMERIC(18,6)
	DECLARE	@intEstNoOfSheets INT
	DECLARE	@dblWeightPerQty NUMERIC(38,20)
	DECLARE @intMachineId INT
	DECLARE @strSQL NVARCHAR(MAX)
	Declare @ysnEnableParentLot bit=0
	Declare @ysnShowAvailableLotsByStorageLocation bit=0
	Declare @intManufacturingProcessId INT
	Declare @intParentLotId INT
	Declare @ysnRecipeItemValidityByDueDate bit=0
	Declare @intDayOfYear INT
	Declare @dtmDate DATETIME
	Declare @dtmDueDate DATETIME
	DECLARE @dblOriginalRequiredQty NUMERIC(18,6)
	DECLARE @dblPartialQuantity NUMERIC(18,6)
	DECLARE @intPartialQuantityStorageLocationId INT
	DECLARE @intOriginalIssuedUOMTypeId INT
	DECLARE @intKitStagingLocationId INT
	DECLARE @intBlendStagingLocationId INT
	DECLARE @intMinPartialQtyLotRowNo INT
	DECLARE @dblAvailablePartialQty NUMERIC(18,6)

	DECLARE @intSequenceNo INT,
			@intSequenceCount INT=1,
			@strRuleName NVARCHAR(100),
			@strValue NVARCHAR(50),
			@strOrderBy NVARCHAR(100)='',
			@strOrderByFinal NVARCHAR(100)=''

	Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

    SELECT @strBlendItemNo=i.strItemNo,@intBlendItemId=i.intItemId,@intMachineId=intMachineId,
	@intEstNoOfSheets=(CASE WHEN ISNULL(dblEstNoOfBlendSheet,0) = 0 THEN 1 ELSE CEILING(dblEstNoOfBlendSheet) END),
	@dtmDueDate=dtmDueDate
    FROM tblMFBlendRequirement br Join tblICItem i on br.intItemId=i.intItemId 
    WHERE br.intBlendRequirementId=@intBlendRequirementId
	SET @intNoOfSheets=@intEstNoOfSheets
				
	Select @intRecipeId = intRecipeId,@intManufacturingProcessId=intManufacturingProcessId from tblMFRecipe 
	where intItemId=@intBlendItemId and intLocationId=@intLocationId and ysnActive=1

	Select @ysnRecipeItemValidityByDueDate=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
	From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
	and at.strAttributeName='Recipe Item Validity By Due Date'

	If @ysnRecipeItemValidityByDueDate=0
		Set @dtmDate=Convert(date,GetDate())
	Else
		Set @dtmDate=Convert(date,@dtmDueDate)

	SELECT @intDayOfYear = DATEPART(dy, @dtmDate)

	Select @ysnShowAvailableLotsByStorageLocation=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
	From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
	and at.strAttributeName='Show Available Lots By Storage Location'

	Select @intPartialQuantityStorageLocationId=ISNULL(pa.strAttributeValue ,0)
	From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
	and at.strAttributeName='Partial Quantity Storage Location'

	Select @intKitStagingLocationId=pa.strAttributeValue 
	From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
	and at.strAttributeName='Kit Staging Location'

	Select @intBlendStagingLocationId=ISNULL(intBlendProductionStagingUnitId,0) From tblSMCompanyLocation Where intCompanyLocationId=@intLocationId

	SELECT @intIssuedUOMTypeId=ISNULL(intIssuedUOMTypeId,0),@strBlenderName=strName FROM tblMFMachine 
	WHERE intMachineId=@intMachineId
	IF @intIssuedUOMTypeId= 0
	BEGIN  
		SET @strErrMsg='Please configure Issued UOM Type for machine ''' + @strBlenderName + '''.'
		RAISERROR(@strErrMsg,16,1)
	END
		 
	Set @intOriginalIssuedUOMTypeId=@intIssuedUOMTypeId

	DECLARE @tblInputItem table      
    ( 
        intRowNo			INT IDENTITY(1,1),
        intRecipeId			INT,                
        intRecipeItemId		INT,
        intItemId			INT, 
        dblRequiredQty		NUMERIC(18,6),
		ysnIsSubstitute		BIT,
		ysnMinorIngredient	BIT
    )


    IF OBJECT_ID('tempdb..#tblBlendSheetLot') IS NOT NULL  
    DROP TABLE #tblBlendSheetLot  

    Create table #tblBlendSheetLot
	( 
        intParentLotId			INT,
        intItemId				INT,
        dblQuantity				NUMERIC(18,6),
        intItemUOMId			INT,
        dblIssuedQuantity		NUMERIC(18,6),
        intItemIssuedUOMId      INT,
        intRecipeItemId			INT,
		intStorageLocationId	INT,
		dblWeightPerQty			NUMERIC(38,20)
	)

	IF OBJECT_ID('tempdb..#tblBlendSheetLotFinal') IS NOT NULL  
    DROP TABLE #tblBlendSheetLotFinal  

    Create table #tblBlendSheetLotFinal
	( 
        intParentLotId			INT,
        intItemId				INT,
        dblQuantity				NUMERIC(18,6),
        intItemUOMId			INT,
        dblIssuedQuantity		NUMERIC(18,6),
        intItemIssuedUOMId      INT,
        intRecipeItemId			INT,
		intStorageLocationId	INT,
		dblWeightPerQty			NUMERIC(38,20)
	)

	--Get Recipe Input Items
	INSERT INTO @tblInputItem(intRecipeId,intRecipeItemId,intItemId,dblRequiredQty,ysnIsSubstitute,ysnMinorIngredient)
	Select @intRecipeId,ri.intRecipeItemId,ri.intItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) AS dblRequiredQty,0,ri.ysnMinorIngredient
	From tblMFRecipeItem ri 
	Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
	where r.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1 AND
	((ri.ysnYearValidationRequired = 1 AND @dtmDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
	OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo)))
	Union
	Select @intRecipeId,rs.intRecipeSubstituteItemId,rs.intSubstituteItemId AS intItemId,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) dblRequiredQty,1,0
	From tblMFRecipeSubstituteItem rs
	Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
	where r.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1
	ORDER BY ysnMinorIngredient

	IF(SELECT ISNULL(COUNT(1),0) FROM @tblInputItem) = 0
	Begin
		Set @strErrMsg='No input item(s) found for the blend item ' + @strBlendItemNo + '.'
		RAISERROR(@strErrMsg,16,1)
	End  

	SELECT @intSequenceNo=MAX(intSequenceNo)+1 from tblMFBlendRequirementRule where intBlendRequirementId=@intBlendRequirementId

	While(@intSequenceCount<@intSequenceNo)  
	BEGIN  
		SELECT @strRuleName=b.strName ,@strValue=a.strValue 
		FROM  tblMFBlendRequirementRule a JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId=b.intBlendSheetRuleId
		where intBlendRequirementId=@intBlendRequirementId and a.intSequenceNo=@intSequenceCount

		IF @strRuleName='Pick Order'                                                    
		BEGIN  
			IF @strValue='FIFO'  
				SET @strOrderBy='PL.dtmCreateDate ASC,'    
			ELSE IF @strValue='LIFO'  
				SET @strOrderBy='PL.dtmCreateDate DESC,'  
			ELSE IF @strValue='FEFO'  
				SET @strOrderBy='PL.dtmExpiryDate ASC,'  
		END   

		IF @strRuleName='Is Cost Applicable?'  
		BEGIN
			IF @strValue='Yes'  
				SET @strOrderBy='PL.dblUnitCost ASC,'
		END

		SET @strOrderByFinal=@strOrderByFinal + @strOrderBy 
		SET @strOrderBy=''
		SET @intSequenceCount=@intSequenceCount+1
	END

	IF LEN(@strOrderByFinal) >0 
		SET @strOrderByFinal=LEFT(@strOrderByFinal,LEN(@strOrderByFinal)-1)

	WHILE @intNoOfSheets > 0 
	BEGIN
		SET @strSQL=''

		Declare @dblQuantityTaken NUMERIC(18,6)
		Declare @ysnPercResetRequired bit=0
		Declare @sRequiredQty NUMERIC(18,6)

		SELECT	@intMinRowNo=MIN(intRowNo) FROM @tblInputItem

		WHILE @intMinRowNo IS NOT NULL
		BEGIN
			SELECT  @intRecipeItemId	=intRecipeItemId,
					@intRawItemId		=intItemId,
					@dblRequiredQty		=(dblRequiredQty/@intEstNoOfSheets),
					@ysnMinorIngredient =ysnMinorIngredient
					FROM @tblInputItem 
					WHERE intRowNo=@intMinRowNo	    
							
					IF @ysnMinorIngredient =1 
					Begin
						IF @ysnPercResetRequired=0 
						Begin
							Select @sRequiredQty=SUM(dblRequiredQty)/@intEstNoOfSheets from @tblInputItem Where ysnMinorIngredient=0
							Select @dblQuantityTaken=Sum(dblQuantity) From #tblBlendSheetLot
							IF @dblQuantityTaken>@sRequiredQty
							Begin
								Select @ysnPercResetRequired=1
								Set @dblPercentageIncrease =(@dblQuantityTaken-@sRequiredQty)/@sRequiredQty*100
							End
						End
						SET @dblRequiredQty=(@dblRequiredQty+(@dblRequiredQty * ISNULL(@dblPercentageIncrease,0)/100)) 
					End

					SET @dblOriginalRequiredQty=@dblRequiredQty

					IF OBJECT_ID('tempdb..#tblLot') IS NOT NULL  
					DROP TABLE #tblLot  

					Create table #tblLot
					( 
						intLotId				INT,
						strLotNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
						intItemId				INT,
						dblQty					NUMERIC(18,6),
						intLocationId			INT,
						intSubLocationId		INT,
						intStorageLocationId	INT,
						dtmCreateDate			datetime,
						dtmExpiryDate			datetime,
						dblUnitCost				NUMERIC(18,6),
						dblWeightPerQty			NUMERIC(38,20),
						strCreatedBy			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
						intParentLotId			INT,
						intItemUOMId			INT,
						intItemIssuedUOMId      INT
					)
					
					IF OBJECT_ID('tempdb..#tblParentLot') IS NOT NULL  
					DROP TABLE #tblParentLot 

					Create table #tblParentLot
					( 
						intParentLotId			INT,
						strParentLotNumber		NVARCHAR(50) COLLATE Latin1_General_CI_AS,
						intItemId				INT,
						dblQty					NUMERIC(18,6),
						intLocationId			INT,
						intSubLocationId		INT,
						intStorageLocationId	INT,
						dtmCreateDate			datetime,
						dtmExpiryDate			datetime,
						dblUnitCost				NUMERIC(18,6),
						dblWeightPerQty			NUMERIC(38,20),
						strCreatedBy			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
						intItemUOMId			INT,
						intItemIssuedUOMId      INT
					)

					IF OBJECT_ID('tempdb..#tblAvailableInputLot') IS NOT NULL  
					DROP TABLE #tblAvailableInputLot 

					Create table #tblAvailableInputLot
					( 
						intParentLotId			INT,--NVARCHAR(50) COLLATE Latin1_General_CI_AS, --Review
						intItemId				INT,
						dblAvailableQty			NUMERIC(18,6),
						intStorageLocationId	INT,
						dblWeightPerQty			NUMERIC(38,20),
						dtmCreateDate			datetime,
						dtmExpiryDate			datetime,
						dblUnitCost				NUMERIC(18,6),
						intItemUOMId			INT,
						intItemIssuedUOMId      INT
					)

					IF OBJECT_ID('tempdb..#tblInputLot') IS NOT NULL  
					DROP TABLE #tblInputLot 

					Create table #tblInputLot
					( 
						intParentLotId			INT,--NVARCHAR(50) COLLATE Latin1_General_CI_AS, --Review
						intItemId				INT,
						dblAvailableQty			NUMERIC(18,6),
						intStorageLocationId	INT,
						dblWeightPerQty			NUMERIC(38,20),
						intItemUOMId			INT,
						intItemIssuedUOMId      INT
					)
					
					IF OBJECT_ID('tempdb..#tblPartialQtyLot') IS NOT NULL  
					DROP TABLE #tblPartialQtyLot

					Create table #tblPartialQtyLot
					( 
						intRowNo				INT IDENTITY(1,1),
						intLotId				INT,
						intItemId				INT,
						dblAvailableQty			NUMERIC(18,6),
						intStorageLocationId	INT,
						dblWeightPerQty			NUMERIC(38,20),
						intItemUOMId			INT,
						intItemIssuedUOMId      INT
					)
											
					--Get the Lots
					INSERT INTO #tblLot(intLotId,strLotNumber,intItemId,dblQty,intLocationId,intSubLocationId,intStorageLocationId,
						dtmCreateDate,dtmExpiryDate,dblUnitCost,dblWeightPerQty,strCreatedBy,intParentLotId,intItemUOMId,intItemIssuedUOMId)
					SELECT L.intLotId,
						L.strLotNumber,
						L.intItemId,
						L.dblWeight,
						L.intLocationId,
						L.intSubLocationId,
						L.intStorageLocationId,
						L.dtmDateCreated,
						L.dtmExpiryDate,
						L.dblLastCost,
						L.dblWeightPerQty,
						US.strUserName,
						L.intParentLotId,
						L.intWeightUOMId,
						L.intItemUOMId
						FROM tblICLot L 
						LEFT JOIN tblSMUserSecurity US ON L.intCreatedEntityId=US.[intEntityUserSecurityId]
						JOIN tblICLotStatus LS ON L.intLotStatusId=LS.intLotStatusId
						WHERE L.intItemId=@intRawItemId AND L.intLocationId=@intLocationId 
						AND LS.strPrimaryStatus IN ('Active','Quarantine')
						AND L.dtmExpiryDate >= GETDATE() AND L.dblWeight > 0
						AND L.intStorageLocationId NOT IN (@intKitStagingLocationId,@intBlendStagingLocationId,@intPartialQuantityStorageLocationId) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations
						 
					--Get Either Parent Lot OR Child Lot Based on Setting
					If @ysnEnableParentLot = 0
						Begin
							Insert Into #tblParentLot(intParentLotId,strParentLotNumber,intItemId,dblQty,intLocationId,intSubLocationId,intStorageLocationId,
								dtmCreateDate,dtmExpiryDate,dblUnitCost,dblWeightPerQty,strCreatedBy,intItemUOMId,intItemIssuedUOMId)
								Select TL.intLotId,TL.strLotNumber,TL.intItemId,TL.dblQty,TL.intLocationId,TL.intSubLocationId,TL.intStorageLocationId,
								TL.dtmCreateDate,TL.dtmExpiryDate,TL.dblUnitCost,TL.dblWeightPerQty,TL.strCreatedBy,TL.intItemUOMId,TL.intItemIssuedUOMId
								From #tblLot TL
						End
					Else 
						Begin
							If @ysnShowAvailableLotsByStorageLocation=1
								Begin
									Insert Into #tblParentLot(intParentLotId,strParentLotNumber,intItemId,dblQty,intLocationId,intSubLocationId,intStorageLocationId,
									dtmCreateDate,dtmExpiryDate,dblUnitCost,dblWeightPerQty,strCreatedBy,intItemUOMId,intItemIssuedUOMId)
									Select TL.intParentLotId,PL.strParentLotNumber,TL.intItemId,SUM(TL.dblQty) AS dblQty,TL.intLocationId,TL.intSubLocationId,TL.intStorageLocationId,
									TL.dtmCreateDate,MAX(TL.dtmExpiryDate) AS dtmExpiryDate,TL.dblUnitCost,TL.dblWeightPerQty,TL.strCreatedBy,TL.intItemUOMId,TL.intItemIssuedUOMId 
									From #tblLot TL JOIN tblICParentLot PL ON TL.intParentLotId=PL.intParentLotId
									GROUP BY TL.intParentLotId,PL.strParentLotNumber,TL.intItemId,TL.intLocationId,TL.intSubLocationId,TL.intStorageLocationId,
									TL.dtmCreateDate,TL.dblUnitCost,TL.dblWeightPerQty,TL.strCreatedBy,TL.intItemUOMId,TL.intItemIssuedUOMId
								End
							Else
								Begin
									Insert Into #tblParentLot(intParentLotId,strParentLotNumber,intItemId,dblQty,intLocationId,intSubLocationId,intStorageLocationId,
									dtmCreateDate,dtmExpiryDate,dblUnitCost,dblWeightPerQty,strCreatedBy,intItemUOMId,intItemIssuedUOMId)
									Select TL.intParentLotId,PL.strParentLotNumber,TL.intItemId,SUM(TL.dblQty) AS dblQty,TL.intLocationId,NULL AS intSubLocationId,NULL AS intStorageLocationId,
									TL.dtmCreateDate,MAX(TL.dtmExpiryDate) AS dtmExpiryDate,TL.dblUnitCost,TL.dblWeightPerQty,TL.strCreatedBy,TL.intItemUOMId,TL.intItemIssuedUOMId 
									From #tblLot TL JOIN tblICParentLot PL ON TL.intParentLotId=PL.intParentLotId 
									GROUP BY TL.intParentLotId,PL.strParentLotNumber,TL.intItemId,TL.intLocationId,
									TL.dtmCreateDate,TL.dblUnitCost,TL.dblWeightPerQty,TL.strCreatedBy,TL.intItemUOMId,TL.intItemIssuedUOMId
								End
						End
 
					LotLoop:

					--Hand Add
					Delete From #tblAvailableInputLot
					Delete From #tblInputLot

					--Calculate Available Qty for each Lot
					--Available Qty = Physical Qty - (Resrved Qty + Sum of Qty Added to Previous Blend Sheet in cuttent Session)
					If @ysnEnableParentLot = 1 AND @ysnShowAvailableLotsByStorageLocation=1
					Begin
						INSERT INTO #tblAvailableInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,dtmCreateDate,dtmExpiryDate,dblUnitCost,intItemUOMId,intItemIssuedUOMId)
						SELECT PL.intParentLotId,PL.intItemId,
								(
									PL.dblQty - (
									(SELECT ISNULL(SUM(SR.dblQty), 0) FROM tblICStockReservation SR 
										WHERE SR.intLotId = PL.intParentLotId --Review when Parent Lot Reservation Done
										AND SR.intStorageLocationId = PL.intStorageLocationId) 
									+ 
									(SELECT ISNULL(SUM(BS.dblQuantity), 0) FROM #tblBlendSheetLot BS WHERE BS.intParentLotId = PL.intParentLotId)
									)
								) AS dblAvailableQty,
								PL.intStorageLocationId,
								PL.dblWeightPerQty,
								PL.dtmCreateDate,PL.dtmExpiryDate,PL.dblUnitCost,
								PL.intItemUOMId,PL.intItemIssuedUOMId
						FROM #tblParentLot AS PL
						WHERE PL.intItemId = @intRawItemId
					End
					Else
					Begin
						INSERT INTO #tblAvailableInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,dtmCreateDate,dtmExpiryDate,dblUnitCost,intItemUOMId,intItemIssuedUOMId)
						SELECT PL.intParentLotId,PL.intItemId,
								(
									PL.dblQty - (
									(SELECT ISNULL(SUM(SR.dblQty), 0) FROM tblICStockReservation SR 
										WHERE SR.intLotId = PL.intParentLotId ) 
									+ 
									(SELECT ISNULL(SUM(BS.dblQuantity), 0) FROM #tblBlendSheetLot BS WHERE BS.intParentLotId = PL.intParentLotId)
									)
								) AS dblAvailableQty,
								PL.intStorageLocationId,
								PL.dblWeightPerQty,
								PL.dtmCreateDate,PL.dtmExpiryDate,PL.dblUnitCost,
								PL.intItemUOMId,PL.intItemIssuedUOMId
						FROM #tblParentLot AS PL
						WHERE PL.intItemId = @intRawItemId
					End

					--Apply Business Rules
					SET @strSQL = 'INSERT INTO #tblInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId) 
								   SELECT PL.intParentLotId,PL.intItemId,PL.dblAvailableQty,PL.intStorageLocationId,PL.dblWeightPerQty,PL.intItemUOMId,PL.intItemIssuedUOMId 
								   FROM #tblAvailableInputLot PL WHERE PL.dblAvailableQty > 0 ORDER BY ' + @strOrderByFinal

					EXEC(@strSQL)


					DECLARE Cursor_FetchItem CURSOR LOCAL FAST_FORWARD FOR 
					SELECT intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty from #tblInputLot                       
					
					OPEN Cursor_FetchItem                        
					FETCH NEXT FROM Cursor_FetchItem INTO @intParentLotId,@intRawItemId,@dblAvailableQty,@intStorageLocationId,@dblWeightPerQty
                            
					WHILE (@@FETCH_STATUS <> -1)                        
					BEGIN
						
						IF @intIssuedUOMTypeId =2 --'BAG' 
							SET @dblAvailableQty = @dblAvailableQty-(@dblAvailableQty % @dblWeightPerQty)

						IF @dblAvailableQty > 0 
						BEGIN
						IF(@dblAvailableQty>=@dblRequiredQty) 
							BEGIN			
									If @ysnEnableParentLot=0
										INSERT INTO #tblBlendSheetLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,
										dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,dblWeightPerQty) 
										Select
										L.intLotId,  
										L.intItemId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ((CASE WHEN ROUND(@dblRequiredQty/L.dblWeightPerQty,0) = 0 THEN 1 ELSE ROUND(@dblRequiredQty/L.dblWeightPerQty,0) END) * L.dblWeightPerQty)
										ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
										END AS dblQuantity,       
										L.intWeightUOMId AS intItemUOMId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ( CASE WHEN ROUND(@dblRequiredQty/L.dblWeightPerQty,0) = 0 THEN 1 ELSE ROUND(@dblRequiredQty/L.dblWeightPerQty,0) END )
										ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
										END AS dblIssuedQuantity,
										CASE WHEN @intIssuedUOMTypeId =2 THEN L.intItemUOMId
										ELSE L.intWeightUOMId 
										END AS intItemIssuedUOMId,
										@intRecipeItemId AS intRecipeItemId,
										@intStorageLocationId AS intStorageLocationId,
										L.dblWeightPerQty										  
										from tblICLot L
										WHERE L.intLotId=@intParentLotId AND L.dblWeight > 0
									Else
										INSERT INTO #tblBlendSheetLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,
										dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,dblWeightPerQty) 
										Select
										L.intParentLotId,  
										L.intItemId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ((CASE WHEN ROUND(@dblRequiredQty/L.dblWeightPerQty,0) = 0 THEN 1 ELSE ROUND(@dblRequiredQty/L.dblWeightPerQty,0) END) * L.dblWeightPerQty)
										ELSE @dblRequiredQty -- To Review ROUND(@dblRequiredQty,3) 
										END AS dblQuantity,       
										L.intItemUOMId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ( CASE WHEN ROUND(@dblRequiredQty/L.dblWeightPerQty,0) = 0 THEN 1 ELSE ROUND(@dblRequiredQty/L.dblWeightPerQty,0) END )
										ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
										END AS dblIssuedQuantity,
										CASE WHEN @intIssuedUOMTypeId =2 THEN L.intItemIssuedUOMId
										ELSE L.intItemUOMId 
										END AS intItemIssuedUOMId,
										@intRecipeItemId AS intRecipeItemId,
										CASE When @ysnShowAvailableLotsByStorageLocation = 1 THEN @intStorageLocationId Else 0 END AS intStorageLocationId,
										L.dblWeightPerQty										  
										from #tblParentLot L
										WHERE L.intParentLotId=@intParentLotId --AND L.dblWeight > 0

																			                                          										   
									SET @dblRequiredQty=0
									goto LOOP_END;    
							END

						ELSE                    
							BEGIN
									If @ysnEnableParentLot=0
										INSERT INTO #tblBlendSheetLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,
										dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,dblWeightPerQty) 
										Select
										L.intLotId,  
										L.intItemId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ((CASE WHEN ROUND(@dblAvailableQty/L.dblWeightPerQty,0)=0 THEN 1 ELSE ROUND(@dblAvailableQty/L.dblWeightPerQty,0) END) * L.dblWeightPerQty)
										ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
										END AS dblQuantity,       
										L.intWeightUOMId AS intItemUOMId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ( CASE WHEN ROUND(@dblAvailableQty/L.dblWeightPerQty,0) = 0 THEN 1 ELSE ROUND(@dblAvailableQty/L.dblWeightPerQty,0) END )
										ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
										END AS dblIssuedQuantity,
										CASE WHEN @intIssuedUOMTypeId =2 THEN L.intItemUOMId
										ELSE L.intWeightUOMId 
										END AS intItemIssuedUOMId,
										@intRecipeItemId AS intRecipeItemId,
										@intStorageLocationId AS intStorageLocationId,
										L.dblWeightPerQty										  
										from tblICLot L
										WHERE L.intLotId=@intParentLotId AND L.dblWeight > 0
									Else
										INSERT INTO #tblBlendSheetLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,
										dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,dblWeightPerQty) 
										Select
										L.intParentLotId,  
										L.intItemId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ((CASE WHEN ROUND(@dblAvailableQty/L.dblWeightPerQty,0)=0 THEN 1 ELSE ROUND(@dblAvailableQty/L.dblWeightPerQty,0) END) * L.dblWeightPerQty)
										ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
										END AS dblQuantity,       
										L.intItemUOMId,
										CASE WHEN @intIssuedUOMTypeId =2 THEN ( CASE WHEN ROUND(@dblAvailableQty/L.dblWeightPerQty,0) = 0 THEN 1 ELSE ROUND(@dblAvailableQty/L.dblWeightPerQty,0) END )
										ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
										END AS dblIssuedQuantity,
										CASE WHEN @intIssuedUOMTypeId =2 THEN L.intItemIssuedUOMId
										ELSE L.intItemUOMId
										END AS intItemIssuedUOMId,
										@intRecipeItemId AS intRecipeItemId,
										CASE When @ysnShowAvailableLotsByStorageLocation =1 THEN @intStorageLocationId Else 0 END AS intStorageLocationId,
										L.dblWeightPerQty										  
										from #tblParentLot L
										WHERE L.intParentLotId=@intParentLotId --AND L.dblWeight > 0

									SET @dblRequiredQty=@dblRequiredQty-@dblAvailableQty
							END
						END --AvailaQty>0 End
				
						SET @intStorageLocationId=NULL
						FETCH NEXT FROM Cursor_FetchItem INTO @strLotNumber,@intRawItemId,@dblAvailableQty,@intStorageLocationId,@dblWeightPerQty
					END --Cursor End For Pick Lots
					LOOP_END:		
			
					CLOSE Cursor_FetchItem                        
					DEALLOCATE Cursor_FetchItem
			
					--Hand Add Item added from Hand Add Storage Location
						IF @intIssuedUOMTypeId = 2 AND ISNULL(@intPartialQuantityStorageLocationId ,0)>0  --'BAG' 
							Begin
								SET @dblPartialQuantity=0
								SET @dblPartialQuantity = ISNULL((@dblOriginalRequiredQty % @dblWeightPerQty),0)
								
								If @ysnEnableParentLot=0 AND @dblPartialQuantity > 0
										INSERT INTO #tblPartialQtyLot(intLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId)
										Select 
										L.intLotId,  
										L.intItemId,
										L.dblWeight - (
										(SELECT ISNULL(SUM(SR.dblQty), 0) FROM tblICStockReservation SR 
											WHERE SR.intLotId = L.intLotId ) 
										+ 
										(SELECT ISNULL(SUM(BS.dblQuantity), 0) FROM #tblBlendSheetLot BS WHERE BS.intParentLotId = L.intLotId)
										) AS dblAvailableQty,										       
										@intPartialQuantityStorageLocationId AS intStorageLocationId,
										L.dblWeightPerQty,
										L.intWeightUOMId AS intItemUOMId,
										L.intWeightUOMId AS intItemIssuedUOMId
										from tblICLot L 
										JOIN tblICLotStatus LS ON L.intLotStatusId=LS.intLotStatusId
										WHERE L.intItemId=@intRawItemId And L.intStorageLocationId=@intPartialQuantityStorageLocationId AND L.dblWeight > 0 
										AND LS.strPrimaryStatus IN ('Active','Quarantine') AND L.dtmExpiryDate >= GETDATE() 
										ORDER BY L.dtmDateCreated

										Select @intMinPartialQtyLotRowNo=MIN(intRowNo) From #tblPartialQtyLot 

										WHILE (@intMinPartialQtyLotRowNo IS NOT NULL)
										BEGIN
											Select @dblAvailablePartialQty=dblAvailableQty From #tblPartialQtyLot Where intRowNo=@intMinPartialQtyLotRowNo

											If (@dblAvailablePartialQty >= @dblPartialQuantity)
												BEGIN
													INSERT INTO #tblBlendSheetLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,
													dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,dblWeightPerQty)
													SELECT intLotId,intItemId,@dblPartialQuantity,intItemUOMId,
													@dblPartialQuantity,intItemIssuedUOMId,@intRecipeItemId,intStorageLocationId,dblWeightPerQty 
													From #tblPartialQtyLot Where intRowNo=@intMinPartialQtyLotRowNo

													Set @dblPartialQuantity=0

													GOTO PartialQty
												END
											Else
												Begin
													INSERT INTO #tblBlendSheetLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,
													dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,dblWeightPerQty)
													SELECT intLotId,intItemId,@dblAvailablePartialQty,intItemUOMId,
													@dblAvailablePartialQty,intItemIssuedUOMId,@intRecipeItemId,intStorageLocationId,dblWeightPerQty 
													From #tblPartialQtyLot Where intRowNo=@intMinPartialQtyLotRowNo

													Set @dblPartialQuantity=@dblPartialQuantity-@dblAvailablePartialQty
												End

												Select @intMinPartialQtyLotRowNo=Min(intRowNo) from #tblPartialQtyLot 
												where intRowNo>@intMinPartialQtyLotRowNo	
										END

										PartialQty:

										--If no paratial lot found in hand add storage location pick from full add location
										If (Select Count(1) From #tblBlendSheetLot Where intStorageLocationId=@intPartialQuantityStorageLocationId)=0
										Begin
											Set @dblRequiredQty=@dblPartialQuantity
											Set @intIssuedUOMTypeId=1
											GOTO LotLoop
										End

										--If selected hand add qty is less than hand add qty , then pick the remaining qty from full add locatiion
										If (@dblPartialQuantity>0)
										Begin
											Set @dblRequiredQty=@dblPartialQuantity
											Set @intIssuedUOMTypeId=1
											GOTO LotLoop
										End
							End
							
						--Hand Add 
						If (@intIssuedUOMTypeId <> @intOriginalIssuedUOMTypeId)
							Set @intIssuedUOMTypeId=@intOriginalIssuedUOMTypeId
													
				SELECT @intMinRowNo=MIN(intRowNo) FROM @tblInputItem WHERE intRowNo>@intMinRowNo
		END --While Loop End For Per Recipe Item
	   
	SET @intNoOfSheets= @intNoOfSheets-1  
	END -- While Loop End For Per Sheet

	SET @strOrderByFinal='Order By ' + LEFT(@strOrderByFinal,LEN(@strOrderByFinal)-1)

	--Final table after summing the Qty for all individual blend sheet
	INSERT INTO #tblBlendSheetLotFinal(intParentLotId,intItemId,dblQuantity,intItemUOMId,
	dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,dblWeightPerQty)
	SELECT  intParentLotId,intItemId,SUM(dblQuantity) AS dblQuantity,intItemUOMId,
	SUM(dblIssuedQuantity) AS dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId,AVG(dblWeightPerQty) from #tblBlendSheetLot
	group by intParentLotId,intItemId,intItemUOMId,intItemIssuedUOMId,intRecipeItemId,intStorageLocationId


	If @ysnEnableParentLot=0
		SELECT	
			L.intLotId AS intWorkOrderInputLotId
		,L.intLotId AS intLotId
		,L.strLotNumber
		,I.strItemNo
		,I.strDescription
		,BS.dblQuantity
		,BS.intItemUOMId
		,UM1.strUnitMeasure AS strUOM
		,BS.dblIssuedQuantity
		,BS.intItemIssuedUOMId
		,UM2.strUnitMeasure AS strIssuedUOM
		,BS.intItemId
		,BS.intRecipeItemId
		,L.dblLastCost AS dblUnitCost
		--,(
		--	SELECT TOP 1 (CAST(PropertyValue AS NUMERIC(18,6))) AS PropertyValue
		--	FROM dbo.QM_TestResult AS TR
		--	INNER JOIN dbo.QM_Property AS P ON P.PropertyKey = TR.PropertyKey
		--	WHERE ProductObjectKey = PL.MainLotKey
		--		AND TR.ProductTypeKey = 16
		--		AND P.PropertyName IN (
		--			SELECT V.SettingValue
		--			FROM dbo.iMake_AppSettingValue AS V
		--			INNER JOIN dbo.iMake_AppSetting AS S ON V.SettingKey = S.SettingKey
		--				AND S.SettingName = '' Average Density ''
		--			)
		--		AND PropertyValue IS NOT NULL
		--		AND PropertyValue <> ''''
		--		AND isnumeric(tr.PropertyValue) = 1
		--	ORDER BY TR.LastUpdateOn DESC
		--	) AS 'Density' --To Review
		,CAST(0 AS decimal) AS dblDensity
		,(BS.dblQuantity / @intEstNoOfSheets) AS dblRequiredQtyPerSheet
		,L.dblWeightPerQty AS dblWeightPerUnit
		,ISNULL(I.dblRiskScore,0) AS dblRiskScore
		,BS.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,CL.strLocationName
		,@intLocationId AS intLocationId
		,CSL.strSubLocationName
		,L.strLotAlias 
		,CAST(0 AS BIT) ysnParentLot
		,'Added' AS strRowState
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICLot L ON BS.intParentLotId = L.intLotId	AND L.dblWeight > 0
		INNER JOIN tblICItem I ON I.intItemId = L.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId=UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId=UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
		INNER JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
		WHERE BS.dblQuantity > 0
	Else
	If @ysnShowAvailableLotsByStorageLocation=1
		SELECT	
		 PL.intParentLotId AS intWorkOrderInputLotId
		,PL.intParentLotId AS intLotId
		,PL.strParentLotNumber AS strLotNumber
		,I.strItemNo
		,I.strDescription
		,BS.dblQuantity
		,BS.intItemUOMId
		,UM1.strUnitMeasure AS strUOM
		,BS.dblIssuedQuantity
		,BS.intItemIssuedUOMId
		,UM2.strUnitMeasure AS strIssuedUOM
		,BS.intItemId
		,BS.intRecipeItemId
		,0.0 AS dblUnitCost -- Review
		--,(
		--	SELECT TOP 1 (CAST(PropertyValue AS NUMERIC(18,6))) AS PropertyValue
		--	FROM dbo.QM_TestResult AS TR
		--	INNER JOIN dbo.QM_Property AS P ON P.PropertyKey = TR.PropertyKey
		--	WHERE ProductObjectKey = PL.MainLotKey
		--		AND TR.ProductTypeKey = 16
		--		AND P.PropertyName IN (
		--			SELECT V.SettingValue
		--			FROM dbo.iMake_AppSettingValue AS V
		--			INNER JOIN dbo.iMake_AppSetting AS S ON V.SettingKey = S.SettingKey
		--				AND S.SettingName = '' Average Density ''
		--			)
		--		AND PropertyValue IS NOT NULL
		--		AND PropertyValue <> ''''
		--		AND isnumeric(tr.PropertyValue) = 1
		--	ORDER BY TR.LastUpdateOn DESC
		--	) AS 'Density' --To Review
		,CAST(0 AS decimal) AS dblDensity
		,(BS.dblQuantity / @intEstNoOfSheets) AS dblRequiredQtyPerSheet
		,BS.dblWeightPerQty AS dblWeightPerUnit
		,ISNULL(I.dblRiskScore,0) AS dblRiskScore
		,BS.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,CL.strLocationName
		,@intLocationId AS intLocationId
		,CAST(1 AS BIT) ysnParentLot
		,'Added' AS strRowState
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICParentLot PL ON BS.intParentLotId = PL.intParentLotId	--AND PL.dblWeight > 0
		INNER JOIN tblICItem I ON I.intItemId = PL.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId=UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId=UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
		WHERE BS.dblQuantity > 0
		Else
		SELECT	
		 PL.intParentLotId AS intWorkOrderInputLotId
		,PL.intParentLotId AS intLotId
		,PL.strParentLotNumber AS strLotNumber
		,I.strItemNo
		,I.strDescription
		,BS.dblQuantity
		,BS.intItemUOMId
		,UM1.strUnitMeasure AS strUOM
		,BS.dblIssuedQuantity
		,BS.intItemIssuedUOMId
		,UM2.strUnitMeasure AS strIssuedUOM
		,BS.intItemId
		,BS.intRecipeItemId
		,0.0 AS dblUnitCost -- Review
		--,(
		--	SELECT TOP 1 (CAST(PropertyValue AS NUMERIC(18,6))) AS PropertyValue
		--	FROM dbo.QM_TestResult AS TR
		--	INNER JOIN dbo.QM_Property AS P ON P.PropertyKey = TR.PropertyKey
		--	WHERE ProductObjectKey = PL.MainLotKey
		--		AND TR.ProductTypeKey = 16
		--		AND P.PropertyName IN (
		--			SELECT V.SettingValue
		--			FROM dbo.iMake_AppSettingValue AS V
		--			INNER JOIN dbo.iMake_AppSetting AS S ON V.SettingKey = S.SettingKey
		--				AND S.SettingName = '' Average Density ''
		--			)
		--		AND PropertyValue IS NOT NULL
		--		AND PropertyValue <> ''''
		--		AND isnumeric(tr.PropertyValue) = 1
		--	ORDER BY TR.LastUpdateOn DESC
		--	) AS 'Density' --To Review
		,CAST(0 AS decimal) AS dblDensity
		,(BS.dblQuantity / @intEstNoOfSheets) AS dblRequiredQtyPerSheet
		,BS.dblWeightPerQty AS dblWeightPerUnit
		,ISNULL(I.dblRiskScore,0) AS dblRiskScore
		,BS.intStorageLocationId
		,CL.strLocationName
		,@intLocationId AS intLocationId
		,CAST(1 AS BIT) ysnParentLot
		,'Added' AS strRowState
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICParentLot PL ON BS.intParentLotId = PL.intParentLotId	--AND PL.dblWeight > 0
		INNER JOIN tblICItem I ON I.intItemId = PL.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId=UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId=UM2.intUnitMeasureId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = @intLocationId
		WHERE BS.dblQuantity > 0

END TRY                          
BEGIN CATCH                       
	SET @strErrMsg = ERROR_MESSAGE()                    
	RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')                          
END CATCH     
