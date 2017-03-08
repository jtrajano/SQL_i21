CREATE PROCEDURE [dbo].[uspCFInvoiceReportFee](
	@xmlParam NVARCHAR(MAX)=null
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		IF (ISNULL(@xmlParam,'') = '')
		BEGIN 
		SELECT 
			 intFeeLoopId				 = 0
			,intAccountId				 = 0
			,strCalculationType			 = ''
			,dblFeeRate					 = 0.0
			,intTransactionId			 = 0
			,dtmTransactionDate			 = GETDATE()
			,dtmStartDate				 = GETDATE()
			,dtmEndDate					 = GETDATE()
			,dblQuantity				 = 0.0
			,intCardId					 = 0
			,dblFeeAmount				 = 0.0
			,strFeeDescription			 = ''
			,strFee						 = ''
			,strInvoiceFormat			 = ''
			,dblFeeTotalAmount			 = 0.0
			,strInvoiceReportNumber		 = ''
			,intCustomerId				 = 0
			,intTermID					 = 0
			,intSalesPersonId			 = 0
			,intItemId					 = 0
			RETURN;
		END
		ELSE
		BEGIN 
			DECLARE @idoc INT
			DECLARE @whereClause NVARCHAR(MAX)
			--DECLARE @endWhereClause NVARCHAR(MAX)
		
			DECLARE @From NVARCHAR(MAX)
			DECLARE @To NVARCHAR(MAX)
			DECLARE @Condition NVARCHAR(MAX)
			DECLARE @Fieldname NVARCHAR(MAX)

			DECLARE @tblCFFieldList TABLE
			(
				[intFieldId]   INT , 
				[strFieldId]   NVARCHAR(MAX)   
			)
		
			SET @whereClause = ''
			--SET @endWhereClause = ''

			INSERT INTO @tblCFFieldList(
				 [intFieldId]
				,[strFieldId]
			)
			SELECT 
				 RecordKey
				,Record
			FROM [fnCFSplitString]('intCustomerGroupId,intAccountId,strNetwork,dtmTransactionDate,dtmPostedDate,strInvoiceCycle,strPrintTimeStamp',',') 


			--READ XML
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam

			--TEMP TABLE FOR PARAMETERS
			DECLARE @temp_params TABLE (
				 [fieldname] NVARCHAR(MAX)
				,[condition] NVARCHAR(MAX)      
				,[from] NVARCHAR(MAX)
				,[to] NVARCHAR(MAX)
				,[join] NVARCHAR(MAX)
				,[begingroup] NVARCHAR(MAX)
				,[endgroup] NVARCHAR(MAX) 
				,[datatype] NVARCHAR(MAX)
			) 

			--XML DATA TO TABLE
			INSERT INTO @temp_params
			SELECT *
			FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
			WITH ([fieldname] NVARCHAR(MAX)
				, [condition] NVARCHAR(MAX)
				, [from] NVARCHAR(MAX)
				, [to] NVARCHAR(MAX)
				, [join] NVARCHAR(MAX)
				, [begingroup] NVARCHAR(MAX)
				, [endgroup] NVARCHAR(MAX)
				, [datatype] NVARCHAR(MAX))



			DECLARE @intCounter INT
			DECLARE @strField	NVARCHAR(MAX)

			WHILE (EXISTS(SELECT 1 FROM @tblCFFieldList))
			BEGIN
				SELECT @intCounter = [intFieldId] FROM @tblCFFieldList
				SELECT @strField = [strFieldId] FROM @tblCFFieldList WHERE [intFieldId] = @intCounter
				
			--MAIN LOOP			
			SELECT TOP 1
				 @From = [from]
				,@To = [to]
				,@Condition = [condition]
				,@Fieldname = [fieldname]
			FROM @temp_params WHERE [fieldname] = @strField
			IF (UPPER(@Condition) = 'BETWEEN')
			BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
			END
			ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','='))
			BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
			END
			ELSE IF (UPPER(@Condition) = 'IN')
			BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
			END

			SET @From = ''
			SET @To = ''
			SET @Condition = ''
			SET @Fieldname = ''



			--MAIN LOOP

				DELETE FROM @tblCFFieldList WHERE [intFieldId] = @intCounter
			END

			DECLARE @ysnInvoiceBillingCycleFee	BIT = 0

			SELECT TOP 1
				 @From = [from]
				,@To = [to]
				,@Condition = [condition]
				,@Fieldname = [fieldname]
			FROM @temp_params WHERE [fieldname] = 'ysnBillingCycle'

			IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'TRUE' OR @From = 1))
			BEGIN
				SET @ysnInvoiceBillingCycleFee = 1
			END

			SET @From = ''
			SET @To = ''
			SET @Condition = ''
			SET @Fieldname = ''

		
			DECLARE @ysnInvoiceMonthyFee		BIT = 0

			SELECT TOP 1
				 @From = [from]
				,@To = [to]
				,@Condition = [condition]
				,@Fieldname = [fieldname]
			FROM @temp_params WHERE [fieldname] = 'ysnMonthly'

			IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'TRUE' OR @From = 1))
			BEGIN
				SET @ysnInvoiceMonthyFee = 1
			END

			SET @From = ''
			SET @To = ''
			SET @Condition = ''
			SET @Fieldname = ''


			DECLARE @ysnInvoiceAnnualFee		BIT = 0

			SELECT TOP 1
				 @From = [from]
				,@To = [to]
				,@Condition = [condition]
				,@Fieldname = [fieldname]
			FROM @temp_params WHERE [fieldname] = 'ysnAnnual'

			IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'TRUE' OR @From = 1))
			BEGIN
				SET @ysnInvoiceAnnualFee = 1
			END

			SET @From = ''
			SET @To = ''
			SET @Condition = ''
			SET @Fieldname = ''

		

			DECLARE @SQL NVARCHAR(MAX)

			-----------------------------------
			--**BEGIN FEE CALCULATION**---
			-----------------------------------
		
			-------------VARIABLES------------
		

			DECLARE @intLoopId				INT

			DECLARE @tblCFInvoiceFeesTemp TABLE
			(
				  intAccountId				INT
				 ,intCardId					INT
				 ,intFeeProfileId			INT
				 ,intSalesPersonId			INT
				 ,dtmInvoiceDate			DATETIME
				 ,intCustomerId				INT
				 ,intInvoiceId				INT
				 ,intTransactionId			INT
				 ,intCustomerGroupId		INT
				 ,intTermID					INT
				 ,intBalanceDue				INT
				 ,intDiscountDay			INT	
				 ,intDayofMonthDue			INT
				 ,intDueNextMonth			INT
				 ,intSort					INT
				 ,intConcurrencyId			INT
				 ,ysnAllowEFT				BIT
				 ,ysnActive					BIT
				 ,ysnEnergyTrac				BIT
				 ,dblQuantity				NUMERIC(18,6)
				 ,dblTotalAmount			NUMERIC(18,6)
				 ,dblDiscountEP				NUMERIC(18,6)
				 ,dblAPR					NUMERIC(18,6)	
				 ,strTerm					NVARCHAR(MAX)
				 ,strType					NVARCHAR(MAX)
				 ,strTermCode				NVARCHAR(MAX)	
				 ,strNetwork				NVARCHAR(MAX)	
				 ,strCustomerName			NVARCHAR(MAX)
				 ,strInvoiceCycle			NVARCHAR(MAX)
				 ,strGroupName				NVARCHAR(MAX)
				 ,strInvoiceNumber			NVARCHAR(MAX)
				 ,strInvoiceReportNumber	NVARCHAR(MAX)
				 ,dtmDiscountDate			DATETIME
				 ,dtmDueDate				DATETIME
				 ,dtmTransactionDate		DATETIME
				 ,dtmPostedDate				DATETIME
				 ,strTransactionType		NVARCHAR(MAX)
				 ,intNetworkId				INT

			)

			DECLARE @tblCFInvoiceFeeDetail TABLE
		(
		     intFeeProfileId						 INT
			,strFeeProfileId						 NVARCHAR(MAX)
			,strFeeProfileDescription				 NVARCHAR(MAX)
			,strInvoiceFormat						 NVARCHAR(MAX)
			,intFeeProfileDetailId					 INT
			,strFeeProfileDetailDescription			 NVARCHAR(MAX)
			,dtmEndDate								 DATETIME
			,dtmStartDate							 DATETIME
			,intFeeId								 INT
			,strFee									 NVARCHAR(MAX)
			,strFeeDescription						 NVARCHAR(MAX)
			,strCalculationType						 NVARCHAR(MAX)
			,strCalculationFrequency				 NVARCHAR(MAX)
			,ysnExtendedRemoteTrans					 BIT
			,ysnRemotesTrans						 BIT
			,ysnLocalTrans							 BIT
			,ysnForeignTrans						 BIT
			,intNetworkId							 INT
			,intCardTypeId							 INT
			,intMinimumThreshold					 INT
			,intMaximumThreshold					 INT
			,dblFeeRate								 NUMERIC(18,6)
			,intGLAccountId							 INT
			,intItemId								 INT
			,intRestrictedByProduct					 INT
		)

			CREATE TABLE ##tblCFInvoiceFeeOutput
		(
			  intFeeLoopId				INT
			 ,intAccountId				INT
			 ,strCalculationType		NVARCHAR(MAX)
			 ,dblFeeRate				NUMERIC(18,6)
			 ,intTransactionId			INT
			 ,dtmTransactionDate		DATETIME
			 ,dtmStartDate				DATETIME
			 ,dtmEndDate				DATETIME
			 ,dblQuantity				NUMERIC(18,6)
			 ,intCardId					INT	
			 ,dblFeeAmount				NUMERIC(18,6)
			 ,strFeeDescription			NVARCHAR(MAX)
			 ,strFee					NVARCHAR(MAX)
			 ,strInvoiceFormat			NVARCHAR(MAX)
			 ,strInvoiceReportNumber	NVARCHAR(MAX)
			 ,intCustomerId				INT
			 ,intTermID					INT
			 ,intSalesPersonId			INT
			 ,dtmInvoiceDate			DATETIME
			 ,intItemId					INT
		)

			-------------VARIABLES------------

		
		


			-----------------MAIN QUERY------------------
			EXEC('SELECT * 
			INTO ##tmpInvoiceFee
			FROM vyuCFInvoiceFee '+ @whereClause)
			-----------------MAIN QUERY------------------

			INSERT @tblCFInvoiceFeesTemp
			SELECT
			 intAccountId			
			,intCardId				
			,intFeeProfileId		
			,intSalesPersonId		
			,dtmInvoiceDate		
			,intCustomerId			
			,intInvoiceId			
			,intTransactionId		
			,intCustomerGroupId	
			,intTermID				
			,intBalanceDue			
			,intDiscountDay		
			,intDayofMonthDue		
			,intDueNextMonth		
			,intSort				
			,intConcurrencyId		
			,ysnAllowEFT			
			,ysnActive				
			,ysnEnergyTrac			
			,dblQuantity			
			,dblTotalAmount		
			,dblDiscountEP			
			,dblAPR				
			,strTerm				
			,strType				
			,strTermCode			
			,strNetwork			
			,strCustomerName		
			,strInvoiceCycle		
			,strGroupName			
			,strInvoiceNumber		
			,strInvoiceReportNumber
			,dtmDiscountDate		
			,dtmDueDate			
			,dtmTransactionDate	
			,dtmPostedDate		
			,strTransactionType	
			,intNetworkId
			FROM ##tmpInvoiceFee

			-------------SET GROUP VOLUME TO OUTPUT---------------
			DECLARE @dblTotalQuantity		NUMERIC(18,6)
			DECLARE @dblTotalAmount			NUMERIC(18,6)
			DECLARE @intTotalTransaction	INT
			DECLARE @intTotalCard			INT
			DECLARE @intTotalActiveCard		INT
			DECLARE @intTotalNewCard		INT
			DECLARE @dtmLastBillingDate		DATETIME
			DECLARE @intFeeProfileId		INT			
			DECLARE @dtmInvoiceDate			DATETIME	
			DECLARE @strInvoiceReportNumber NVARCHAR(MAX)
			DECLARE @intCustomerId			INT
			DECLARE @intTermID				INT
			DECLARE @intSalesPersonId		INT
			
			
			WHILE (EXISTS(SELECT 1 FROM @tblCFInvoiceFeesTemp))
			BEGIN
			
				---GET ACCOUNT AND FEE PROFILE ID---
				SELECT TOP 1
				 @intLoopId					= intAccountId 
				,@intFeeProfileId			= intFeeProfileId
				,@dtmInvoiceDate			= dtmInvoiceDate
				,@strInvoiceReportNumber	= strInvoiceReportNumber
				,@intCustomerId				= intCustomerId
				,@intTermID					= intTermID
				,@intSalesPersonId			= intSalesPersonId
				FROM @tblCFInvoiceFeesTemp

				---GET LAST BILLING CYCLE DATE---
				SELECT TOP 1
				@dtmLastBillingDate = dtmLastBillingCycleDate
				FROM tblCFAccount
				WHERE intAccountId = @intLoopId

				IF (@intFeeProfileId IS NOT NULL AND @intFeeProfileId > 0)
				BEGIN
				
					DECLARE @intFeeLoopId			INT
					DECLARE @ysnLocalTrans			BIT = 0
					DECLARE @ysnRemoteTrans			BIT = 0
					DECLARE @ysnExtRemoteTrans		BIT = 0
					DECLARE @ysnForeignTrans		BIT = 0
					DECLARE @strCalculationType		NVARCHAR(MAX)
					DECLARE @intMinimumThreshold	INT
					DECLARE @intMaximumThreshold	INT
					DECLARE @intNetworkId			INT
					DECLARE @intCardTypeId			INT
					

					

					----------GET FEE DETAILS------------
				INSERT INTO @tblCFInvoiceFeeDetail
				(
				 intFeeProfileId				
				,strFeeProfileId				
				,strFeeProfileDescription		
				,strInvoiceFormat				
				,intFeeProfileDetailId			
				,strFeeProfileDetailDescription	
				,dtmEndDate						
				,dtmStartDate					
				,intFeeId						
				,strFee							
				,strFeeDescription				
				,strCalculationType				
				,strCalculationFrequency		
				,ysnExtendedRemoteTrans			
				,ysnRemotesTrans				
				,ysnLocalTrans					
				,ysnForeignTrans				
				,intNetworkId					
				,intCardTypeId					
				,intMinimumThreshold			
				,intMaximumThreshold			
				,dblFeeRate						
				,intGLAccountId					
				,intItemId						
				,intRestrictedByProduct			
				)
				SELECT 
				 cffp.intFeeProfileId	
				,strFeeProfileId	
				,cffp.strDescription AS strFeeProfileDescription
				,strInvoiceFormat	
				,intFeeProfileDetailId	
				,cffpd.strDescription AS strFeeProfileDetailDescription
				,dtmEndDate	
				,dtmStartDate	
				,cffpd.intFeeId	
				,strFee	
				,strFeeDescription	
				,strCalculationType	
				,strCalculationFrequency	
				,ysnExtendedRemoteTrans	
				,ysnRemotesTrans	
				,ysnLocalTrans	
				,ysnForeignTrans	
				,intNetworkId	
				,intCardTypeId	
				,intMinimumThreshold	
				,intMaximumThreshold	
				,dblFeeRate	
				,intGLAccountId	
				,intItemId	
				,intRestrictedByProduct	
				FROM tblCFFeeProfile cffp
				INNER JOIN tblCFFeeProfileDetail cffpd
				ON cffp.intFeeProfileId = cffpd.intFeeProfileId
				INNER JOIN tblCFFee cff
				ON cffpd.intFeeId = cff.intFeeId
				WHERE cffp.intFeeProfileId = @intFeeProfileId
					----------GET FEE DETAILS------------
					WHILE (EXISTS(SELECT 1 FROM @tblCFInvoiceFeeDetail))
					BEGIN
					
						---GET FEES SETTINGS/CONFIGS---
						SELECT TOP 1 
						 @intFeeLoopId			= intFeeId
						,@ysnLocalTrans			= ysnLocalTrans
						,@ysnRemoteTrans		= ysnRemotesTrans
						,@ysnExtRemoteTrans		= ysnExtendedRemoteTrans
						,@ysnForeignTrans		= ysnForeignTrans
						,@strCalculationType	= strCalculationType
						,@intMinimumThreshold	= intMinimumThreshold
						,@intMaximumThreshold	= intMaximumThreshold
						,@intNetworkId			= intNetworkId
						,@intCardTypeId			= intCardTypeId
						FROM @tblCFInvoiceFeeDetail


						
						---GET TOTAL NO. OF CARD / TOTAL NO. OF TRANS / TOTAL QUANTITY / TOTAL AMOUNT / INVOICE DATE---
						IF(@strCalculationType = 'Unit' OR @strCalculationType = 'Transaction')
						BEGIN
							SELECT 
							 @intTotalTransaction	= ISNULL(COUNT(*),0)
							,@dblTotalQuantity		= ISNULL(SUM(dblQuantity),0)
							FROM @tblCFInvoiceFeesTemp 
							WHERE intAccountId = @intLoopId
							AND intNetworkId = @intNetworkId
							AND dblQuantity != 0
							AND (dblQuantity < @intMinimumThreshold OR dblQuantity > @intMaximumThreshold)
							AND 
							((strTransactionType = 'Local/Network' AND @ysnLocalTrans = 1)
							 OR (strTransactionType = 'Remote' AND @ysnRemoteTrans = 1)
							 OR (strTransactionType = 'Extended Remote' AND @ysnExtRemoteTrans = 1
							 OR (strTransactionType = 'Foreign Sale' AND @ysnForeignTrans = 1)))

						END

						IF(@strCalculationType = 'Percentage')
						BEGIN
							SELECT 
							@dblTotalAmount		= ISNULL(SUM(dblTotalAmount),0)
							FROM @tblCFInvoiceFeesTemp WHERE intAccountId = @intLoopId
							AND intNetworkId = @intNetworkId
							
						END

						  ---GET TOTAL NO. OF CARDS---
						IF(@strCalculationType = 'All Cards')
						BEGIN
							SELECT 
							@intTotalCard = ISNULL(COUNT(DISTINCT(cfcards.intCardId)),0)
							FROM @tblCFInvoiceFeesTemp cftrans
							INNER JOIN tblCFCard cfcards
							ON cftrans.intCardId = cfcards.intCardId
							WHERE cftrans.intAccountId = @intLoopId 
							AND cftrans.intNetworkId = @intNetworkId
							AND cfcards.intCardTypeId = @intCardTypeId
						END


						 ---GET TOTAL NO. OF ACTIVE CARD---
						IF(@strCalculationType = 'Active Cards')
						BEGIN
							SELECT 
							@intTotalActiveCard = ISNULL(COUNT(DISTINCT(cfcards.intCardId)),0)
							FROM @tblCFInvoiceFeesTemp cftrans
							INNER JOIN tblCFCard cfcards
							ON cftrans.intCardId = cfcards.intCardId
							WHERE cftrans.intAccountId = @intLoopId 
							AND cftrans.intNetworkId = @intNetworkId
							AND cfcards.intCardTypeId = @intCardTypeId
							AND cfcards.ysnActive = 1
						END

						 ---GET TOTAL NO. OF NEW CARD---
						
						IF (@dtmLastBillingDate IS NOT NULL)
						BEGIN
							IF(@strCalculationType = 'New Cards')
							BEGIN
								SELECT 
								@intTotalNewCard = ISNULL(COUNT(DISTINCT(cfcards.intCardId)),0)
								FROM @tblCFInvoiceFeesTemp cftrans
								INNER JOIN tblCFCard cfcards
								ON cftrans.intCardId = cfcards.intCardId
								WHERE cftrans.intAccountId = @intLoopId  
								AND cftrans.intNetworkId = @intNetworkId
								AND cfcards.intCardTypeId = @intCardTypeId
								AND cfcards.dtmIssueDate > @dtmLastBillingDate
							END
						END
						ELSE
						BEGIN
							SET @intTotalNewCard = @intTotalCard
						END


					INSERT INTO ##tblCFInvoiceFeeOutput(
						 intFeeLoopId	
						,intAccountId		
						,strCalculationType
						,dblFeeRate		
						,dtmStartDate		
						,dtmEndDate		
						,strFeeDescription
						,strFee	
						,strInvoiceFormat
						,dblFeeAmount	
						,strInvoiceReportNumber
						,intCustomerId
						,intTermID
						,intSalesPersonId
						,dtmInvoiceDate
						,intItemId
					)
					SELECT 
						 @intFeeLoopId
						,@intLoopId
						,strCalculationType
						,dblFeeRate
						,dtmStartDate
						,dtmEndDate
						,strFeeDescription
						,strFee
						,strInvoiceFormat
						,dblFeeAmount = 
						( 
							CASE 
								WHEN @dtmInvoiceDate >= cffee.dtmStartDate AND @dtmInvoiceDate <= cffee.dtmEndDate
									THEN
										 CASE 
											 WHEN cffee.strCalculationType = 'Transaction' AND (cffee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
												THEN ROUND((@intTotalTransaction * cffee.dblFeeRate),2)
											 WHEN cffee.strCalculationType = 'Unit' AND (cffee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
												THEN ROUND((@dblTotalQuantity * cffee.dblFeeRate),2)
											 WHEN cffee.strCalculationType = 'All Cards'  AND (cffee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
												THEN ROUND((@intTotalCard * cffee.dblFeeRate),2)
											 WHEN cffee.strCalculationType = 'Active Cards' AND (cffee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
												THEN ROUND((@intTotalActiveCard * cffee.dblFeeRate),2)
											 WHEN cffee.strCalculationType = 'New Cards' AND (cffee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
												THEN ROUND((@intTotalNewCard * cffee.dblFeeRate),2)
											 WHEN cffee.strCalculationType = 'Flat' 
											 AND ((cffee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
											 OR (cffee.strCalculationFrequency = 'Annual' AND @ysnInvoiceAnnualFee = 1)
											 OR (cffee.strCalculationFrequency = 'Monthy' AND @ysnInvoiceMonthyFee = 1)
											 )
												THEN ROUND((cffee.dblFeeRate),2)
											 WHEN cffee.strCalculationType = 'Percentage' AND (cffee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
												THEN ROUND(((@dblTotalAmount * (cffee.dblFeeRate / 100))),2)
											 ELSE
												NULL
										END
							END 
						)
						,@strInvoiceReportNumber
						,@intCustomerId				
						,@intTermID					
						,@intSalesPersonId	
						,@dtmInvoiceDate	
						,intItemId	
						FROM @tblCFInvoiceFeeDetail cffee
						WHERE intFeeId = @intFeeLoopId
						GROUP BY 
						 cffee.strCalculationType
						,cffee.dblFeeRate
						,cffee.dtmStartDate
						,cffee.dtmEndDate
						,cffee.strFeeDescription
						,cffee.strFee
						,cffee.strCalculationFrequency
						,cffee.strInvoiceFormat
						,cffee.intItemId


						DELETE FROM @tblCFInvoiceFeeDetail WHERE intFeeId = @intFeeLoopId
						END

					DELETE FROM @tblCFInvoiceFeesTemp WHERE intAccountId = @intLoopId
					END
				ELSE
					BEGIN
						DELETE FROM @tblCFInvoiceFeesTemp WHERE intAccountId = @intLoopId
					END
				END
				
			END
			
			-------------SET GROUP VOLUME TO OUTPUT---------------


			----------------------------------
			---**END DISCOUNT CALCULATION**---
			----------------------------------

			-------------SELECT MAIN TABLE FOR OUTPUT---------------
			SELECT 
			 intFeeLoopId			
			,intAccountId			
			,strCalculationType	
			,dblFeeRate			
			,intTransactionId		
			,dtmTransactionDate	
			,dtmStartDate			
			,dtmEndDate			
			,dblQuantity			
			,intCardId				
			,dblFeeAmount			
			,strFeeDescription		
			,strFee				
			,strInvoiceFormat		
			,strInvoiceReportNumber
			,intCustomerId			
			,intTermID				
			,intSalesPersonId		
			,dtmInvoiceDate
			,dblFeeTotalAmount = (SELECT ROUND(SUM(dblFeeAmount),2) FROM ##tblCFInvoiceFeeOutput) 
			,intItemId
			FROM ##tblCFInvoiceFeeOutput
					
			-------------SELECT MAIN TABLE FOR OUTPUT---------------

			-------------DROP TEMPORARY TABLES---------------
			IF OBJECT_ID(N'tempdb..##tmpInvoiceFee', N'U') IS NOT NULL 
			DROP TABLE ##tmpInvoiceFee;

			IF OBJECT_ID(N'tempdb..##tblCFInvoiceFeeOutput', N'U') IS NOT NULL 
			DROP TABLE ##tblCFInvoiceFeeOutput;
			-------------DROP TEMPORARY TABLES---------------
		END TRY
		BEGIN CATCH
			
			declare @error int, @message varchar(4000), @xstate int;
			select @error = ERROR_NUMBER(),
            @message = ERROR_MESSAGE(), 
            @xstate = XACT_STATE();
			
			-------------DROP TEMPORARY TABLES---------------
			IF OBJECT_ID(N'tempdb..##tmpInvoiceFee', N'U') IS NOT NULL 
			DROP TABLE ##tmpInvoiceFee;

			IF OBJECT_ID(N'tempdb..##tblCFInvoiceFeeOutput', N'U') IS NOT NULL 
			DROP TABLE ##tblCFInvoiceFeeOutput;
			-------------DROP TEMPORARY TABLES---------------
		END CATCH
END