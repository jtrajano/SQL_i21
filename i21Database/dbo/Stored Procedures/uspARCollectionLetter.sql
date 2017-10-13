﻿CREATE PROCEDURE [dbo].[uspARCollectionLetter]  
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN
	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS ON  

	DECLARE @idoc					INT
		  , @strCustomerIds			NVARCHAR(MAX)		
		  , @intLetterId			INT
		  , @strLetterId			NVARCHAR(10)
		  , @ysnSystemDefined		BIT  
		  , @strLetterName			NVARCHAR(MAX)
		  , @strMessage				NVARCHAR(MAX)				
		  , @query					NVARCHAR(MAX)
		  , @intEntityCustomerId	INT
		  , @blb					VARBINARY(MAX)
		  , @originalMsgInHTML		VARCHAR(MAX)	
		  , @filterValue			VARCHAR(MAX)	
		  , @intSourceLetterId		INT										
		
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
	DECLARE @temp_params TABLE (
		  [fieldname]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [condition]		NVARCHAR(20)	COLLATE Latin1_General_CI_AS    
		, [from]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS
		, [to]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [join]			NVARCHAR(10)	COLLATE Latin1_General_CI_AS
		, [begingroup]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [endgroup]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [datatype]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	) 

	INSERT INTO @temp_params
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
	WITH (	
		  [fieldname]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [condition]	NVARCHAR(20)	COLLATE Latin1_General_CI_AS
		, [from]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS
		, [to]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [join]		NVARCHAR(10)	COLLATE Latin1_General_CI_AS
		, [begingroup]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [endgroup]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS
		, [datatype]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	)

	SELECT @strCustomerIds = [from]		
	FROM @temp_params 
	WHERE [fieldname] = 'intEntityCustomerId' 

	SELECT @intLetterId = [from]
	FROM @temp_params 
	WHERE [fieldname] = 'intLetterId'
		
	SET @strLetterId = CAST(@intLetterId AS NVARCHAR(10))


	SELECT @intSourceLetterId = intSourceLetterId FROM tblSMLetter WITH(NOLOCK) WHERE intLetterId = @intLetterId
	IF (@intSourceLetterId IS NULL OR @intSourceLetterId = '')
	BEGIN
		SELECT @strLetterName = strName FROM tblSMLetter WITH(NOLOCK) WHERE intLetterId = @intLetterId
	END
	ELSE
	BEGIN
		SELECT @strLetterName = strName FROM tblSMLetter WITH(NOLOCK) WHERE intLetterId = @intSourceLetterId
	END

	SELECT @strLetterName		= strName
		 , @strMessage			= CONVERT(VARCHAR(MAX), blbMessage)
		 , @blb					= blbMessage 
		 , @ysnSystemDefined	= ysnSystemDefined 
	FROM tblSMLetter WITH(NOLOCK) 
	WHERE intLetterId = @intLetterId

	IF ISNULL(@strCustomerIds, '') = '' AND ISNULL(@ysnSystemDefined, 1) = 1
		BEGIN
			IF @strLetterName NOT IN ('Credit Suspension', 'Expired Credit Card', 'Credit Review', 'Service Charge Invoices Letter')
				BEGIN
					SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
					FROM (
						SELECT CAST(intEntityCustomerId AS VARCHAR(200))  + ', '
						FROM tblARCollectionOverdue WITH(NOLOCK)
						FOR XML PATH ('')
					) c (intEntityCustomerId)
				END
			ELSE IF @strLetterName = 'Service Charge Invoices Letter' 
				BEGIN
					SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
					FROM (
						SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(200))  + ', '
						FROM vyuARServiceChargeInvoiceReport WITH(NOLOCK)
						FOR XML PATH ('')
					) c (intEntityCustomerId)
				END
		END
	
	SET @strCustomerIds = REPLACE (@strCustomerIds, '|^|', ',')
	SET @strCustomerIds = REVERSE(SUBSTRING(REVERSE(@strCustomerIds),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)),LEN(@strCustomerIds) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)) - 1)	) )
	
	DECLARE @OriginalMsgInHTMLTable TABLE  (
		msgAsHTML VARCHAR(max)
	);

	DECLARE @SelectedPlaceHolderTable TABLE  (
		intPlaceHolderId				INT
		, strPlaceHolder				VARCHAR(MAX)
		, strSourceColumn				NVARCHAR(200)	COLLATE Latin1_General_CI_AS
		, strPlaceHolderDescription		NVARCHAR(200)	COLLATE Latin1_General_CI_AS
		, strSourceTable				NVARCHAR(200)	COLLATE Latin1_General_CI_AS
		, ysnTable						INT
		, strDataType					VARCHAR(MAX)	COLLATE Latin1_General_CI_AS
	);
				
 	DECLARE @SelectedCustomer TABLE  (
		intEntityCustomerId		INT
	);
	
	IF OBJECT_ID('tempdb..#CustomerPlaceHolder') IS NOT NULL DROP TABLE #CustomerPlaceHolder	
	CREATE TABLE #CustomerPlaceHolder (
		[intPlaceHolderId]		INT NOT NULL,
		[strPlaceHolder]		VARCHAR(MAX)	COLLATE Latin1_General_CI_AS,
		[intEntityCustomerId]	INT NOT NULL,
		[strValue]				VARCHAR(MAX)	COLLATE Latin1_General_CI_AS
	)

	IF OBJECT_ID('tempdb..#TransactionLetterDetail') IS NOT NULL DROP TABLE #TransactionLetterDetail	
	CREATE TABLE #TransactionLetterDetail (	
		intEntityCustomerId	INT NOT NULL,
		strInvoiceNumber	VARCHAR(MAX)	COLLATE Latin1_General_CI_AS, 
		dtmDate				DATETIME, 
		dbl10Days			NUMERIC(18,6), 
		dbl30Days			NUMERIC(18,6), 
		dbl60Days			NUMERIC(18,6), 
		dbl90Days			NUMERIC(18,6), 
		dbl120Days			NUMERIC(18,6), 
		dbl121Days			NUMERIC(18,6),
		dblAmount			NUMERIC(18,6),
		dtmDueDate			DATETIME, 
		strTerm				NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	)

	IF ISNULL(@strCustomerIds, '') = '' AND ISNULL(@ysnSystemDefined, 1) = 1
		BEGIN
			IF @strLetterName IN ('Credit Suspension', 'Expired Credit Card')
				BEGIN
					INSERT INTO @SelectedCustomer
					SELECT intEntityId
					FROM tblARCustomer WITH (NOLOCK)
					WHERE ysnActive = 1
					  AND dblCreditLimit = 0
				END
			ELSE IF @strLetterName = 'Credit Review'
				BEGIN
					INSERT INTO @SelectedCustomer
					SELECT intEntityId
					FROM tblARCustomer WITH (NOLOCK)
					WHERE ysnActive = 1
					  AND dblCreditLimit > 0
				END
			ELSE
				BEGIN
					INSERT INTO @SelectedCustomer
					SELECT * 
					FROM fnGetRowsFromDelimitedValues(@strCustomerIds)
				END
		END
	ELSE IF ISNULL(@strCustomerIds, '') = '' AND ISNULL(@ysnSystemDefined, 1) = 0
		BEGIN
			INSERT INTO @SelectedCustomer
			SELECT intEntityId
			FROM tblARCustomer WITH (NOLOCK)
			WHERE ysnActive = 1
		END
	ELSE IF ISNULL(@strCustomerIds, '') <> ''
		BEGIN
			INSERT INTO @SelectedCustomer
			SELECT * 
			FROM fnGetRowsFromDelimitedValues(@strCustomerIds)
		END

	INSERT INTO @OriginalMsgInHTMLTable
	SELECT CONVERT(VARCHAR(MAX), @blb) 

	SELECT @originalMsgInHTML = msgAsHTML 
	FROM @OriginalMsgInHTMLTable
	 
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
		tblARLetterPlaceHolder WITH(NOLOCK)
	WHERE 
		CHARINDEX ( dbo.fnARRemoveWhiteSpace(strPlaceHolder), dbo.fnARRemoveWhiteSpace(@originalMsgInHTML) ) <> 0
	
	IF ISNULL(@ysnSystemDefined, 1) = 1
		BEGIN
			WHILE EXISTS(SELECT NULL FROM @SelectedCustomer)
				BEGIN
					DECLARE @CustomerId INT
					SELECT TOP 1 @CustomerId = intEntityCustomerId 
					FROM @SelectedCustomer 
					ORDER BY intEntityCustomerId
 
					IF @strLetterName = 'Recent Overdue Collection Letter'
					BEGIN	
						DECLARE @UnpaidRecent TABLE
						(
							snum NVARCHAR(50) COLLATE Latin1_General_CI_AS
						)
						INSERT INTO @UnpaidRecent 
						SELECT strInvoiceNumber FROM tblARInvoice where ysnPaid = 0	
						INSERT INTO #TransactionLetterDetail
						(	
							intEntityCustomerId		
							,strInvoiceNumber	 
							,dtmDate				 
							,dbl10Days			 
							,dbl30Days			 
							,dbl60Days			  
							,dbl90Days			 
							,dbl120Days			 
							,dbl121Days	
							,dblAmount		 
							,dtmDueDate
							,strTerm 
						)
						SELECT 
							intEntityCustomerId 
							, strInvoiceNumber
							, dtmDate
							, dbl10Days
							, dbl30Days
							, dbl60Days
							, dbl90Days
							, dbl120Days
							, dbl121Days
							, 0
							, GETDATE()
							, NULL
						FROM
						( 
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @UnpaidRecent)
							AND dbl10Days <> 0
							UNION ALL 
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @UnpaidRecent)
							AND dbl30Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @UnpaidRecent)
							AND dbl60Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @UnpaidRecent)
							AND dbl90Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @UnpaidRecent)
							AND dbl120Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @UnpaidRecent)
							AND dbl121Days  <> 0
						) ABC

						UPDATE 
							tblARCollectionOverdue SET dbl10DaysSum = ABC.dblTotalDueSum
						FROM 
							(SELECT dblTotalDueSum = (SUM(dbl10Days) + SUM(dbl30Days) + SUM(dbl60Days) + SUM(dbl90Days) + SUM(dbl120Days) + SUM(dbl121Days)) FROM #TransactionLetterDetail WHERE intEntityCustomerId = @CustomerId) ABC
 						WHERE 
							intEntityCustomerId = @CustomerId 

					END
					ELSE IF @strLetterName = '30 Day Overdue Collection Letter'					
					BEGIN
						DECLARE @Unpaid30Invoice TABLE
						(
							snum NVARCHAR(50) COLLATE Latin1_General_CI_AS
						)
						INSERT INTO @Unpaid30Invoice 
						SELECT strInvoiceNumber FROM tblARInvoice where ysnPaid = 0
				
						INSERT INTO #TransactionLetterDetail
						(
							intEntityCustomerId 
							,strInvoiceNumber	 
							,dtmDate				 
							,dbl10Days			 
							,dbl30Days			 
							,dbl60Days			  
							,dbl90Days			 
							,dbl120Days			 
							,dbl121Days	
							,dblAmount		 
							,dtmDueDate
							,strTerm
						)
						SELECT intEntityCustomerId 
							, strInvoiceNumber
							, dtmDate
							, dbl10Days
							, dbl30Days
							, dbl60Days
							, dbl90Days
							, dbl120Days
							, dbl121Days
							, 0
							, GETDATE()
							, NULL
						FROM
						( 
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId
							AND dbl60Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId
							AND dbl90Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId,strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId
							AND dbl120Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId
							AND dbl121Days  <> 0
						) ABC
							WHERE strInvoiceNumber IN ( SELECT snum FROM @Unpaid30Invoice)

						UPDATE 
							tblARCollectionOverdue SET dbl30DaysSum = ABC.dblTotalDueSum
						FROM 
							(SELECT dblTotalDueSum = (SUM(dbl60Days) + SUM(dbl90Days) + SUM(dbl120Days) + SUM(dbl121Days)) FROM #TransactionLetterDetail WHERE intEntityCustomerId = @CustomerId) ABC
 						WHERE 
							intEntityCustomerId = @CustomerId 

					END
					ELSE IF @strLetterName = '60 Day Overdue Collection Letter'					
					BEGIN
						DECLARE @Unpaid60Invoice TABLE
						(
							snum NVARCHAR(50) COLLATE Latin1_General_CI_AS
						)
						INSERT INTO @Unpaid60Invoice 
						SELECT strInvoiceNumber FROM tblARInvoice where ysnPaid = 0		
						INSERT INTO #TransactionLetterDetail
						(
							intEntityCustomerId
							,strInvoiceNumber	 
							,dtmDate				 
							,dbl10Days			 
							,dbl30Days			 
							,dbl60Days			  
							,dbl90Days			 
							,dbl120Days			 
							,dbl121Days	
							,dblAmount		
							,dtmDueDate
							,strTerm 
						)
						SELECT intEntityCustomerId
							, strInvoiceNumber
							, dtmDate
							, dbl10Days
							, dbl30Days
							, dbl60Days
							, dbl90Days
							, dbl120Days
							, dbl121Days
							, 0
							, GETDATE()
							, NULL
						FROM
						( 
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @Unpaid60Invoice)
							AND dbl90Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @Unpaid60Invoice)
							AND dbl120Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND strInvoiceNumber IN ( SELECT snum FROM @Unpaid60Invoice)
							AND dbl121Days  <> 0
						) ABC

						UPDATE 
							tblARCollectionOverdue SET dbl60DaysSum = ABC.dblTotalDueSum
						FROM 
							(SELECT dblTotalDueSum = (SUM(dbl90Days) + SUM(dbl120Days) + SUM(dbl121Days)) FROM #TransactionLetterDetail WHERE intEntityCustomerId = @CustomerId) ABC
 						WHERE 
							intEntityCustomerId = @CustomerId 
					END
					ELSE IF @strLetterName = '90 Day Overdue Collection Letter'					
					BEGIN				
						DECLARE @UnpaidInvoice TABLE
						(
							id int
						)
						INSERT INTO @UnpaidInvoice 
						SELECT intInvoiceId FROM tblARInvoice where ysnPaid = 0

						INSERT INTO #TransactionLetterDetail
						(
							intEntityCustomerId
							,strInvoiceNumber	 
							,dtmDate				 
							,dbl10Days			 
							,dbl30Days			 
							,dbl60Days			  
							,dbl90Days			 
							,dbl120Days			 
							,dbl121Days		
							,dblAmount	 
							,dtmDueDate
							,strTerm
						)
						SELECT intEntityCustomerId
							, strInvoiceNumber
							, dtmDate
							, dbl10Days
							, dbl30Days
							, dbl60Days
							, dbl90Days
							, dbl120Days
							, dbl121Days
							, 0
							, GETDATE()
							, NULL
						FROM
						( 
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND intInvoiceId in (SELECT id FROM @UnpaidInvoice)
							AND dbl120Days  <> 0
							UNION ALL
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId AND intInvoiceId in (SELECT id FROM @UnpaidInvoice)
							AND dbl121Days  <> 0
						) ABC

						UPDATE 
							tblARCollectionOverdue SET dbl90DaysSum = ABC.dblTotalDueSum
						FROM 
							(SELECT dblTotalDueSum = (SUM(dbl120Days) + SUM(dbl121Days)) FROM #TransactionLetterDetail WHERE intEntityCustomerId = @CustomerId) ABC
 						WHERE 
							intEntityCustomerId = @CustomerId 
					END
					ELSE IF @strLetterName = 'Final Overdue Collection Letter'					
					BEGIN		
						INSERT INTO #TransactionLetterDetail
						(
							intEntityCustomerId
							,strInvoiceNumber	 
							,dtmDate				 
							,dbl10Days			 
							,dbl30Days			 
							,dbl60Days			  
							,dbl90Days			 
							,dbl120Days			 
							,dbl121Days		
							,dblAmount	 
							,dtmDueDate
							,strTerm
						)
						SELECT intEntityCustomerId
							, strInvoiceNumber
							, dtmDate
							, dbl10Days
							, dbl30Days
							, dbl60Days
							, dbl90Days
							, dbl120Days
							, dbl121Days
							, 0
							, GETDATE()
							, NULL
						FROM
						( 
							SELECT intEntityCustomerId, strInvoiceNumber, dtmDate, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl120Days, dbl121Days FROM tblARCollectionOverdueDetail WITH(NOLOCK)
							WHERE intEntityCustomerId = @CustomerId
							AND dbl121Days  <> 0
						) ABC

						UPDATE 
							tblARCollectionOverdue SET dbl121DaysSum = ABC.dblTotalDueSum
						FROM 
							(SELECT dblTotalDueSum = (SUM(dbl121Days)) FROM #TransactionLetterDetail WHERE intEntityCustomerId = @CustomerId) ABC
 						WHERE 
							intEntityCustomerId = @CustomerId 
					END	
					ELSE IF @strLetterName = 'Service Charge Invoices Letter'
						BEGIN
							INSERT INTO #TransactionLetterDetail
							(
								intEntityCustomerId
								,strInvoiceNumber	 
								,dtmDate				 
								,dbl10Days			 
								,dbl30Days			 
								,dbl60Days			  
								,dbl90Days			 
								,dbl120Days			 
								,dbl121Days		
								,dblAmount	 
								,dtmDueDate
								,strTerm
							)
							SELECT intEntityCustomerId
								, strInvoiceNumber
								, dtmDate							 
								, 0	dbl10Days		 
								, 0	dbl30Days		 
								, 0	dbl60Days		  
								, 0 dbl90Days			 
								, 0 dbl120Days			 
								, 0	dbl121Days		
								, dblTotalDue
								, dtmDueDate
								, strTerm
							FROM 
								vyuARServiceChargeInvoiceReport WITH(NOLOCK)
						END
								
					WHILE EXISTS(SELECT NULL FROM @SelectedPlaceHolderTable)
					BEGIN
						DECLARE @PlaceHolderId				INT
								,@PlaceHolder				VARCHAR(MAX)	 
								,@SourceColumn				VARCHAR(MAX)	 
								,@PlaceHolderDescription	VARCHAR(MAX)
								,@SourceTable				VARCHAR(MAX)
								,@Table						BIT
								,@PlaceHolderValue			VARCHAR(MAX)
								,@DataType					VARCHAR(MAX)

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
														RowId							INT,
														intEntityCustomerId				INT,
														strValues		VARCHAR(MAX)	COLLATE Latin1_General_CI_AS,
														strDataType		VARCHAR(MAX)	COLLATE Latin1_General_CI_AS								
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
													FROM 
														' + @SourceTable + '  
													WHERE 
														[intEntityCustomerId] = ' + CAST(@CustomerId AS VARCHAR(200))	+ '  

													INSERT INTO 
														#Records 
													(
														RowId
														, intEntityCustomerId
														, strValues
														, strDataType
													)

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
							FROM  
								dbo.fnARSplitValues(@DataType, ',')			
				 
							UPDATE #TempDataType  
							SET strDataType = 'datetime'
							WHERE strDataType LIKE '%time%'

							UPDATE #TempDataType  
							SET strDataType = 'nvarchar'
							WHERE strDataType LIKE '%char%'

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
					
							IF @strLetterName = 'Service Charge Invoices Letter'  									 
							BEGIN
								SET @PHQueryTable = '
								DECLARE @HTMLTableValue NVARCHAR(MAX)
								IF OBJECT_ID(''tempdb..#TempRecords'') IS NOT NULL DROP TABLE #TempRecords
								SELECT 
									RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
									, ' + @SourceColumn + ' 
								INTO 
									#TempRecords
								FROM 
									' + @SourceTable + ' 
								WHERE 
									[intEntityCustomerId] = ' + CAST(@CustomerId AS VARCHAR(200))
								+ ' AND strInvoiceNumber IN (SELECT strInvoiceNumber FROM #TransactionLetterDetail) ORDER BY intInvoiceId DESC

					
   								IF OBJECT_ID(''tempdb..#RecordsNoRowId'') IS NOT NULL DROP TABLE #RecordsNoRowId
								SELECT 		
									RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))						
									, strInvoiceNumber
									, SUM(dblTotalDue) dblTotalDue 
									, strTerm
									, dtmDueDate
								INTO
									#RecordsNoRowId
								FROM 
									#TempRecords 
								GROUP BY strInvoiceNumber
								, strTerm, dtmDueDate				
								
								IF OBJECT_ID(''tempdb..#Records'') IS NOT NULL DROP TABLE #Records
								SELECT 
										RowId
									, INV.dtmDate
									, #RecordsNoRowId.strInvoiceNumber
									, #RecordsNoRowId.dblTotalDue 
									, #RecordsNoRowId.strTerm
									, #RecordsNoRowId.dtmDueDate
								INTO
									#Records
								FROM 
									#RecordsNoRowId
								INNER JOIN (SELECT 
													strInvoiceNumber
													, dtmDate
											FROM 
												tblARInvoice WITH(NOLOCK)
											WHERE 
												strInvoiceNumber IN (SELECT 
																			strInvoiceNumber 
																		FROM 
																		#RecordsNoRowId) ) INV ON #RecordsNoRowId.strInvoiceNumber = INV.strInvoiceNumber				
								ORDER BY INV.dtmDate 
  		
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
										dtmDate		 

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
											CASE WHEN strDataType LIKE ''datetime'' 
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
							END
							ELSE
							BEGIN
								SET @PHQueryTable = '
								DECLARE @HTMLTableValue NVARCHAR(MAX)
								IF OBJECT_ID(''tempdb..#TempRecords'') IS NOT NULL DROP TABLE #TempRecords
								SELECT 
									RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
									, ' + @SourceColumn + ' 
								INTO 
									#TempRecords
								FROM 
									' + @SourceTable + ' 
								WHERE 
									[intEntityCustomerId] = ' + CAST(@CustomerId AS VARCHAR(200))
								+ ' AND strInvoiceNumber IN (SELECT strInvoiceNumber FROM #TransactionLetterDetail) ORDER BY intInvoiceId DESC
				 
 
  								IF OBJECT_ID(''tempdb..#RecordsNoRowId'') IS NOT NULL DROP TABLE #RecordsNoRowId
								SELECT 		
									RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))						
									, strInvoiceNumber
									, SUM(dblTotalDue) dblTotalDue 
								INTO
									#RecordsNoRowId
								FROM 
									#TempRecords 
								GROUP BY strInvoiceNumber
					
								
								IF OBJECT_ID(''tempdb..#Records'') IS NOT NULL DROP TABLE #Records
								SELECT 
										RowId
									, INV.dtmDate
									, #RecordsNoRowId.strInvoiceNumber
									, #RecordsNoRowId.dblTotalDue 
								INTO
									#Records
								FROM 
									#RecordsNoRowId
								INNER JOIN (SELECT 
													strInvoiceNumber
													, dtmDate
											FROM 
												tblARInvoice WITH(NOLOCK)
											WHERE 
												strInvoiceNumber IN (SELECT 
																			strInvoiceNumber 
																		FROM 
																		#RecordsNoRowId) ) INV ON #RecordsNoRowId.strInvoiceNumber = INV.strInvoiceNumber				
								ORDER BY INV.dtmDate 
   						 
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
										dtmDate		 

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
							END


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

					DELETE FROM @SelectedCustomer 
					WHERE intEntityCustomerId = @CustomerId 

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
						tblARLetterPlaceHolder WITH(NOLOCK)
					WHERE 
						CHARINDEX ( dbo.fnARRemoveWhiteSpace(strPlaceHolder), dbo.fnARRemoveWhiteSpace(@originalMsgInHTML) ) <> 0
				END
		END

	DECLARE @PlaceHolderTable AS PlaceHolderTable
	
	INSERT INTO @PlaceHolderTable(
		   intPlaceHolderId
		 , strPlaceHolder
		 , intEntityCustomerId
		 , strPlaceValue
	)
	SELECT intPlaceHolderId		= [intPlaceHolderId]
		 , strPlaceHolder		= [strPlaceHolder]
		 , intEntityCustomerId	= [intEntityCustomerId]
		 , strPlaceValue		= [strValue]
	FROM #CustomerPlaceHolder

	IF ISNULL(@strCustomerIds, '') = '' AND ISNULL(@ysnSystemDefined, 1) = 1
		BEGIN
			IF @strLetterName IN ('Credit Suspension', 'Expired Credit Card')
				BEGIN
					INSERT INTO @SelectedCustomer
					SELECT intEntityId
					FROM tblARCustomer WITH (NOLOCK)
					WHERE ysnActive = 1
					  AND dblCreditLimit = 0
				END
			ELSE IF @strLetterName = 'Credit Review'
				BEGIN
					INSERT INTO @SelectedCustomer
					SELECT intEntityId
					FROM tblARCustomer WITH (NOLOCK)
					WHERE ysnActive = 1
					  AND dblCreditLimit > 0
				END
			ELSE
				BEGIN
					INSERT INTO @SelectedCustomer
					SELECT * 
					FROM fnGetRowsFromDelimitedValues(@strCustomerIds)
				END
		END
	ELSE IF ISNULL(@strCustomerIds, '') = '' AND (ISNULL(@ysnSystemDefined, 1) = 0 OR @strLetterName IN ('Credit Suspension', 'Expired Credit Card', 'Credit Review'))
		BEGIN
			INSERT INTO @SelectedCustomer
			SELECT intEntityId
			FROM tblARCustomer WITH (NOLOCK)
			WHERE ysnActive = 1
		END
	ELSE IF ISNULL(@strCustomerIds, '') <> ''
		BEGIN
			INSERT INTO @SelectedCustomer
			SELECT * 
			FROM fnGetRowsFromDelimitedValues(@strCustomerIds)
		END

	SELECT SC.*
		, blbMessage			= dbo.[fnARConvertLetterMessage](@strMessage, SC.intEntityCustomerId , @PlaceHolderTable)
		, strCompanyName		= COMPANY.strCompanyName
		, strCompanyAddress		= COMPANY.strCompanyAddress
		, strCompanyPhone		= COMPANY.strCompanyPhone
		, strCustomerAddress	= [dbo].fnARFormatLetterAddress(CUSTOMER.strBillToPhone, NULL, CUSTOMER.strCustomerNumber + ' - ' + CUSTOMER.strName, CUSTOMER.strBillToAddress, CUSTOMER.strBillToCity, CUSTOMER.strBillToState, CUSTOMER.strBillToZipCode, CUSTOMER.strBillToCountry, NULL, NULL)
								  + CHAR(13) + ISNULL(CUSTOMER.strAccountNumber, '')
		, strAccountNumber		= CUSTOMER.strAccountNumber
		, strCompanyFax			= COMPANY.strCompanyFax
		, strCompanyEmail		= COMPANY.strCompanyEmail		
	FROM @SelectedCustomer SC
	INNER JOIN (
		SELECT intEntityId
			 , strCustomerNumber
			 , strName
			 , strAccountNumber
			 , strBillToAddress
			 , strBillToCity
			 , strBillToCountry
			 , strBillToLocationName
			 , strBillToState 
			 , strBillToZipCode
			 , strBillToPhone
			 , intTermsId
		FROM vyuARCustomerSearch WITH (NOLOCK)
	) CUSTOMER ON SC.intEntityCustomerId = CUSTOMER.intEntityId
	OUTER APPLY (
		SELECT TOP 1 
			  strCompanyName
			, strCompanyAddress	= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL)
			, strCompanyPhone	= strPhone
			, strCompanyFax		= strFax
			, strCompanyEmail	= strEmail
		FROM tblSMCompanySetup WITH(NOLOCK)
	) COMPANY
END