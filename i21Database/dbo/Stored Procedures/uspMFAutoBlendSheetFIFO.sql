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
	 
            DECLARE @ProductName NVARCHAR(50)
            DECLARE @InputItemName NVARCHAR(50)
            DECLARE @ProductKey INT
            DECLARE @RequiredQty NUMERIC(18,6)
            DECLARE @mRowNumber INT
            DECLARE @BOMItemDetailKey INT
            DECLARE @BOMItemKey INT
            DECLARE @idoc INT
            DECLARE @ErrMsg NVARCHAR(MAX) 
            DECLARE @BOMKey INT
			--DECLARE @IssuedUOM NVARCHAR(50)
			DECLARE @intIssuedUOMTypeId INT
			DECLARE @IsMinorIngredient Bit
			DECLARE @PercentageIncrease NUMERIC(18,6)
			DECLARE @NoOfSheets INT
			DECLARE @UnitKey INT
			DECLARE @SessionID INT
			DECLARE @intRecipeId INT
			DECLARE @strBlenderName NVARCHAR(50)

			----INSERT INTO dbo.Workorder_AutoPickLotsProgress(SessionID,Message)
			----SELECT @SessionID,'Initializing data...'

			SET @PercentageIncrease=0
			SET @NoOfSheets=1

			DECLARE @Attribute NVARCHAR(100),
					@Value NVARCHAR(50),
					@Sequence INT,
					@Count INT,
					@Order1 NVARCHAR(100),
					@RulesName NVARCHAR(100),
					@NoOfSequence INT,
					@Order NVARCHAR(100)

			DECLARE @LotID NVARCHAR(50),
					@AvailQty NUMERIC(18,6),
					@EstNoOfSheets INT,
					@dblWeightPerQty NUMERIC(38,20)

            SELECT @ProductName=strItemNo,
                   @ProductKey=intItemId
            FROM tblICItem 
            WHERE intItemId = (SELECT intItemId FROM tblMFBlendRequirement WHERE intBlendRequirementId=@intBlendRequirementId)
			
			Select @intRecipeId = intRecipeId from tblMFRecipe where intItemId=@ProductKey and intLocationId=@intLocationId and ysnActive=1

			 SELECT @intIssuedUOMTypeId=ISNULL(intIssuedUOMTypeId,0),@strBlenderName=strName FROM tblMFMachine 
			 WHERE intMachineId=(SELECT intMachineId FROM tblMFBlendRequirement WHERE intBlendRequirementId =@intBlendRequirementId)
			 IF @intIssuedUOMTypeId= 0
			 BEGIN  
				SET @ErrMsg='Please configure Issued UOM Type for machine ''' + @strBlenderName + '''.'
				RAISERROR(@ErrMsg,16,1)
			 END

			 SELECT @EstNoOfSheets=(CASE WHEN dblEstNoOfBlendSheet =0 THEN 1 ELSE CEILING(dblEstNoOfBlendSheet) END) FROM tblMFBlendRequirement WHERE intBlendRequirementId=@intBlendRequirementId
			 IF @EstNoOfSheets is null Set @EstNoOfSheets=1
			 SET @NoOfSheets=@EstNoOfSheets
			 
			DECLARE @tblInputItem table      
            ( 
                  RowNumber               INT IDENTITY(1,1),
                  BOMKey                  INT,                
                  BOMItemKey              INT,
                  BOMItemDetailKey		  INT, 
                  RequiredQty             NUMERIC(18,6),
				  --AvailableQty			  NUMERIC(18,6),
				  IsSubstitute			  BIT,
				  IsMinorIngredient       BIT
            )


            IF OBJECT_ID('tempdb..#tblBlendSheetLot') IS NOT NULL  
            DROP TABLE #tblBlendSheetLot  

            Create table #tblBlendSheetLot
			( 
                  ParentLotKey		INT,
                  MaterialKey		INT,
                  Qty				NUMERIC(18,6),
                  UOMKey			INT,
                  IssuedQty			NUMERIC(18,6),
                  IssuedUOMKey      INT,
                  BOMItemDetailKey  INT,
				  UnitKey			INT
			)


		    IF OBJECT_ID('tempdb..#tblBlendSheetLotFinal') IS NOT NULL  
            DROP TABLE #tblBlendSheetLotFinal  

            Create table #tblBlendSheetLotFinal
			( 
                  ParentLotKey      INT,
                  MaterialKey INT,
                  Qty   NUMERIC(18,6),
                  UOMKey      INT,
                  IssuedQty   NUMERIC(18,6),
                  IssuedUOMKey      INT,
                  BOMItemDetailKey  INT,
				  UnitKey INT
			)

		--Get Recipe Input Items
		INSERT INTO @tblInputItem(BOMKey,BOMItemKey,BOMItemDetailKey,RequiredQty,IsSubstitute,IsMinorIngredient)
		Select @intRecipeId,ri.intItemId,ri.intRecipeItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) RequiredQty,0,ri.ysnMinorIngredient
		From tblMFRecipeItem ri 
		Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
		where r.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1
		Union
		Select @intRecipeId,rs.intSubstituteItemId AS intItemId,rs.intRecipeSubstituteItemId,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) RequiredQty,1,0
		From tblMFRecipeSubstituteItem rs
		Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
		where r.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

		IF(SELECT ISNULL(COUNT(1),0) FROM @tblInputItem) = 0  
			RAISERROR('Please configure input item(s) for the output item.',16,1)

		SET @Count=1
		SET @Order=''
		SET @Order1=''

		----INSERT INTO dbo.Workorder_AutoPickLotsProgress(SessionID,Message)
		----SELECT @SessionID,'Sourcing cost/pick order data...'

		SELECT @NoOfSequence=MAX(intSequenceNo)+1 from tblMFBlendRequirementRule where intBlendRequirementId=@intBlendRequirementId

		While(@Count<@NoOfSequence)  
		BEGIN  
			SELECT @RulesName=b.strName ,@Value=a.strValue 
			FROM  tblMFBlendRequirementRule a JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId=b.intBlendSheetRuleId
			where intBlendRequirementId=@intBlendRequirementId and a.intSequenceNo=@Count

			IF @RulesName='Pick Order'                                                    
			BEGIN  
				IF @Value='FIFO'  
				SET @Order='PL.CreateDate ASC,'    
				ELSE IF @Value='LIFO'  
				SET @Order='PL.Createdate DESC,'  
				ELSE IF @Value='FEFO'  
				SET @Order='PL.ExpiryDate ASC,'  
			END   

			IF @RulesName='Is Cost Applicable?'  
			BEGIN
				IF @Value='Yes'  
				SET @Order='PL.UnitCost ASC,'
			END

			SET @Order1=@Order1 + @Order 
			SET @Order=''
			SET @Count=@Count+1
		END

		IF LEN(@Order1) >0 
			SET @Order1=LEFT(@Order1,LEN(@Order1)-1)


		WHILE @NoOfSheets > 0 
		BEGIN
			DECLARE @SQLSTR NVARCHAR(MAX)

			SET @SQLSTR=''

			Declare @QuantityTaken NUMERIC(18,6)
			Declare @isPercResetRequired bit
			Declare @sRequiredQty NUMERIC(18,6)
			SET		@isPercResetRequired = 0
			SELECT	@mRowNumber=MIN(RowNumber) FROM @tblInputItem

			WHILE @mRowNumber IS NOT NULL
			BEGIN
				SELECT  @BOMItemDetailKey	=BOMItemDetailKey,
						@BOMKey				=BOMKey,
						@BOMItemKey			=BOMItemKey,
						@RequiredQty		=(RequiredQty/@EstNoOfSheets),
						@IsMinorIngredient  =IsMinorIngredient
						FROM @tblInputItem 
						WHERE RowNumber=@mRowNumber	    
							
						IF @IsMinorIngredient =1 
						Begin
							IF @isPercResetRequired=0 
							Begin
								Select @sRequiredQty=SUM(RequiredQty)/@EstNoOfSheets from @tblInputItem Where IsMinorIngredient=0
								Select @QuantityTaken=Sum(Qty) From #tblBlendSheetLot
								IF @QuantityTaken>@sRequiredQty
								Begin
									Select @isPercResetRequired=1
									Set @PercentageIncrease =(@QuantityTaken-@sRequiredQty)/@sRequiredQty*100
								End
							End
							SET @RequiredQty=(@RequiredQty+(@RequiredQty * ISNULL(@PercentageIncrease,0)/100)) 
						End

						IF OBJECT_ID('tempdb..#tblInputLot') IS NOT NULL  
						DROP TABLE #tblInputLot 

						Create table #tblInputLot
						( 
						ParentLotID	NVARCHAR(50) COLLATE Latin1_General_CI_AS,
						MaterialKey	INT,
						AvailableQty	NUMERIC(18,6),
						UnitKey		INT,
						dblWeightPerQty NUMERIC(38,20)
						)

						IF OBJECT_ID('tempdb..#tblParentLot') IS NOT NULL  
						DROP TABLE #tblParentLot  

						Create table #tblParentLot
						( 
						MainLotKey	INT,
						ParentLotID	NVARCHAR(50) COLLATE Latin1_General_CI_AS,
						CreateDate	datetime,
						CreatedBy	NVARCHAR(50) COLLATE Latin1_General_CI_AS,
						MaterialKey	INT,
						QueuedQty	NUMERIC(18,6),
						FactoryKey	INT,
						LocationKey INT,
						ExpiryDate	datetime,
						UnitCost	NUMERIC(18,6),
						UnitKey		INT,
						dblWeightPerQty NUMERIC(38,20)
						)
						
						----INSERT INTO #tblParentLot
						----Select * FROM (
						----SELECT L.intParentLotId,
						----PL.strParentLotNumber,
						----MAX(L.dtmDateCreated) AS CreateDate,
						----US.strUserName, --To Review US.strUserName whether nameor Id since added in Group By Clause
						----L.intItemId,
						----SUM(L.dblWeight)AS QueuedQty ,
						----L.intLocationId,
						----L.intSubLocationId,
						----MAX(L.dtmExpiryDate) AS ExpiryDate,
						----L.dblLastCost AS UnitCost,L.intStorageLocationId,L.dblWeightPerQty --To Review L.dblWeightPerQty New Field Added since added in Group By Clause
						----FROM tblICLot L 
						----JOIN tblICParentLot PL on PL.intParentLotId=L.intParentLotId
						----JOIN tblSMUserSecurity US ON L.intCreatedUserId=US.intUserSecurityID
						----WHERE L.intItemId=@BOMItemKey and L.intLocationId=@intLocationId 
						----and (L.intLotStatusId =1 or L.intLotStatusId =3) --ACTIVE,QUARANTINED
						----and L.dtmExpiryDate >= GETDATE() and L.dblWeight > 0 
						----GROUP BY  L.intParentLotId,PL.strParentLotNumber,US.strUserName,L.intItemId,L.intLocationId,L.intSubLocationId,L.intStorageLocationId,
						----L.dblLastCost,L.dblWeightPerQty) AS DT 
						----WHERE DT.QueuedQty>0
					
			
						INSERT INTO #tblParentLot
						Select * FROM (
						SELECT L.intLotId,
						L.strLotNumber,
						MAX(L.dtmDateCreated) AS CreateDate,
						US.strUserName, --To Review US.strUserName whether nameor Id since added in Group By Clause
						L.intItemId,
						SUM(L.dblWeight)AS QueuedQty ,
						L.intLocationId,
						L.intSubLocationId,
						MAX(L.dtmExpiryDate) AS ExpiryDate,
						L.dblLastCost AS UnitCost,L.intStorageLocationId,L.dblWeightPerQty --To Review L.dblWeightPerQty New Field Added since added in Group By Clause
						FROM tblICLot L 
						JOIN tblSMUserSecurity US ON L.intCreatedUserId=US.intUserSecurityID
						WHERE L.intItemId=@BOMItemKey and L.intLocationId=@intLocationId 
						and (L.intLotStatusId =1 or L.intLotStatusId =3) --ACTIVE,QUARANTINED
						and L.dtmExpiryDate >= GETDATE() and L.dblWeight > 0 
						GROUP BY  L.intLotId,L.strLotNumber,US.strUserName,L.intItemId,L.intLocationId,L.intSubLocationId,L.intStorageLocationId,
						L.dblLastCost,L.dblWeightPerQty) AS DT 
						WHERE DT.QueuedQty>0


						SET @SQLSTR ='INSERT INTO #tblInputLot SELECT PL.ParentLotID,PL.MaterialKey,
						(PL.QueuedQty-((SELECT isnull(sum(dblQty),0) from tblICStockReservation where intLotId=PL.MainLotKey And intStorageLocationId=PL.UnitKey) 
						+ (SELECT isnull(sum(Qty),0) from #tblBlendSheetLot where ParentLotKey=PL.MainLotKey))) AS AvailableQty,
						PL.UnitKey AS UnitKey,PL.dblWeightPerQty --INTO #tblInputLot
						FROM #tblParentLot AS PL 
						JOIN dbo.tblICItem AS M ON PL.MaterialKey=M.intItemId
						--JOIN dbo.UOMConversion AS U1 ON U1.UOMKey=M.StandardUOMKey            --For Review
						JOIN dbo.tblSMCompanyLocationSubLocation AS LN  ON LN.intCompanyLocationSubLocationId =PL.LocationKey  --AND LN.LocationName <> ''InTransit''   -- For Review
						WHERE PL.MaterialKey='+STR(@BOMItemKey)+'  AND PL.LocationKey= LN.intCompanyLocationSubLocationId AND PL.FactoryKey='+str(@intLocationId)+'                           
						AND PL.QueuedQty > 0  and PL.ExpiryDate >= GETDATE()
						and (PL.QueuedQty-((SELECT ISNULL(sum(dblQty),0) FROM tblICStockReservation WHERE intLotId=PL.MainLotKey) 
						+ (SELECT ISNULL(sum(Qty),0) from #tblBlendSheetLot WHERE ParentLotKey=PL.MainLotKey))) > 0 '  
						+ 'Order By '+ @Order1     

 
						----INSERT INTO dbo.Workorder_AutoPickLotsProgress(SessionID,Message)
						----SELECT @SessionID,'Processing data...'

						exec(@SQLSTR)

						----INSERT INTO dbo.Workorder_AutoPickLotsProgress(SessionID,Message)
						----SELECT @SessionID,'Optimizing data...'

						DECLARE Cursor_FetchItem CURSOR LOCAL FAST_FORWARD FOR SELECT * from #tblInputLot                       
					
						OPEN Cursor_FetchItem                        
						FETCH NEXT FROM Cursor_FetchItem INTO @LotID,@BOMItemKey,@AvailQty,@UnitKey,@dblWeightPerQty
                            
						WHILE (@@FETCH_STATUS <> -1)                        
						BEGIN
						
							IF @intIssuedUOMTypeId =2 --'BAG' 
								SET @AvailQty = @AvailQty-(@AvailQty % @dblWeightPerQty)

							IF @AvailQty > 0 
							BEGIN
							IF(@AvailQty>=@RequiredQty) 
								BEGIN			
										----INSERT INTO #tblBlendSheetLot 
										----Select
										----PL.intParentLotId As 'ParentLotKey',  
										----PL.intItemId  AS 'MaterialKey',
										----CASE WHEN @intIssuedUOMTypeId =2 THEN (ROUND(@RequiredQty/PL.dblWeightPerQty,0) * PL.dblWeightPerQty)
										----ELSE ROUND(@RequiredQty,3) 
										----END AS 'Quantity',       
										----PL.intWeightUOMId, -- To Review whether UOMId or ItemUOMId  
										----CASE WHEN @intIssuedUOMTypeId =2 THEN ROUND(@RequiredQty/PL.dblWeightPerQty,0)
										----ELSE ROUND(@RequiredQty,3) 
										----END AS 'Issued Qty',
										----CASE WHEN @intIssuedUOMTypeId =2 THEN PL.intItemUOMId
										----ELSE PL.intWeightUOMId 
										----END AS 'IssuedUOMKey',-- To Review whether UOMId or ItemUOMId
										----@BOMItemDetailKey AS 'BOMItemDetailKey',
										----@UnitKey AS 'UnitKey'										  
										----from tblICParentLot PL JOIN tblICItem MR1 ON PL.intItemId=MR1.intItemId
										------JOIn UOMConversion UC1 ON UC1.UOMKey=@Issued_UOMKey --No Link with Lot
										----WHERE PL.strParentLotNumber=@LotID and MR1.intItemId=@BOMItemKey AND PL.dblWeight > 0 --AND PL.FactoryKey=@intLocationId

										INSERT INTO #tblBlendSheetLot 
										Select
										L.intLotId As 'ParentLotKey',  
										L.intItemId  AS 'MaterialKey',
										CASE WHEN @intIssuedUOMTypeId =2 THEN (ROUND(@RequiredQty/L.dblWeightPerQty,0) * L.dblWeightPerQty)
										ELSE ROUND(@RequiredQty,3) 
										END AS 'Quantity',       
										L.intWeightUOMId, -- To Review whether UOMId or ItemUOMId  
										CASE WHEN @intIssuedUOMTypeId =2 THEN ROUND(@RequiredQty/L.dblWeightPerQty,0)
										ELSE ROUND(@RequiredQty,3) 
										END AS 'Issued Qty',
										CASE WHEN @intIssuedUOMTypeId =2 THEN L.intItemUOMId
										ELSE L.intWeightUOMId 
										END AS 'IssuedUOMKey',-- To Review whether UOMId or ItemUOMId
										@BOMItemDetailKey AS 'BOMItemDetailKey',
										@UnitKey AS 'UnitKey'										  
										from tblICLot L JOIN tblICItem MR1 ON L.intItemId=MR1.intItemId
										--JOIn UOMConversion UC1 ON UC1.UOMKey=@Issued_UOMKey --No Link with Lot
										WHERE L.strLotNumber=@LotID and MR1.intItemId=@BOMItemKey AND L.dblWeight > 0 --AND PL.FactoryKey=@intLocationId
										
										                                          										   
										SET @RequiredQty=0
										goto LOOP_END;    
								END

							ELSE                    
								BEGIN
										----INSERT INTO #tblBlendSheetLot 
										----Select
										----PL.intParentLotId As 'ParentLotKey',  
										----PL.intItemId  AS 'MaterialKey',
										----CASE WHEN @intIssuedUOMTypeId =2 THEN (ROUND(@AvailQty/PL.dblWeightPerQty,0) * PL.dblWeightPerQty)
										----ELSE ROUND(@AvailQty,3) 
										----END AS 'Quantity',
										----PL.intWeightUOMId, -- To Review whether UOMId or ItemUOMId  
										----CASE WHEN @intIssuedUOMTypeId =2 THEN ROUND(@AvailQty/PL.dblWeightPerQty,0)
										----ELSE ROUND(@AvailQty,3) 
										----END AS 'Issued Qty', 
										----CASE WHEN @intIssuedUOMTypeId =2 THEN PL.intItemUOMId
										----ELSE PL.intWeightUOMId 
										----END AS 'IssuedUOMKey',-- To Review whether UOMId or ItemUOMId
										----@BOMItemDetailKey AS 'BOMItemDetailKey',
										----@UnitKey AS 'UnitKey'
										----from tblICParentLot PL 
										----JOIN tblICItem MR1 ON PL.intItemId=MR1.intItemId
										------JOIn UOMConversion UC1 ON UC1.UOMKey=@Issued_UOMKey
										----WHERE PL.strParentLotNumber=@LotID and PL.intItemId=@BOMItemKey AND PL.dblWeight > 0-- AND PL.FactoryKey=@intLocationId -- To Review Parent Lot Unique in a Factory

                           
										INSERT INTO #tblBlendSheetLot 
										Select
										L.intLotId As 'ParentLotKey',  
										L.intItemId  AS 'MaterialKey',
										CASE WHEN @intIssuedUOMTypeId =2 THEN (ROUND(@AvailQty/L.dblWeightPerQty,0) * L.dblWeightPerQty)
										ELSE ROUND(@AvailQty,3) 
										END AS 'Quantity',
										L.intWeightUOMId, -- To Review whether UOMId or ItemUOMId  
										CASE WHEN @intIssuedUOMTypeId =2 THEN ROUND(@AvailQty/L.dblWeightPerQty,0)
										ELSE ROUND(@AvailQty,3) 
										END AS 'Issued Qty', 
										CASE WHEN @intIssuedUOMTypeId =2 THEN L.intItemUOMId
										ELSE L.intWeightUOMId 
										END AS 'IssuedUOMKey',-- To Review whether UOMId or ItemUOMId
										@BOMItemDetailKey AS 'BOMItemDetailKey',
										@UnitKey AS 'UnitKey'
										from tblICLot L 
										JOIN tblICItem MR1 ON L.intItemId=MR1.intItemId
										--JOIn UOMConversion UC1 ON UC1.UOMKey=@Issued_UOMKey
										WHERE L.strLotNumber=@LotID and L.intItemId=@BOMItemKey AND L.dblWeight > 0-- AND PL.FactoryKey=@intLocationId -- To Review Parent Lot Unique in a Factory


										SET @RequiredQty=@RequiredQty-@AvailQty
								END
							END --AvailaQty>0 End
				
							SET @UnitKey=NULL
							FETCH NEXT FROM Cursor_FetchItem INTO @LotID,@BOMItemKey,@AvailQty,@UnitKey,@dblWeightPerQty
						END --Cursor End For Pick Lots
						LOOP_END:		
			
						CLOSE Cursor_FetchItem                        
						DEALLOCATE Cursor_FetchItem
					
				 SELECT @mRowNumber=MIN(RowNumber) FROM @tblInputItem WHERE RowNumber>@mRowNumber
		   END --While Loop End For Per Recipe Item
	   
		SET @NoOfSheets= @NoOfSheets-1  
		END -- While Loop End For Per Sheet

		SET @Order1='Order By ' +LEFT(@Order1,lEN(@Order1)-1)


	    INSERT INTO #tblBlendSheetLotFinal
		SELECT  ParentLotKey,MaterialKey,sum(Qty),UOMKey,sum(IssuedQty),IssuedUOMKey,BOMItemDetailKey,UnitKey from #tblBlendSheetLot
		group by ParentLotKey,MaterialKey,UOMKey,IssuedUOMKey,BOMItemDetailKey,UnitKey


		--NA
  ----  	EXEC('SELECT PL.MainLotKey AS ParentLotKey,PL.ParentLotID AS Lot,M.MaterialName AS [Material Name],
		----M.Description AS [Material Description],
		----((Case When U1.UOMName=''BAG'' Then ROUND((BS.IssuedQty),0) Else BS.IssuedQty End) 
		----* (dbo.fn_GetUOMConversionFactorByParentLot(PL.ParentLotID,U1.UOMKey))) AS Quantity,
		----BS.UOMKey,U.UOMName AS UOM,Case When U1.UOMName=''BAG'' Then ROUND((BS.IssuedQty),0) Else BS.IssuedQty End AS [Issued Qty],
		----BS.IssuedUOMKey,U1.UOMName AS [Issued UOM],BS.MaterialKey,BS.MaterialKey AS [BOMItemKey],'+ @BOMKey +' AS [BOMKey],
		----BS.BOMItemDetailKey,PL.UnitCost AS CostPerLB,
		----(SELECT TOP 1(dbo.fn_ConvertnVarcharToDecimal(PropertyValue)) AS PropertyValue FROM dbo.QM_TestResult AS TR  
		----JOIN dbo.QM_Property AS P ON P.PropertyKey=TR.PropertyKey WHERE ProductObjectKey=PL.MainLotKey AND TR.ProductTypeKey=16  AND P.PropertyName in  
		----(SELECT V.SettingValue FROM dbo.iMake_AppSettingValue AS V  JOIN dbo.iMake_AppSetting  AS S ON V.SettingKey = S.SettingKey  AND S.SettingName = ''Average Density'' ) 
		----AND PropertyValue IS NOT NULL  AND PropertyValue <>'''' AND isnumeric(tr.PropertyValue)=1 Order By TR.LastUpdateOn DESC ) AS ''Density'',
		----(BS.Qty/'+@EstNoOfSheets+') AS RequiredQtyPerSheet,
		----(dbo.fn_GetUOMConversionFactorByParentLot(PL.ParentLotID,U1.UOMKey)) As ConversionFactor,
		----M.UDA_RiskScore AS RiskScore,BS.UnitKey AS UnitKey,F.FactoryName As Factory
		----FROM #tblBlendSheetLotFinal BS 
		----JOIN tblICParentLot PL ON BS.ParentLotkey=PL.intParentLotId and PL.dblWeight > 0 
		----JOIN tblICItem M ON M.intItemId=PL.intItemId
		----JOIN UOMConversion U ON U.UOMkey=BS.UOMKey
		----JOIN UOMConversion U1 ON U1.UOMKey=BS.IssuedUOMKey 
		----JOIN tblICStorageLocation UT On UT.intStorageLocationId=BS.UnitKey
		----JOIN tblSMCompanyLocation F on F.intCompanyLocationId=UT.intLocationId
		----WHERE BS.Qty>0') --To Review  ORDER BY M.UDA_RiskScore ASC
		--NA

		----SELECT	PL.intParentLotId AS intLotId
		----,PL.strParentLotNumber AS strLotNumber
		----,M.strItemNo AS strItemNo
		----,M.strDescription AS strDescription
		------,(
		------	(
		------	CASE 
		------		WHEN @intIssuedUOMTypeId=2 --U1.UOMName = 'BAG'
		------			THEN ROUND((BS.IssuedQty), 0)
		------		ELSE BS.IssuedQty
		------		END
		------	) * (PL.dblWeightPerQty)
		------) AS Quantity
		----,BS.Qty AS dblQuantity
		----,BS.UOMKey AS intItemUOMId
		----,UM1.strUnitMeasure AS strUOM
		------,CASE 
		------	WHEN  @intIssuedUOMTypeId=2 --U1.UOMName = 'BAG'
		------		THEN ROUND((BS.IssuedQty), 0)
		------	ELSE BS.IssuedQty
		------END AS [Issued Qty]
		----,BS.IssuedQty  AS dblIssuedQuantity
		----,BS.IssuedUOMKey AS intItemIssuedUOMId
		----,UM2.strUnitMeasure AS strIssuedUOM
		----,BS.MaterialKey AS intItemId
		------,BS.MaterialKey AS [BOMItemKey]
		------,@BOMKey AS [BOMKey]
		----,BS.BOMItemDetailKey AS intRecipeItemId
		----,1 AS CostPerLB --To Review PL.UnitCost
		------,(
		------	SELECT TOP 1 (CAST(PropertyValue AS NUMERIC(18,6))) AS PropertyValue
		------	FROM dbo.QM_TestResult AS TR
		------	INNER JOIN dbo.QM_Property AS P ON P.PropertyKey = TR.PropertyKey
		------	WHERE ProductObjectKey = PL.MainLotKey
		------		AND TR.ProductTypeKey = 16
		------		AND P.PropertyName IN (
		------			SELECT V.SettingValue
		------			FROM dbo.iMake_AppSettingValue AS V
		------			INNER JOIN dbo.iMake_AppSetting AS S ON V.SettingKey = S.SettingKey
		------				AND S.SettingName = '' Average Density ''
		------			)
		------		AND PropertyValue IS NOT NULL
		------		AND PropertyValue <> ''''
		------		AND isnumeric(tr.PropertyValue) = 1
		------	ORDER BY TR.LastUpdateOn DESC
		------	) AS 'Density' --To Review
		----,0 AS Density
		----,(BS.Qty / @EstNoOfSheets) AS RequiredQtyPerSheet
		----,PL.dblWeightPerQty AS dblWeightPerUnit
		------,M.UDA_RiskScore AS RiskScore --To Review
		----,1 AS RiskScore
		----,BS.UnitKey AS intStorageLocationId
		----,F.strLocationName AS strLocationName
		----,@intLocationId AS intLocationId
		----,CAST(1 AS BIT) ysnParentLot
		----FROM #tblBlendSheetLotFinal BS
		----INNER JOIN tblICParentLot PL ON BS.ParentLotKey = PL.intParentLotId	AND PL.dblWeight > 0
		----INNER JOIN tblICItem M ON M.intItemId = PL.intItemId
		----INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.UOMKey
		----INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId=UM1.intUnitMeasureId
		----INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.IssuedUOMKey
		----INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId=UM2.intUnitMeasureId
		----INNER JOIN tblICStorageLocation UT ON UT.intStorageLocationId = BS.UnitKey
		----INNER JOIN tblSMCompanyLocation F ON F.intCompanyLocationId = UT.intLocationId
		----WHERE BS.Qty > 0

		SELECT	
		 L.intLotId AS intWorkOrderInputLotId
		,L.intLotId AS intLotId
		,L.strLotNumber AS strLotNumber
		,M.strItemNo AS strItemNo
		,M.strDescription AS strDescription
		--,(
		--	(
		--	CASE 
		--		WHEN @intIssuedUOMTypeId=2 --U1.UOMName = 'BAG'
		--			THEN ROUND((BS.IssuedQty), 0)
		--		ELSE BS.IssuedQty
		--		END
		--	) * (PL.dblWeightPerQty)
		--) AS Quantity
		,BS.Qty AS dblQuantity
		,BS.UOMKey AS intItemUOMId
		,UM1.strUnitMeasure AS strUOM
		--,CASE 
		--	WHEN  @intIssuedUOMTypeId=2 --U1.UOMName = 'BAG'
		--		THEN ROUND((BS.IssuedQty), 0)
		--	ELSE BS.IssuedQty
		--END AS [Issued Qty]
		,BS.IssuedQty  AS dblIssuedQuantity
		,BS.IssuedUOMKey AS intItemIssuedUOMId
		,UM2.strUnitMeasure AS strIssuedUOM
		,BS.MaterialKey AS intItemId
		--,BS.MaterialKey AS [BOMItemKey]
		--,@BOMKey AS [BOMKey]
		,BS.BOMItemDetailKey AS intRecipeItemId
		,L.dblLastCost AS dblUnitCost --To Review PL.UnitCost
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
		,(BS.Qty / @EstNoOfSheets) AS dblRequiredQtyPerSheet
		,L.dblWeightPerQty AS dblWeightPerUnit
		--,M.UDA_RiskScore AS RiskScore --To Review
		,ISNULL(M.dblRiskScore,0) AS RiskScore
		,BS.UnitKey AS intStorageLocationId
		,F.strLocationName AS strLocationName
		,@intLocationId AS intLocationId
		,CAST(0 AS BIT) ysnParentLot
		,'Added' AS strRowState
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICLot L ON BS.ParentLotKey = L.intLotId	AND L.dblWeight > 0
		INNER JOIN tblICItem M ON M.intItemId = L.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.UOMKey
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId=UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.IssuedUOMKey
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId=UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation UT ON UT.intStorageLocationId = BS.UnitKey
		INNER JOIN tblSMCompanyLocation F ON F.intCompanyLocationId = UT.intLocationId
		WHERE BS.Qty > 0

        ----Delete from Workorder_AutoPickLotsProgress
END TRY                          
BEGIN CATCH                       
	SET @ErrMsg = ERROR_MESSAGE()                    
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')                          
END CATCH     
