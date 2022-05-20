GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARSyncTerms')
	DROP PROCEDURE uspARSyncTerms
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

	EXEC('CREATE PROCEDURE uspARSyncTerms  
		   @ToOrigin   bit    = 0  
		   ,@TermCodes  nvarchar(MAX) = ''all''  
		   ,@AddedCount  int    = 0 OUTPUT  
		   ,@UpdatedCount  int    = 0 OUTPUT  
		  AS  
		  BEGIN  
		  
		  DECLARE @RecordsToProcess table(strTermCode nvarchar(2) COLLATE Latin1_General_CI_AS)  
		  DECLARE @RecordsToAdd table(strTermCode varchar(2) COLLATE Latin1_General_CI_AS)  
		  DECLARE @RecordsToUpdate table(strTermCode varchar(2) COLLATE Latin1_General_CI_AS)  
		  
		  DELETE FROM @RecordsToProcess  
		  DELETE FROM @RecordsToAdd  
		  DELETE FROM @RecordsToUpdate  
		    
		  IF(LOWER(@TermCodes) = ''all'')  
		   BEGIN  
			IF (@ToOrigin = 1)  
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT [strTermCode] 
			 FROM tblSMTerm
			 WHERE
				ISNUMERIC(LTRIM(RTRIM([strTermCode]))) = 1
				AND LTRIM(RTRIM([strTermCode])) <= ''99''    
			ELSE  
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT [agtrm_key_n]
			 FROM [agtrmmst]           
		   END  
		  ELSE  
		   BEGIN  
			IF (@ToOrigin = 1)     
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT PM.[strTermCode]  
			 FROM fnGetRowsFromDelimitedValues(@TermCodes) T  
			 INNER JOIN tblSMTerm PM ON T.[intID] = PM.[strTermCode] 
			 WHERE
				ISNUMERIC(LTRIM(RTRIM(PM.[strTermCode]))) = 1
				AND LTRIM(RTRIM(PM.[strTermCode])) <= ''99''      
			ELSE  
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT PM.[agtrm_key_n]  
			 FROM fnGetRowsFromDelimitedValues(@TermCodes) T  
			 INNER JOIN [agtrmmst] PM ON T.[intID] = PM.[agtrm_key_n]  
		   END  
		      
		  IF (@ToOrigin = 1)  
		   INSERT INTO @RecordsToAdd  
		   SELECT T.[strTermCode]  
		   FROM @RecordsToProcess T  
		   LEFT OUTER JOIN [agtrmmst] PM ON T.[strTermCode] = PM.[agtrm_key_n]
		   WHERE PM.[agtrm_key_n] IS NULL   
		  ELSE  
		   INSERT INTO @RecordsToAdd  
		   SELECT T.[strTermCode]  
		   FROM @RecordsToProcess T  
		   LEFT OUTER JOIN tblSMTerm PM ON T.[strTermCode] = PM.[strTermCode]
		   WHERE PM.[strTermCode] IS NULL  
		            
		  INSERT INTO @RecordsToUpdate  
		  SELECT T.[strTermCode]  
		  FROM @RecordsToProcess T  
		  LEFT JOIN @RecordsToAdd A ON T.[strTermCode] = A.[strTermCode]  
		  WHERE A.[strTermCode] IS NULL       
		     
		  IF(@ToOrigin = 1)  
		   BEGIN   
		      
			INSERT INTO [agtrmmst]  
			   ([agtrm_key_n]
			   ,[agtrm_desc]
			   ,[agtrm_disc_pct]
			   ,[agtrm_disc_days]
			   ,[agtrm_disc_rev_dt]
			   ,[agtrm_net_days]
			   ,[agtrm_net_rev_dt]
			   --,[agtrm_age_ind]
			   --,[agtrm_cutoff_days]
			   --,[agtrm_roll_terms_yn]
			   --,[agtrm_proximo_yn]
			   ,[agtrm_eft_yn]
			   --,[agtrm_send_to_et_yn]
			   --,[agtrm_et_discount_type]
			   --,[agtrm_et_discount_rate]
			   --,[agtrm_et_override_yn]
			   --,[agtrm_user_id]
			   --,[agtrm_user_rev_dt]
			   )  
			SELECT  
				LTRIM(RTRIM(T.[strTermCode]))				--[agtrm_key_n]
				,SUBSTRING(LTRIM(RTRIM(T.[strTerm])),1,15)	--[agtrm_desc]
				,CAST(T.[dblDiscountEP]	AS numeric(4,2))	--[agtrm_disc_pct]
				,T.[intDiscountDay]							--[agtrm_disc_days]
				,(CASE WHEN ISDATE(T.[dtmDiscountDate]) = 1
					THEN
						CAST((SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),7,4) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),1,2) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),4,2)) AS int)
					ELSE 0
				END)										--[agtrm_disc_rev_dt]
				,T.[intBalanceDue]							--[agtrm_net_days]
				,(CASE WHEN ISDATE(T.[dtmDueDate]) = 1
					THEN
						CAST((SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDueDate], 101),7,4) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDueDate], 101),1,2) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDueDate], 101),4,2)) AS int)
					ELSE 0
				END)										--[agtrm_net_rev_dt]
				--,[agtrm_age_ind]
				--,[agtrm_cutoff_days]
				--,[agtrm_roll_terms_yn]
				--,[agtrm_proximo_yn]
				,(CASE T.[ysnAllowEFT]
					WHEN 1	THEN	''Y''
					WHEN 0	THEN	''N''
					ELSE ''N''
				END)										--[agtrm_eft_yn]
				--,[agtrm_send_to_et_yn]
				--,[agtrm_et_discount_type]
				--,[agtrm_et_discount_rate]
				--,[agtrm_et_override_yn]
				--,[agtrm_user_id]
				--,[agtrm_user_rev_dt]
			FROM  
			 tblSMTerm T  
			INNER JOIN  
			 @RecordsToAdd A  
			  ON T.[strTermCode] = A.[strTermCode]      
			LEFT OUTER JOIN  
			 [agtrmmst] PM  
			  ON T.[strTermCode] = PM.[agtrm_key_n]  
			WHERE  
				PM.[agtrm_key_n] IS NULL  
				AND ISNUMERIC(LTRIM(RTRIM(T.[strTermCode]))) = 1
			ORDER BY  
			 T.[strTermCode]             
		  
			SET @AddedCount = @@ROWCOUNT  
		  
		  
			UPDATE [agtrmmst]  
			SET   
				[agtrm_key_n] = LTRIM(RTRIM(T.[strTermCode]))
				,[agtrm_desc] = SUBSTRING(LTRIM(RTRIM(T.[strTerm])),1,15)
				,[agtrm_disc_pct] = CAST(T.[dblDiscountEP]	AS numeric(4,2))
				,[agtrm_disc_days] = T.[intDiscountDay]	
				,[agtrm_disc_rev_dt] = 
					(CASE WHEN ISDATE(T.[dtmDiscountDate]) = 1
						THEN
							CAST((SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),7,4) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),1,2) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),4,2)) AS int)
						ELSE 0
					END)						
				,[agtrm_net_days] = T.[intBalanceDue]
				,[agtrm_net_rev_dt] = 
					(CASE WHEN ISDATE(T.[dtmDueDate]) = 1
						THEN
							CAST((SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDueDate], 101),7,4) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDueDate], 101),1,2) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDueDate], 101),4,2)) AS int)
						ELSE 0
					END)
				,[agtrm_age_ind] = [agtrm_age_ind]
				,[agtrm_cutoff_days] = [agtrm_cutoff_days]
				,[agtrm_roll_terms_yn] = [agtrm_roll_terms_yn]
				,[agtrm_proximo_yn] = [agtrm_proximo_yn]
				,[agtrm_eft_yn] = 
					(CASE T.[ysnAllowEFT]
						WHEN 1	THEN	''Y''
						WHEN 0	THEN	''N''
						ELSE ''N''
					END)
				,[agtrm_send_to_et_yn] = [agtrm_send_to_et_yn]
				,[agtrm_et_discount_type] = [agtrm_et_discount_type]
				,[agtrm_et_discount_rate] = [agtrm_et_discount_rate]
				,[agtrm_et_override_yn] = [agtrm_et_override_yn]
				,[agtrm_user_id] = [agtrm_user_id]
				,[agtrm_user_rev_dt] = [agtrm_user_rev_dt]
			FROM  
			 tblSMTerm T  
			INNER JOIN  
			 @RecordsToUpdate A  
			  ON T.[strTermCode] = A.[strTermCode]       
			WHERE  
				[agtrmmst].[agtrm_key_n] = LTRIM(RTRIM(A.[strTermCode]))   
		     
			SET @UpdatedCount = @@ROWCOUNT      
		   END  
		  ELSE  
		   BEGIN  
		   
			INSERT INTO [tblSMTerm]  
				([strTerm]
				,[strTermCode]
				,[strType]
				,[dblDiscountEP]
				,[intDiscountDay]
				,[dtmDiscountDate]
				,[intBalanceDue]
				,[dtmDueDate]
				,[ysnAllowEFT]
				,[dblAPR]
				,[intDayofMonthDue]
				,[intDueNextMonth]) 
			SELECT  
				--T.[agtrm_desc]			--[strTerm]
				(CASE WHEN EXISTS(SELECT [agtrm_key_n], [agtrm_desc] FROM [agtrmmst] WHERE RTRIM(LTRIM([agtrm_desc])) = RTRIM(LTRIM(T.[agtrm_desc])) AND RTRIM(LTRIM([agtrm_key_n])) <> RTRIM(LTRIM(T.[agtrm_key_n])))
					THEN 
						RTRIM(LTRIM(T.[agtrm_desc])) + '' - '' + RTRIM(LTRIM(T.[agtrm_key_n]))
					ELSE
						RTRIM(LTRIM(T.[agtrm_desc]))
				  END)								
				,T.[agtrm_key_n]		--[strTermCode]
				,(CASE 
					WHEN T.[agtrm_net_rev_dt] <> 0  OR T.[agtrm_disc_rev_dt] <> 0
						THEN ''Specific Date''
					ELSE
						''Standard''
					END)				--[strType]
				,T.[agtrm_disc_pct]		--[dblDiscountEP]
				,T.[agtrm_disc_days]	--[intDiscountDay]
				,(CASE 
					WHEN ISDATE(T.[agtrm_disc_rev_dt]) = 1 
						THEN CONVERT(DATE, CAST(T.[agtrm_disc_rev_dt] AS CHAR(12)), 112) 
					ELSE
						NULL 
					END)				--[dtmDiscountDate]
				,T.[agtrm_net_days]		--[intBalanceDue]
				,(CASE 
					WHEN ISDATE(agtrm_net_rev_dt) = 1 
						THEN CONVERT(DATE, CAST(T.[agtrm_net_rev_dt] AS CHAR(12)), 112) 
					ELSE
						NULL 
					END)				--[dtmDueDate]
				,(CASE 
					WHEN RTRIM(LTRIM(ISNULL(T.[agtrm_eft_yn],''N''))) = ''N'' THEN 0 ELSE 1 
					END)				--[ysnAllowEFT]
				,0						--[dblAPR]
				,0						--[intDayofMonthDue]
				,0						--[intDueNextMonth]
			FROM  
			 [agtrmmst] T  
			INNER JOIN  
			 @RecordsToAdd A  
			  ON CAST(T.[agtrm_key_n] AS nvarchar(2)) = A.[strTermCode]
			LEFT OUTER JOIN  
			 tblSMTerm PM  
			  ON CAST(T.[agtrm_key_n] AS nvarchar(2)) = PM.[strTermCode]  
			WHERE  
			 PM.[strTermCode] IS NULL  
			ORDER BY  
			 T.[agtrm_key_n]  
		     
			SET @AddedCount = @@ROWCOUNT   
		    
		    
			UPDATE [tblSMTerm]  
			SET  
				[strTerm] = T.[agtrm_desc]
				,[strTermCode] = T.[agtrm_key_n]
				,[strType] = 
					(CASE 
						WHEN T.[agtrm_net_rev_dt] <> 0  OR T.[agtrm_disc_rev_dt] <> 0
							THEN ''Specific Date''
						ELSE
							''Standard''
					END)
				,[dblDiscountEP] = T.[agtrm_disc_pct]
				,[intDiscountDay] = T.[agtrm_disc_days]
				,[dtmDiscountDate] = 
					(CASE 
						WHEN ISDATE(T.[agtrm_disc_rev_dt]) = 1 
							THEN CONVERT(DATE, CAST(T.[agtrm_disc_rev_dt] AS CHAR(12)), 112) 
						ELSE
							NULL 
					END)
				,[intBalanceDue] = T.[agtrm_net_days]
				,[dtmDueDate]= 
					(CASE 
						WHEN ISDATE(agtrm_net_rev_dt) = 1 
							THEN CONVERT(DATE, CAST(T.[agtrm_net_rev_dt] AS CHAR(12)), 112) 
						ELSE
							NULL 
					END)
				,[ysnAllowEFT] = 
					(CASE WHEN RTRIM(LTRIM(ISNULL(T.[agtrm_eft_yn],''N''))) = ''N'' 
							THEN 0 
						ELSE 1 
					END)
				,[dblAPR] = [dblAPR]
				,[intDayofMonthDue] = [intDayofMonthDue]
				,[intDueNextMonth] = [intDueNextMonth]
			FROM  
			 [agtrmmst] T  
			INNER JOIN  
			 @RecordsToUpdate A  
			  ON CAST(T.[agtrm_key_n] AS nvarchar(2)) = A.[strTermCode]      
			WHERE  
			  [tblSMTerm].[strTermCode] = A.[strTermCode]    
		      
		      
			SET @UpdatedCount = @@ROWCOUNT      
		    
		   
		   END  
		  
		  
		  END')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	EXEC('CREATE PROCEDURE uspARSyncTerms  
		   @ToOrigin   bit    = 0  
		   ,@TermCodes  nvarchar(MAX) = ''all''  
		   ,@AddedCount  int    = 0 OUTPUT  
		   ,@UpdatedCount  int    = 0 OUTPUT  
		  AS  
		  BEGIN  
		  
		  DECLARE @RecordsToProcess table(strTermCode nvarchar(3) COLLATE Latin1_General_CI_AS)  
		  DECLARE @RecordsToAdd table(strTermCode varchar(3) COLLATE Latin1_General_CI_AS)  
		  DECLARE @RecordsToUpdate table(strTermCode varchar(3) COLLATE Latin1_General_CI_AS)  
		  
		  DELETE FROM @RecordsToProcess  
		  DELETE FROM @RecordsToAdd  
		  DELETE FROM @RecordsToUpdate  
		    
		  IF(LOWER(@TermCodes) = ''all'')  
		   BEGIN  
			IF (@ToOrigin = 1)  
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT [strTermCode]  
			 FROM tblSMTerm    
			 WHERE
				ISNUMERIC(LTRIM(RTRIM([strTermCode]))) = 1
				AND LTRIM(RTRIM([strTermCode])) <= ''99''      
			ELSE  
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT [pttrm_code]  
			 FROM [pttrmmst]           
		   END  
		  ELSE  
		   BEGIN  
			IF (@ToOrigin = 1)     
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT PM.[strTermCode]  
			 FROM fnGetRowsFromDelimitedValues(@TermCodes) T  
			 INNER JOIN tblSMTerm PM ON T.[intID] = PM.[strTermCode] 
			 WHERE
				ISNUMERIC(LTRIM(RTRIM(PM.[strTermCode]))) = 1
				AND LTRIM(RTRIM(PM.[strTermCode])) <= ''99''       
			ELSE  
			 INSERT INTO @RecordsToProcess(strTermCode)  
			 SELECT PM.[pttrm_code]  
			 FROM fnGetRowsFromDelimitedValues(@TermCodes) T  
			 INNER JOIN [pttrmmst] PM ON T.[intID] = PM.[pttrm_code]  
		   END    
		   
		  IF (@ToOrigin = 1)  
		   INSERT INTO @RecordsToAdd  
		   SELECT T.[strTermCode]  
		   FROM @RecordsToProcess T  
		   LEFT OUTER JOIN [pttrmmst] PM ON T.[strTermCode] = PM.[pttrm_code]  
		   WHERE PM.[pttrm_code] IS NULL   
		  ELSE  
		   INSERT INTO @RecordsToAdd  
		   SELECT T.[strTermCode]  
		   FROM @RecordsToProcess T  
		   LEFT OUTER JOIN tblSMTerm PM ON T.[strTermCode] = PM.[strTermCode]  
		   WHERE PM.[strTermCode] IS NULL    
		   
		        
		  INSERT INTO @RecordsToUpdate  
		  SELECT T.[strTermCode]  
		  FROM @RecordsToProcess T  
		  LEFT JOIN @RecordsToAdd A ON T.[strTermCode] = A.[strTermCode]  
		  WHERE A.[strTermCode] IS NULL       
		   
		  
		  IF(@ToOrigin = 1)  
		   BEGIN   
		      
			INSERT INTO [pttrmmst]  
			   ([pttrm_code]
			   ,[pttrm_desc]
			   ,[pttrm_pct]
			   ,[pttrm_days]
			   ,[pttrm_last_chg_rev_dt]
			   ,[pttrm_net]
			   --,[pttrm_type_pd]
			   --,[pttrm_prox_cutoff_day]
			   --,[pttrm_filler]
			   --,[pttrm_filler1]
			   --,[pttrm_load_to_load_yn]
			   ,[pttrm_eft_yn]
			   --,[pttrm_send_to_et_yn]
			   --,[pttrm_et_discount_type]
			   --,[pttrm_et_discount_rate]
			   --,[pttrm_et_override_yn]
			   )  
			SELECT  
				LTRIM(RTRIM(T.[strTermCode]))				--[pttrm_code]
				,SUBSTRING(LTRIM(RTRIM(T.[strTerm])),1,30)	--[pttrm_desc]
				,CAST(T.[dblDiscountEP]	AS numeric(6,4))	--[pttrm_pct]
				,T.[intDiscountDay]							--[pttrm_days]
				,(CASE WHEN ISDATE(T.[dtmDiscountDate]) = 1
					THEN
						CAST((SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),7,4) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),1,2) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),4,2)) AS int)
					ELSE 0
				END)										--[pttrm_last_chg_rev_dt]
				,T.[intBalanceDue]							--[pttrm_net]
				--,[pttrm_type_pd]
				--,[pttrm_prox_cutoff_day]
				--,[pttrm_filler]
				--,[pttrm_filler1]
				--,[pttrm_load_to_load_yn]
				,(CASE T.[ysnAllowEFT]
					WHEN 1	THEN	''Y''
					WHEN 0	THEN	''N''
					ELSE ''N''
				END)										--[pttrm_eft_yn]
				--,[pttrm_send_to_et_yn]
				--,[pttrm_et_discount_type]
				--,[pttrm_et_discount_rate]
				--,[pttrm_et_override_yn]
			FROM  
			 tblSMTerm T  
			INNER JOIN  
			 @RecordsToAdd A  
			  ON T.[strTermCode] = A.[strTermCode]      
			LEFT OUTER JOIN  
			 [pttrmmst] PM  
			  ON T.[strTermCode] = PM.[pttrm_code]  
			WHERE  
			 PM.[pttrm_code] IS NULL  
			 AND ISNUMERIC(LTRIM(RTRIM(T.[strTermCode]))) = 1
			ORDER BY  
			 T.[strTermCode]             
		  
			SET @AddedCount = @@ROWCOUNT  
		  
		  
			UPDATE [pttrmmst]  
			SET   
				[pttrm_code] = LTRIM(RTRIM(T.[strTermCode]))
				,[pttrm_desc] = SUBSTRING(LTRIM(RTRIM(T.[strTerm])),1,30)
				,[pttrm_pct] = CAST(T.[dblDiscountEP]	AS numeric(6,4))
				,[pttrm_days] = T.[intDiscountDay]	
				,[pttrm_last_chg_rev_dt] = 
					(CASE WHEN ISDATE(T.[dtmDiscountDate]) = 1
						THEN
							CAST((SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),7,4) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),1,2) + SUBSTRING(CONVERT(NVARCHAR(10),T.[dtmDiscountDate], 101),4,2)) AS int)
						ELSE 0
					END)						
				,[pttrm_net] = T.[intBalanceDue]
				,[pttrm_type_pd] = [pttrm_type_pd]
				,[pttrm_prox_cutoff_day] = [pttrm_prox_cutoff_day]
				,[pttrm_filler] = [pttrm_filler]
				,[pttrm_filler1] = [pttrm_filler1]
				,[pttrm_load_to_load_yn] = [pttrm_load_to_load_yn]
				,[pttrm_eft_yn] = 
					(CASE T.[ysnAllowEFT]
						WHEN 1	THEN	''Y''
						WHEN 0	THEN	''N''
						ELSE ''N''
					END)
				,[pttrm_send_to_et_yn] = [pttrm_send_to_et_yn]
				,[pttrm_et_discount_type] = [pttrm_et_discount_type]
				,[pttrm_et_discount_rate] = [pttrm_et_discount_rate]
				,[pttrm_et_override_yn] = [pttrm_et_override_yn]
			FROM  
			 tblSMTerm T  
			INNER JOIN  
			 @RecordsToUpdate A  
			  ON T.[strTermCode] = A.[strTermCode]       
			WHERE  
				ISNUMERIC(LTRIM(RTRIM(T.[strTermCode]))) = 1
				AND [pttrmmst].[pttrm_code] = LTRIM(RTRIM(A.[strTermCode]))   
		     
			SET @UpdatedCount = @@ROWCOUNT      
		   END  
		  ELSE  
		   BEGIN  
		   
			INSERT INTO [tblSMTerm]  
				([strTerm]
				,[strTermCode]
				,[strType]
				,[dblDiscountEP]
				,[intDiscountDay]
				,[dtmDiscountDate]
				,[intBalanceDue]
				,[dtmDueDate]
				,[ysnAllowEFT]
				,[dblAPR]
				,[intDayofMonthDue]
				,[intDueNextMonth]) 
			SELECT  
				--T.[pttrm_desc]			--[strTerm]
				(CASE WHEN EXISTS(SELECT [pttrm_code], [pttrm_desc] FROM [pttrmmst] WHERE RTRIM(LTRIM([pttrm_desc])) = RTRIM(LTRIM(T.[pttrm_desc])) AND RTRIM(LTRIM([pttrm_code])) <> RTRIM(LTRIM(T.[pttrm_code])))
					THEN 
						RTRIM(LTRIM(T.[pttrm_desc])) + '' - '' + RTRIM(LTRIM(T.[pttrm_code]))
					ELSE
						RTRIM(LTRIM(T.[pttrm_desc]))
				  END)
				,T.[pttrm_code]			--[strTermCode]
				,(CASE 
					WHEN T.[pttrm_last_chg_rev_dt] <> 0
						THEN ''Specific Date''
					ELSE
						''Standard''
					END)				--[strType]
				,T.[pttrm_pct]			--[dblDiscountEP]
				,T.[pttrm_days]			--[intDiscountDay]
				,(CASE 
					WHEN ISDATE(T.[pttrm_last_chg_rev_dt]) = 1 
						THEN CONVERT(DATE, CAST(T.[pttrm_last_chg_rev_dt] AS CHAR(12)), 112) 
					ELSE
						NULL 
					END)				--[dtmDiscountDate]
				,T.[pttrm_net]			--[intBalanceDue]
				,NULL
				,(CASE 
					WHEN RTRIM(LTRIM(ISNULL(T.[pttrm_eft_yn],''N''))) = ''N'' THEN 0 ELSE 1 
					END)				--[ysnAllowEFT]
				,0						--[dblAPR]
				,0						--[intDayofMonthDue]
				,0						--[intDueNextMonth]
			FROM  
			 [pttrmmst] T  
			INNER JOIN  
			 @RecordsToAdd A  
			  ON T.[pttrm_code] = A.[strTermCode]
			LEFT OUTER JOIN  
			 tblSMTerm PM  
			  ON T.[pttrm_code] = PM.[strTermCode]  
			WHERE  
			 PM.[strTermCode] IS NULL  
			ORDER BY  
			 T.[pttrm_code]  
		     
			SET @AddedCount = @@ROWCOUNT   
		    
		    
			UPDATE [tblSMTerm]  
			SET  
				[strTerm] = T.[pttrm_desc]
				,[strTermCode] = T.[pttrm_code]
				,[strType] = 
					(CASE 
						WHEN T.[pttrm_last_chg_rev_dt] <> 0
							THEN ''Specific Date''
						ELSE
							''Standard''
					END)
				,[dblDiscountEP] = T.[pttrm_pct]
				,[intDiscountDay] = T.[pttrm_days]
				,[dtmDiscountDate] = 
					(CASE 
						WHEN ISDATE(T.[pttrm_last_chg_rev_dt]) = 1 
							THEN CONVERT(DATE, CAST(T.[pttrm_last_chg_rev_dt] AS CHAR(12)), 112) 
						ELSE
							NULL 
					END)
				,[intBalanceDue] = T.[pttrm_net]
				,[dtmDueDate] = [dtmDueDate]
				,[ysnAllowEFT] = 
					(CASE WHEN RTRIM(LTRIM(ISNULL(T.[pttrm_eft_yn],''N''))) = ''N'' 
							THEN 0 
						ELSE 1 
					END)
				,[dblAPR] = [dblAPR]
				,[intDayofMonthDue] = [intDayofMonthDue]
				,[intDueNextMonth] = [intDueNextMonth]
			FROM  
			 [pttrmmst] T  
			INNER JOIN  
			 @RecordsToUpdate A  
			  ON T.[pttrm_code] = A.[strTermCode]      
			WHERE  
			  [tblSMTerm].[strTermCode] = A.[strTermCode]    
		      
		      
			SET @UpdatedCount = @@ROWCOUNT      
		    
		   
		   END  
		  
		  
		  END')
END