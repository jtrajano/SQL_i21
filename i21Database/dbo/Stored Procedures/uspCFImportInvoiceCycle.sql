
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
					
				
				INSERT [dbo].[tblCFInvoiceCycle](
				 [strInvoiceCycle]	
				,[strDescription])
				VALUES(
				 @strInvoiceCycle	
				,@strDescription)

				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				
			END TRY
			BEGIN CATCH
				PRINT 'IMPORTING INVOICE CYCLE' + ERROR_MESSAGE()
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			PRINT @originInvoiceCycle
			DELETE FROM #tmpcfactmst WHERE cfact_ivc_cyc = @originInvoiceCycle
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END