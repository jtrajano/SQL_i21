
CREATE PROCEDURE [dbo].[uspCFImportInvoiceCycle]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--============================================--
		--     ONE TIME INVOICE CYCLE SYNCHRONIZATION --
		--============================================--
		
		SET @TotalSuccess = 0
		SET @TotalFailed = 0
		
		--1 Time synchronization here
		PRINT '1 Time Invoice Cycle Synchronization'

		DECLARE @originInvoiceCycle				NVARCHAR(50)

		DECLARE @Counter						INT = 0

		DECLARE @strInvoiceCycle				NVARCHAR(250)
		DECLARE @strDescription					NVARCHAR(250)

		
		--Import only those are not yet imported
		SELECT DISTINCT cfact_ivc_cyc INTO #tmpcfactmst
			FROM cfactmst
				WHERE cfact_ivc_cyc COLLATE Latin1_General_CI_AS NOT IN (select strInvoiceCycle from tblCFInvoiceCycle) 
				AND cfact_ivc_cyc IS NOT NULL

		--DUPLICATE SITE ON i21--

		INSERT INTO tblCFImportResult(
							 dtmImportDate
							,strSetupName
							,ysnSuccessful
							,strFailedReason
							,strOriginTable
							,strOriginIdentityId
							,strI21Table
							,intI21IdentityId
							,strUserId
						)
		SELECT 
		 dtmImportDate = GETDATE()
		,strSetupName = 'Invoice Cycle'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate invoice cycle on i21 Card Fueling invoice cycles list'
		,strOriginTable = 'cfactmst'
		,strOriginIdentityId = cfact_ivc_cyc
		,strI21Table = 'tblCFInvoiceCycle'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfactmst
				WHERE cfact_ivc_cyc COLLATE Latin1_General_CI_AS NOT IN (select strInvoiceCycle from tblCFInvoiceCycle) 
				AND cfact_ivc_cyc IS NOT NULL 
		
		--DUPLICATE SITE ON i21--

		WHILE (EXISTS(SELECT 1 FROM #tmpcfactmst))
		BEGIN
			
			SELECT @originInvoiceCycle = cfact_ivc_cyc FROM #tmpcfactmst

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					 @strInvoiceCycle			 = RTRIM(LTRIM(cfact_ivc_cyc))
					,@strDescription			 = RTRIM(LTRIM(cfact_ivc_cyc))
				FROM cfactmst
				WHERE cfact_ivc_cyc = @originInvoiceCycle
					
				--*********************COMMIT TRANSACTION*****************--
				INSERT [dbo].[tblCFInvoiceCycle](
				 [strInvoiceCycle]	
				,[strDescription])
				VALUES(
				 @strInvoiceCycle	
				,@strDescription)

				   COMMIT TRANSACTION
				--*********************COMMIT TRANSACTION*****************--
				SET @TotalSuccess += 1;
				INSERT INTO tblCFImportResult(
						 dtmImportDate
						,strSetupName
						,ysnSuccessful
						,strFailedReason
						,strOriginTable
						,strOriginIdentityId
						,strI21Table
						,intI21IdentityId
						,strUserId
					)
					VALUES(
						GETDATE()
						,'Invoice Cycle'
						,1
						,''
						,'cfactmst'
						,@originInvoiceCycle
						,'tblCFInvoiceCycle'
						,SCOPE_IDENTITY()
						,''
					)
			END TRY
			BEGIN CATCH
				--*********************ROLLBACK TRANSACTION*****************--
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				
				INSERT INTO tblCFImportResult(
					 dtmImportDate
					,strSetupName
					,ysnSuccessful
					,strFailedReason
					,strOriginTable
					,strOriginIdentityId
					,strI21Table
					,intI21IdentityId
					,strUserId
				)
				VALUES(
					GETDATE()
					,'Invoice Cycle'
					,0
					,ERROR_MESSAGE()
					,'cfactmst'
					,@originInvoiceCycle
					,'tblCFInvoiceCycle'
					,null
					,''
				)
				GOTO CONTINUELOOP;
				--*********************ROLLBACK TRANSACTION*****************--
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			DELETE FROM #tmpcfactmst WHERE cfact_ivc_cyc = @originInvoiceCycle
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess FROM cfactmst
				WHERE cfact_ivc_cyc COLLATE Latin1_General_CI_AS NOT IN (select strInvoiceCycle from tblCFInvoiceCycle) 
				AND cfact_ivc_cyc IS NOT NULL 
		PRINT @TotalFailed

	END