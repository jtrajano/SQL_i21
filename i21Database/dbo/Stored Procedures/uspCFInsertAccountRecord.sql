CREATE PROCEDURE [dbo].[uspCFInsertAccountRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
	 @strCustomerId					NVARCHAR(MAX)	 =	 ''
	,@strDiscountScheduleId			NVARCHAR(MAX)	 =	 ''
	,@strInvoiceCycle				NVARCHAR(MAX)	 =	 ''
	,@strSalesPersonId				NVARCHAR(MAX)	 =	 ''
	,@strTermsCode					NVARCHAR(MAX)	 =	 ''
	,@strAccountStatusCodeId		NVARCHAR(MAX)	 =	 ''
	,@strPriceRuleGroup				NVARCHAR(MAX)	 =	 ''
	,@strFeeProfileId				NVARCHAR(MAX)	 =	 ''
	,@strRemotePriceProfileId		NVARCHAR(MAX)	 =	 ''
	,@strExtRemotePriceProfileId	NVARCHAR(MAX)	 =	 ''
	,@strLocalPriceProfileId		NVARCHAR(MAX)	 =	 ''
	---------------------------------------------------------
	,@intDiscountDays				INT				 =	 0
	---------------------------------------------------------
	,@ysnPrintTimeOnInvoices		NVARCHAR(MAX)	 =	 'Y'
	,@ysnPrintTimeOnReports			NVARCHAR(MAX)	 =	 'Y'
	,@ysnSummaryByCard				NVARCHAR(MAX)	 =	 'N'
	,@ysnSummaryByMiscellaneous		NVARCHAR(MAX)	 =	 'N'
	,@ysnSummaryByProduct			NVARCHAR(MAX)	 =	 'Y'
	,@ysnSummaryByDepartment		NVARCHAR(MAX)	 =	 'N'
	,@ysnVehicleRequire				NVARCHAR(MAX)	 =	 'N'
	,@ysnPrintMiscellaneous			NVARCHAR(MAX)	 =	 'N'
	---------------------------------------------------------
	,@dblBonusCommissionRate		NUMERIC(18,6)	 =	 NULL
	,@dblRegularCommissionRate		NUMERIC(18,6)	 =	 NULL
	---------------------------------------------------------
	,@dtmLastBillingCycleDate		DATETIME		 =	 NULL
	,@dtmBonusCommissionDate		DATETIME		 =	 NULL
	---------------------------------------------------------
	,@strBillingSite				NVARCHAR(MAX)	 =	 NULL
	,@strPrimarySortOptions			NVARCHAR(MAX)	 =	 'Card'
	,@strSecondarySortOptions		NVARCHAR(MAX)	 =	 'Vehicle'
	,@strPrintRemittancePage		NVARCHAR(MAX)	 =	 'No'
	,@strPrintPricePerGallon		NVARCHAR(MAX)	 =	 'Including Taxes'
	,@strPrintSiteAddress			NVARCHAR(MAX)	 =	 'None'
	---------------------------------------------------------

AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicateAccount					  INT = 0
	---------------------------------------------------------
	DECLARE @intCustomerId							  INT = 0
	DECLARE @intDiscountScheduleId					  INT = 0
	DECLARE @intInvoiceCycle						  INT = 0
	DECLARE @intSalesPersonId						  INT = 0
	DECLARE @intTermsCode							  INT = 0
	DECLARE @intAccountStatusCodeId					  INT = 0
	DECLARE @intPriceRuleGroup						  INT = 0
	DECLARE @intFeeProfileId						  INT = 0
	DECLARE @intRemotePriceProfileId				  INT = 0
	DECLARE @intExtRemotePriceProfileId				  INT = 0
	DECLARE @intLocalPriceProfileId					  INT = 0
	---------------------------------------------------------



	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------

	
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strCustomerId = NULL OR @strCustomerId = '')
	BEGIN
		SET @strCustomerId = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Account number is required')
		SET @ysnHasError = 1
	END
	IF(@strAccountStatusCodeId = NULL OR @strAccountStatusCodeId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Account status code is required')
		SET @ysnHasError = 1
	END
	IF(@strTermsCode = NULL OR @strTermsCode = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Terms code is required')
		SET @ysnHasError = 1
	END
	IF(@strDiscountScheduleId = NULL OR @strDiscountScheduleId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog(strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Discount schedule is required')
		SET @ysnHasError = 1
	END
	IF(@strRemotePriceProfileId = NULL OR @strRemotePriceProfileId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Remote price profile is required')
		SET @ysnHasError = 1
	END
	IF(@strExtRemotePriceProfileId = NULL OR @strExtRemotePriceProfileId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog(strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Ext Remote price profile is required')
		SET @ysnHasError = 1
	END
	IF(@strSalesPersonId = NULL OR @strSalesPersonId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog(strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Salesperson is required')
		SET @ysnHasError = 1
	END
	IF(@strInvoiceCycle = NULL OR @strInvoiceCycle = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Invoice cycle is required')
		SET @ysnHasError = 1
	END
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--			      DUPLICATE ACCOUNT NUMBER			   --
	---------------------------------------------------------
	--Customer
	SELECT @intCustomerId = [intEntityId] 
	FROM tblARCustomer 
	WHERE strCustomerNumber = @strCustomerId
	
	IF (@intCustomerId = 0)
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Unable to find match for '+ @strCustomerId +' on customer list')
		SET @ysnHasError = 1
	END
	ELSE
	BEGIN
		SELECT @intDuplicateAccount = COUNT(*) FROM tblCFAccount WHERE intCustomerId = @intCustomerId
		IF (@intDuplicateAccount > 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Duplicate account for '+ @strCustomerId)
			SET @ysnHasError = 1
		END
	END
	
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID VALUE TO OTHER TABLE		       --
	---------------------------------------------------------

	--Discount Schedule
	IF(@strDiscountScheduleId != '')
	BEGIN
		SELECT @intDiscountScheduleId = intDiscountScheduleId 
		FROM tblCFDiscountSchedule 
		WHERE strDiscountSchedule = @strDiscountScheduleId
		IF (@intDiscountScheduleId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strDiscountScheduleId +' on discount schedule list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intDiscountScheduleId = NULL;
	END

	--Invoice Cycle
	IF(@strInvoiceCycle != '')
	BEGIN
		SELECT @intInvoiceCycle = intInvoiceCycleId 
		FROM tblCFInvoiceCycle 
		WHERE strInvoiceCycle = @strInvoiceCycle
		IF (@intInvoiceCycle = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strInvoiceCycle +' on invoice cycle list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intInvoiceCycle = NULL;
	END

	--Sales Person
	SELECT @intSalesPersonId = S.intEntityId  
	FROM tblEMEntity E
	INNER JOIN tblARSalesperson S
	ON E.intEntityId = S.[intEntityId]
	WHERE E.strName = @strSalesPersonId
	IF (@strSalesPersonId != '')
	BEGIN
		SELECT @intSalesPersonId = S.intEntityId  
		FROM tblEMEntity E
		INNER JOIN tblARSalesperson S
		ON E.intEntityId = S.[intEntityId]
		WHERE E.strName = @strSalesPersonId
		IF (@intSalesPersonId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strSalesPersonId +' on salesperson list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intSalesPersonId = NULL;
	END

	--Terms
	IF(@strTermsCode != '')
	BEGIN
		SELECT @intTermsCode = intTermID 
		FROM tblSMTerm 
		WHERE strTerm = @strTermsCode
		IF (@intTermsCode = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strTermsCode +' on terms list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intTermsCode = NULL;
	END

	--Account Status
	IF(@strAccountStatusCodeId != '')
	BEGIN
		SELECT @intAccountStatusCodeId = intAccountStatusId 
		FROM tblARAccountStatus 
		WHERE strAccountStatusCode = @strAccountStatusCodeId
		IF (@intAccountStatusCodeId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strAccountStatusCodeId +' on account status list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intAccountStatusCodeId = NULL;
	END

	--Price Rule Group
	IF(@strPriceRuleGroup != '')
	BEGIN
		SELECT @intPriceRuleGroup = intPriceRuleGroupId 
		FROM tblCFPriceRuleGroup 
		WHERE strPriceGroup = @strPriceRuleGroup
		IF (@intPriceRuleGroup = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strPriceRuleGroup +' on price rule group list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intPriceRuleGroup = NULL;
	END

	--@Fee Profile
	IF(@strFeeProfileId != '')
	BEGIN
		SELECT @intFeeProfileId = intFeeProfileId 
		FROM tblCFFeeProfile 
		WHERE strFeeProfileId = @strFeeProfileId
		IF (@intFeeProfileId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strFeeProfileId +' on fee profile list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intFeeProfileId = NULL;
	END

	--@Remote Price Profile
	IF(@strRemotePriceProfileId != '')
	BEGIN
		SELECT @intRemotePriceProfileId = intPriceProfileHeaderId 
		FROM tblCFPriceProfileHeader 
		WHERE strPriceProfile = @strRemotePriceProfileId
		IF (@intRemotePriceProfileId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strRemotePriceProfileId +' on remote price profile list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intRemotePriceProfileId = NULL;
	END

	--Ext Remote Price Profile
	IF(@strExtRemotePriceProfileId != '')
	BEGIN
		SELECT @intExtRemotePriceProfileId = intPriceProfileHeaderId 
		FROM tblCFPriceProfileHeader 
		WHERE strPriceProfile = @strExtRemotePriceProfileId
		IF (@intExtRemotePriceProfileId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strExtRemotePriceProfileId +' on ext remote price profile list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intExtRemotePriceProfileId = NULL;
	END

	--Ext Remote Price Profile
	IF(@strLocalPriceProfileId != '')
	BEGIN
		SELECT @intLocalPriceProfileId = intPriceProfileHeaderId 
		FROM tblCFPriceProfileHeader 
		WHERE strPriceProfile = @strLocalPriceProfileId
		IF (@intLocalPriceProfileId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Unable to find match for '+ @strLocalPriceProfileId +' on local price profile list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intLocalPriceProfileId = NULL;
	END
	---------------------------------------------------------
	
	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------
	--Print Time On Invoice
	IF (@ysnPrintTimeOnInvoices = 'N')
		BEGIN 
			SET @ysnPrintTimeOnInvoices = 0
		END
	ELSE IF (@ysnPrintTimeOnInvoices = 'Y')
		BEGIN
			SET @ysnPrintTimeOnInvoices = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid print time on invoice value '+ @ysnPrintTimeOnInvoices +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Print Time On Reports
	IF (@ysnPrintTimeOnReports = 'N')
		BEGIN 
			SET @ysnPrintTimeOnReports = 0
		END
	ELSE IF (@ysnPrintTimeOnReports = 'Y')
		BEGIN
			SET @ysnPrintTimeOnReports = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid print time on reports value '+ @ysnPrintTimeOnReports +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Summary by card
	IF (@ysnSummaryByCard = 'N')
		BEGIN 
			SET @ysnSummaryByCard = 0
		END
	ELSE IF (@ysnSummaryByCard = 'Y')
		BEGIN
			SET @ysnSummaryByCard = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid summary by card value '+ @ysnSummaryByCard +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Summary by miscellaneous
	IF (@ysnSummaryByMiscellaneous = 'N')
		BEGIN 
			SET @ysnSummaryByMiscellaneous = 0
		END
	ELSE IF (@ysnSummaryByMiscellaneous = 'Y')
		BEGIN
			SET @ysnSummaryByMiscellaneous = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid summary by miscellaneous value '+ @ysnSummaryByMiscellaneous +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Summary by product
	IF (@ysnSummaryByProduct = 'N')
		BEGIN 
			SET @ysnSummaryByProduct = 0
		END
	ELSE IF (@ysnSummaryByProduct = 'Y')
		BEGIN
			SET @ysnSummaryByProduct = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid summary by product value '+ @ysnSummaryByProduct +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Summary by department
	IF (@ysnSummaryByDepartment = 'N')
		BEGIN 
			SET @ysnSummaryByDepartment = 0
		END
	ELSE IF (@ysnSummaryByDepartment = 'Y')
		BEGIN
			SET @ysnSummaryByDepartment = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid summary by department value '+ @ysnSummaryByDepartment +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Vehicle required
	IF (@ysnVehicleRequire = 'N')
		BEGIN 
			SET @ysnVehicleRequire = 0
		END
	ELSE IF (@ysnVehicleRequire = 'Y')
		BEGIN
			SET @ysnVehicleRequire = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid vehicle required value '+ @ysnVehicleRequire +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Print Miscellaneous
	IF (@ysnPrintMiscellaneous = 'N')
		BEGIN 
			SET @ysnPrintMiscellaneous = 0
		END
	ELSE IF (@ysnPrintMiscellaneous = 'Y')
		BEGIN
			SET @ysnPrintMiscellaneous = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Invalid print miscellaneous value '+ @ysnPrintMiscellaneous +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Primary Sort Options
	IF(@strPrimarySortOptions NOT IN ('Card','Vehicle','Department','Miscellaneous'))
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Invalid primary sort option value '+ @strPrimarySortOptions +'. Value should be Card, Vehicle, Department, Miscellaneous only')
		SET @ysnHasError = 1
	END

	--Secondary Sort Options
	IF(@strSecondarySortOptions NOT IN ('Card','Vehicle','Department','Miscellaneous'))
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Invalid secondary sort option value '+ @strSecondarySortOptions +'. Value should be Card, Vehicle, Department, Miscellaneous only')
		SET @ysnHasError = 1
	END

	--Print Remittance Page
	IF(@strPrintRemittancePage NOT IN ('No','Yes with company address','Yes with location address','Yes with no address'))
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Invalid print remittance page value '+ @strPrintRemittancePage +'. Value should be No, Yes with company address, Yes with location address, Yes with no address only')
		SET @ysnHasError = 1
	END

	--Print Price Per Gallon
	IF(@strPrintPricePerGallon NOT IN ('Including Taxes','Excluding Taxes','Excluding SST Tax'))
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Invalid print price per gallon value '+ @strPrintPricePerGallon +'. Value should be Including Taxes, Excluding Taxes, Excluding SST Tax only')
		SET @ysnHasError = 1
	END

	--Print Site Address
	IF(@strPrintSiteAddress NOT IN ('All','Remote','None'))
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strCustomerId,'Invalid print site address value '+ @strPrintSiteAddress +'. Value should be All, Remote, None only')
		SET @ysnHasError = 1
	END

	--Bonus Commission Date
	IF (@dtmBonusCommissionDate = '')
		BEGIN 
			SET @dtmBonusCommissionDate = NULL
		END

	--Last Billing Cycle Date
	IF (@dtmLastBillingCycleDate = '')
		BEGIN 
			SET @dtmLastBillingCycleDate = NULL
		END
	---------------------------------------------------------


	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				INSERT ACCOUNT RECORD			       --		
	---------------------------------------------------------
	BEGIN TRANSACTION
		BEGIN TRY

			INSERT INTO tblCFAccount(
			 intCustomerId
			,intDiscountDays
			,intDiscountScheduleId
			,intInvoiceCycle
			,intSalesPersonId
			,dtmBonusCommissionDate
			,dblBonusCommissionRate
			,dblRegularCommissionRate
			,ysnPrintTimeOnInvoices
			,ysnPrintTimeOnReports
			,intTermsCode
			,strBillingSite
			,strPrimarySortOptions
			,strSecondarySortOptions
			,ysnSummaryByCard
			,ysnSummaryByMiscellaneous
			,ysnSummaryByProduct
			,ysnSummaryByDepartment
			,ysnVehicleRequire
			,intAccountStatusCodeId
			,strPrintRemittancePage
			,intPriceRuleGroup
			,strPrintPricePerGallon
			,ysnPrintMiscellaneous
			,intFeeProfileId
			,strPrintSiteAddress
			,dtmLastBillingCycleDate
			,intRemotePriceProfileId
			,intExtRemotePriceProfileId
			,intLocalPriceProfileId
			,dtmCreated
			,dtmLastModified)
			VALUES(
			 @intCustomerId
			,@intDiscountDays
			,@intDiscountScheduleId
			,@intInvoiceCycle
			,@intSalesPersonId
			,@dtmBonusCommissionDate
			,@dblBonusCommissionRate
			,@dblRegularCommissionRate
			,@ysnPrintTimeOnInvoices
			,@ysnPrintTimeOnReports
			,@intTermsCode
			,@strBillingSite
			,@strPrimarySortOptions
			,@strSecondarySortOptions
			,@ysnSummaryByCard
			,@ysnSummaryByMiscellaneous
			,@ysnSummaryByProduct
			,@ysnSummaryByDepartment
			,@ysnVehicleRequire
			,@intAccountStatusCodeId
			,@strPrintRemittancePage
			,@intPriceRuleGroup
			,@strPrintPricePerGallon
			,@ysnPrintMiscellaneous
			,@intFeeProfileId
			,@strPrintSiteAddress
			,@dtmLastBillingCycleDate
			,@intRemotePriceProfileId
			,@intExtRemotePriceProfileId
			,@intLocalPriceProfileId
			,GETDATE()
			,GETDATE())

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
		
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strCustomerId,'Internal Error - ' + ERROR_MESSAGE())
			RETURN 0
		END CATCH
		
END