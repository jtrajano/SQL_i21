CREATE PROCEDURE [dbo].[uspARCollectionLetter]  
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @idoc						INT
			, @strCustomerIds			NVARCHAR(MAX)		
			, @intLetterId				INT
			, @strLetterId				NVARCHAR(10)  
			 ,@LetterName				NVARCHAR(MAX)				
			, @query					NVARCHAR(MAX)
			, @intEntityCustomerId		INT
			, @blb						VARBINARY(MAX)
			, @originalMsgInHTML		VARCHAR(MAX)	
			, @filterValue				VARCHAR(MAX)										
		
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
	DECLARE @temp_params TABLE (
					[fieldname]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [condition]		NVARCHAR(20)   COLLATE Latin1_General_CI_AS    
				, [from]			NVARCHAR(MAX)
				, [to]				NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS
				, [begingroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [datatype]		NVARCHAR(100) COLLATE Latin1_General_CI_AS
				) 
	INSERT INTO 
		@temp_params
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
	WITH (	
			[fieldname]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, [condition]		NVARCHAR(20) COLLATE Latin1_General_CI_AS
			, [from]			NVARCHAR(MAX)
			, [to]				NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, [join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS
			, [begingroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, [endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, [datatype]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
			)
	SELECT 
		@strCustomerIds = [from]		
	FROM 
		@temp_params 
	WHERE 
		[fieldname] = 'intEntityCustomerId' 

	IF (@strCustomerIds IS NULL OR @strCustomerIds = '')
	BEGIN
		SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
		FROM (
			SELECT CAST(intEntityCustomerId AS VARCHAR(200))  + ', '
			FROM vyuARCustomer
			FOR XML PATH ('')
		) c (intEntityCustomerId)
	END
	
	SET @strCustomerIds = REPLACE (@strCustomerIds, '|^|', ',')
	SET @strCustomerIds = REVERSE(SUBSTRING(REVERSE(@strCustomerIds),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)),LEN(@strCustomerIds) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)) - 1)	) )
	
	DECLARE @OriginalMsgInHTMLTable TABLE  (
		msgAsHTML VARCHAR(max)
	);

	SELECT 
		@intLetterId = [from]
	FROM 
		@temp_params 
	WHERE [fieldname] = 'intLetterId'
		
	SET @strLetterId = CAST(@intLetterId AS NVARCHAR(10))

	SELECT @LetterName = strName FROM tblSMLetter WHERE intLetterId = @intLetterId	

	DECLARE @strMessage VARCHAR(MAX)
	SELECT
		@strMessage = CONVERT(VARCHAR(MAX), blbMessage)
	FROM
		tblSMLetter
	WHERE
		intLetterId  = @strLetterId		

	DECLARE @SelectedPlaceHolderTable TABLE  (
		intPlaceHolderId	INT
		, strPlaceHolder	VARCHAR(max)
		, strSourceColumn	NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPlaceHolderDescription	NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strSourceTable	NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, ysnTable			INT
		, strDataType		NVARCHAR(100) COLLATE Latin1_General_CI_AS
	);
				
 	DECLARE @SelectedCustomer TABLE  (
		intEntityCustomerId		INT
	);

	IF OBJECT_ID('tempdb..#CustomerPlaceHolder') IS NOT NULL DROP TABLE #CustomerPlaceHolder	
	CREATE TABLE #CustomerPlaceHolder (
		[intPlaceHolderId] [int] NOT NULL,
		[strPlaceHolder]	VARCHAR(MAX),
		[intEntityCustomerId] [int] NOT NULL,
		[strValue] varchar(MAX)
	)

	INSERT INTO 
		@SelectedCustomer
	SELECT 
		* 
	FROM 
		fnGetRowsFromDelimitedValues(@strCustomerIds)

	SELECT 
		@blb = blbMessage 
	FROM 
		tblSMLetter 
	WHERE 
		intLetterId =@strLetterId

	INSERT INTO 
		@OriginalMsgInHTMLTable
	SELECT 
		CONVERT(VARCHAR(MAX), @blb) 

	SELECT 
		@originalMsgInHTML = msgAsHTML 
	FROM 
		@OriginalMsgInHTMLTable

	IF @LetterName = 'Recent Overdue Collection Letter'
	BEGIN		
		SET @filterValue = 'dbl10DaysSum > 0 OR dbl10DaysSum > 1'
	END
	ELSE IF @LetterName = '30 Day Overdue Collection Letter'					
	BEGIN		
		SET @filterValue = 'dbl30DaysSum > 0 OR dbl30DaysSum > 1'
	END
	ELSE IF @LetterName = '60 Day Overdue Collection Letter'					
	BEGIN		
		SET @filterValue = 'dbl60DaysSum > 0 OR dbl60DaysSum > 1'
	END
	ELSE IF @LetterName = '90 Day Overdue Collection Letter'					
	BEGIN		
		SET @filterValue = 'dbl90DaysSum > 0 OR dbl90DaysSum > 1'
	END
	ELSE IF @LetterName = 'Final Overdue Collection Letter'					
	BEGIN		
		SET @filterValue = '[dbl121DaysSum] > 0 OR [dbl121DaysSum] > 1'
	END
	ELSE IF @LetterName = 'Credit Suspension'					
	BEGIN
		SET @filterValue = '[dblCreditLimit] = 0'
	END
	ELSE IF @LetterName = 'Credit Review'					
	BEGIN
		SET @filterValue = '[dblCreditLimit] > 0'
	END

		 
	INSERT INTO @SelectedPlaceHolderTable
	(
		intPlaceHolderId
		, strPlaceHolder
		, strSourceColumn 
		, strPlaceHolderDescription
		, strSourceTable
		, ysnTable
		, strDataType
	)			
	SELECT 
		intPlaceHolderId
		, strPlaceHolder
		, strSourceColumn
		,strPlaceHolderDescription
		, strSourceTable
		, ysnTable
		, strDataType
	FROM 
		tblARLetterPlaceHolder 
	WHERE 
		CHARINDEX ( dbo.fnARRemoveWhiteSpace(strPlaceHolder), dbo.fnARRemoveWhiteSpace(@originalMsgInHTML) ) <> 0
			
	WHILE EXISTS(SELECT NULL FROM @SelectedCustomer)
	BEGIN
		DECLARE @CustomerId INT
		SELECT TOP 1 @CustomerId = intEntityCustomerId FROM @SelectedCustomer ORDER BY intEntityCustomerId
						
		WHILE EXISTS(SELECT NULL FROM @SelectedPlaceHolderTable)
		BEGIN
			DECLARE @PlaceHolderId				INT
					,@PlaceHolder				VARCHAR(MAX)
					,@SourceColumn				VARCHAR(MAX)
					,@PlaceHolderDescription	VARCHAR(MAX)
					,@SourceTable				VARCHAR(MAX)
					,@Table						BIT
					,@PlaceHolderValue			VARCHAR(MAX)
					,@DataType					NVARCHAR(100)

			SELECT TOP 1 
				@PlaceHolderId				= [intPlaceHolderId]
				,@PlaceHolder				= [strPlaceHolder]
				,@SourceColumn				= [strSourceColumn]
				,@PlaceHolderDescription	= [strPlaceHolderDescription]
				,@SourceTable				= [strSourceTable]
				,@Table						= [ysnTable]
				,@DataType					= [strDataType]
			FROM
				@SelectedPlaceHolderTable 
			ORDER BY [intPlaceHolderId]				
		 
			IF @Table = 0
			BEGIN
				DECLARE @PHQuery		VARCHAR(MAX)
						,@InsertQuery	VARCHAR(MAX)
						,@NotTableQuery	VARCHAR(MAX)

				SET @NotTableQuery = 'DECLARE @SetQuery				VARCHAR(MAX)
												,@InsertQuery		VARCHAR(MAX)							 

										IF OBJECT_ID(''tempdb..#Records'') IS NOT NULL DROP TABLE #Records
										CREATE TABLE #Records(
											RowId			INT,
											intEntityCustomerId		INT,
											strValues		VARCHAR(MAX),
											strDataType		VARCHAR(MAX)								
										)								 

										DECLARE @TermTable TABLE
										(
											intEntityCustomerId INT
											, ' + @SourceColumn + ' nvarchar(max)
										)

										INSERT INTO 
											@TermTable
										(
											intEntityCustomerId
											, ' + @SourceColumn + '
										) 
										SELECT DISTINCT
											intEntityCustomerId
											, ' + @SourceColumn + ' 
										FROM ' + @SourceTable + '  
										WHERE 
											[intEntityCustomerId] = ' + CAST(@CustomerId AS VARCHAR(200))	+ '  

										INSERT INTO #Records (RowId, intEntityCustomerId, strValues, strDataType)

										SELECT TOP 1 
											RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
											, intEntityCustomerId
											, strValues = STUFF((SELECT '', '' + ' + @SourceColumn + ' 												
																FROM 
																	@TermTable 
																WHERE 
																	intEntityCustomerId = t.intEntityCustomerId
																FOR XML PATH(''''), TYPE)
																.value(''.'',''NVARCHAR(MAX)''),1,2,'' '') 
											, strDataType = ''' + @DataType + '''
										FROM 
											@TermTable t
										GROUP BY 
											intEntityCustomerId						 
 				
						 				UPDATE 
											#Records
										SET strValues = 
											CASE WHEN strDataType = ''datetime'' 
												THEN CAST(month(strValues) AS VARCHAR(2)) + ''/'' + CAST(day(strValues) AS VARCHAR(2)) + ''/'' + CAST(year(strValues) AS VARCHAR(4)) 
											ELSE strValues END

						 				UPDATE 
											#Records
										SET 												
											strValues = CONVERT(varchar, CAST(strValues AS money), 1)
										WHERE 
											ISNUMERIC(strValues) = 1
											
										SELECT 
											TOP 1 @SetQuery = strValues 
										FROM 
											#Records	
										 
									SET @InsertQuery= ''''
										INSERT INTO	#CustomerPlaceHolder(
											[intPlaceHolderId],
											[strPlaceHolder],
											[intEntityCustomerId],
											[strValue]
										)
										SELECT
											[intPlaceHolderId]		= ' + CAST(@PlaceHolderId AS VARCHAR(200)) + '
											,[strPlaceHolder]		= ''' + @PlaceHolder + '''
											,[intEntityCustomerId]	= ' + CAST(@CustomerId AS VARCHAR(200)) + ' 
											,[strValue]				= '''' +  @SetQuery  + '''''
											
				EXEC sp_sqlexec @NotTableQuery 			 
			END
		ELSE
			BEGIN
				DECLARE @PHQueryTable		VARCHAR(MAX)
						,@InsertQueryTable	VARCHAR(MAX)
						,@HTMLTable			VARCHAR(MAX)
						,@ColumnCount		INT
						,@ColumnCounter		INT							
 										

				IF OBJECT_ID('tempdb..#TempTableColumnHeaders') IS NOT NULL DROP TABLE #TempTableColumnHeaders
				SELECT 
					RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
					,strValues 
				INTO 
					#TempTableColumnHeaders
				FROM 
					fnARGetRowsFromDelimitedValues(@PlaceHolderDescription)											

				SET @HTMLTable = '<table  id="t01" style="width:100%" border="1"><tbody><tr>'
								
				SET @ColumnCounter = 1
				
				SELECT @ColumnCount = COUNT(RowId) FROM #TempTableColumnHeaders
				 
				WHILE (@ColumnCount >= @ColumnCounter)
				BEGIN
					DECLARE @Header VARCHAR(MAX)
					SELECT TOP 1
						@Header = strValues
					FROM
						#TempTableColumnHeaders
					WHERE
						RowId = @ColumnCounter					 
							
					IF (@Header = 'Amount Due')
					BEGIN
						SET @HTMLTable = @HTMLTable + '<th style="text-align:right"> <span style="font-family: Arial; font-size:9">' + @Header + ' </span> </th> '
					END
					ELSE
					BEGIN
						SET @HTMLTable = @HTMLTable + '<th> <span style="font-family: Arial; font-size:9">' + @Header + ' </span> </th> '
					END
	
					SET @ColumnCounter = @ColumnCounter + 1
				END

				SET @HTMLTable = @HTMLTable + '</tr> '

				IF OBJECT_ID('tempdb..#TempTableColumns') IS NOT NULL DROP TABLE #TempTableColumns
				SELECT 
					RowId			= ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
					,strValues 
					,strDataType	= @DataType
				INTO 
					#TempTableColumns
				FROM 
					fnARGetRowsFromDelimitedValues(@SourceColumn)

				IF OBJECT_ID('tempdb..#TempDataType') IS NOT NULL DROP TABLE #TempDataType
				SELECT 
					RowId	= ROW_NUMBER() OVER (ORDER BY (SELECT NULL))			
					, * 
				INTO  
					#TempDataType 
				FROM dbo.fnARSplitValues(@DataType, ',')			

				UPDATE 
					#TempTableColumns 
				SET 
					strDataType = TDT.strDataType
				FROM 
					#TempDataType TDT
				INNER JOIN 
					#TempTableColumns TDC ON TDT.RowId = TDC.RowId				 
				
				DECLARE @Declaration	VARCHAR(MAX)
						,@Select		VARCHAR(MAX)
				SET @Declaration = ''
				SET @Select = ''
				SET @ColumnCounter = 1

				SELECT 
					@ColumnCount = COUNT(RowId) 
				FROM 
					#TempTableColumns
					 
				WHILE (@ColumnCount >= @ColumnCounter)
				BEGIN
					DECLARE @Colunm VARCHAR(MAX)
					SELECT TOP 1
						@Colunm = strValues
					FROM
						#TempTableColumns
					WHERE
						RowId = @ColumnCounter
							
					SET @Declaration = @Declaration + '@' + @Colunm + ' AS NVARCHAR(200)'  + (CASE WHEN @ColumnCount = @ColumnCounter THEN '' ELSE ',' END)
					SET @Select = @Select + '@' + @Colunm + '= CONVERT(NVARCHAR(200), ' + @Colunm + ')'  + (CASE WHEN @ColumnCount = @ColumnCounter THEN '' ELSE ',' END)					 
					SET @ColumnCounter = @ColumnCounter + 1
				END
						
				IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL DROP TABLE #TempTable
				CREATE TABLE #TempTable(
					strTableBody VARCHAR(MAX)
				)

				INSERT INTO 
					#TempTable
				SELECT 
					@HTMLTable					 

				SET @PHQueryTable = '
				DECLARE @HTMLTableValue NVARCHAR(MAX)
				IF OBJECT_ID(''tempdb..#Records'') IS NOT NULL DROP TABLE #Records
				SELECT 
					RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
					, ' + @SourceColumn + ' 
				INTO 
					#Records
				FROM 
					' + @SourceTable + ' 
				WHERE 
					[intEntityCustomerId] = ' + CAST(@CustomerId AS VARCHAR(200))
				+ ' AND ' + @filterValue + '
												
				DECLARE @HTMLTableRows VARCHAR(MAX)
				SET @HTMLTableRows = ''''

				WHILE EXISTS(SELECT NULL FROM #Records)
				BEGIN
					DECLARE @RowId INT,
						' + @Declaration + '
					SELECT TOP 1
						@RowId = RowId,
						' + @Select + '
					FROM 
						#Records
					ORDER BY
						RowId		 

					SET @HTMLTableRows = @HTMLTableRows + ''<tr> ''

					DECLARE @ColumnCounter1		INT
							,@ColumnCount1		INT
					SET @ColumnCounter1 = 1
					SELECT 
						@ColumnCount1 = COUNT(RowId) 
					FROM 
						#TempTableColumns
				 
					WHILE (@ColumnCount1 >=  @ColumnCounter1)
					BEGIN
						DECLARE @Colunm1	VARCHAR(MAX)
							 ,@DataType1	VARCHAR(MAX)
							 ,@SetQuery		VARCHAR(MAX)

						SELECT TOP 1						 
							@Colunm1 = strValues	
							, @DataType1 = strDataType 				
						FROM
							#TempTableColumns
						WHERE
							RowId = @ColumnCounter1								
						
						IF OBJECT_ID(''tempdb..#Field'') IS NOT NULL DROP TABLE #Field
						CREATE TABLE #Field(
							strDataType		VARCHAR(MAX), 
							strField		VARCHAR(MAX)
						)						
						
						SET @SetQuery = ''INSERT INTO #Field (strDataType, strField) 
						SELECT   
							'''''' +  @DataType1 + '''''' ,
							'' +  @Colunm1 + '' 
						FROM 
							#Records 
						WHERE 
							RowId = '' + CAST(@RowId AS NVARCHAR(100)) 		

						EXEC sp_sqlexec @SetQuery	

						 					UPDATE 
												#Field 
											SET strField = 
												CASE WHEN strDataType = ''datetime'' 
													THEN CAST(month(strField) AS VARCHAR(2)) + ''/'' + CAST(day(strField) AS VARCHAR(2)) + ''/'' + CAST(year(strField) AS VARCHAR(4)) 
												ELSE strField END

						 					UPDATE 
												#Field 
											SET 												
												strField = CONVERT(varchar, CAST(strField AS money), 1)
											WHERE 
												ISNUMERIC(strField) = 1						
												
						DECLARE @isNumeric BIT 
						SET  @isNumeric = 0 
						SELECT 
							TOP 1 @isNumeric = 1  
						FROM 
							#Field 
						WHERE
							ISNUMERIC(strField) = 1		

						IF  (@isNumeric = 1)
						BEGIN
							SET @HTMLTableRows = @HTMLTableRows + ''<td align="right"> <span style="font-family: Arial; font-size:9"> '' + (SELECT TOP 1 strField FROM #Field) + '' </span> </td>''																									
						END
						ELSE
						BEGIN
							SET @HTMLTableRows = @HTMLTableRows + ''<td> <span style="font-family: Arial; font-size:9"> '' + (SELECT TOP 1 strField FROM #Field) + '' </span> </td>''																									
						END
						

						SET @ColumnCounter1 = @ColumnCounter1 + 1
					END

					SET @HTMLTableRows = @HTMLTableRows + '' </tr>''
						
					DELETE 
					FROM 
						#Records 
					WHERE 
						RowId = @RowId
				END

				UPDATE #TempTable
				SET strTableBody = strTableBody + @HTMLTableRows + ''</tbody></table>'''

				EXEC sp_sqlexec @PHQueryTable 				 
									
				SET @InsertQueryTable= '
									INSERT INTO	#CustomerPlaceHolder(
										[intPlaceHolderId],
										[strPlaceHolder],
										[intEntityCustomerId],
										[strValue]
									)
									SELECT
										[intPlaceHolderId]		= ' + CAST(@PlaceHolderId AS VARCHAR(200)) + '
										,[strPlaceHolder]		= ''' + @PlaceHolder + '''
										,[intEntityCustomerId]	= ' + CAST(@CustomerId AS VARCHAR(200)) + '
										,[strValue]				= ''' +  (SELECT TOP 1 strTableBody FROM #TempTable) 	  + ''''
 
 
				EXEC sp_sqlexec @InsertQueryTable 	

			
			END
				
			DELETE 
			FROM 
				@SelectedPlaceHolderTable 
			WHERE
				[intPlaceHolderId] = @PlaceHolderId
		END

		DELETE 
		FROM 
			@SelectedCustomer 
		WHERE 
			intEntityCustomerId = @CustomerId 

		INSERT INTO @SelectedPlaceHolderTable
		(
			intPlaceHolderId
			, strPlaceHolder
			, strSourceColumn 
			, strPlaceHolderDescription
			, strSourceTable
			, ysnTable
			, strDataType
		)			
		SELECT 
			intPlaceHolderId
			, strPlaceHolder
			, strSourceColumn
			,strPlaceHolderDescription
			, strSourceTable
			, ysnTable
			, strDataType
		FROM 
			tblARLetterPlaceHolder 
		WHERE 
			CHARINDEX ( dbo.fnARRemoveWhiteSpace(strPlaceHolder), dbo.fnARRemoveWhiteSpace(@originalMsgInHTML) ) <> 0
	END
	
	DECLARE @PlaceHolderTable AS PlaceHolderTable

	INSERT INTO @PlaceHolderTable(
		intPlaceHolderId
		,strPlaceHolder
		,intEntityCustomerId
		,strPlaceValue
	)
	SELECT
		intPlaceHolderId		= [intPlaceHolderId]
		,strPlaceHolder			= [strPlaceHolder]
		,intEntityCustomerId	= [intEntityCustomerId]
		,strPlaceValue			= [strValue]
	FROM
		#CustomerPlaceHolder

	INSERT INTO 
		@SelectedCustomer
	SELECT 
		* 
	FROM 
		fnGetRowsFromDelimitedValues(@strCustomerIds)

	SELECT
		SC.*
		, blbMessage			= dbo.[fnARConvertLetterMessage](@strMessage, SC.intEntityCustomerId , @PlaceHolderTable)
		, strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
		, strCompanyAddress		= (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
		, strCompanyPhone		= (SELECT TOP 1 strPhone FROM tblSMCompanySetup)
		, strCustomerAddress	= [dbo].fnARFormatCustomerAddress(NULL, NULL, Cus.strName, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, NULL, NULL)
		, strAccountNumber		= (SELECT strAccountNumber FROM tblARCustomer WHERE intEntityCustomerId = SC.intEntityCustomerId)
	FROM
		@SelectedCustomer SC
	INNER JOIN 
		(SELECT 
			intEntityCustomerId, strBillToAddress, strBillToCity, strBillToCountry, strBillToLocationName, strBillToState, strBillToZipCode, intTermsId, strName
		FROM 
			vyuARCustomer) Cus ON SC.intEntityCustomerId = Cus.intEntityCustomerId 

END