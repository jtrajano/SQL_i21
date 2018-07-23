
PRINT '---------- START DYNAMIC CSV DEFAULT DATA ----------'
SET NOCOUNT ON

-- Customer Contact Import Begin
SET IDENTITY_INSERT tblSMCSVDynamicImport  ON
DECLARE @NewHeaderId INT
SET @NewHeaderId = 1

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, '1','1'
END

UPDATE tblSMCSVDynamicImport SET
	strName = 'Contact Import',
	strCommand = '
	DECLARE @EntityId 			INT
	DECLARE @EntityLocationId 	INT

		--	phone
		--mobile
		--locname
		--portal


	--validation stage
	DECLARE @IsValid BIT
	--DECLARE @ValidationMessage NVARCHAR(MAX)
	SET @IsValid = 1

	DECLARE @ContactMethod	NVARCHAR(100)
	DECLARE @ActiveStr		NVARCHAR(100)
	DECLARE @ActiveBit		BIT
	DECLARE @RankStr		NVARCHAR(100)
	DECLARE @Rank			INT
	DECLARE @PortalStr		NVARCHAR(100)
	DECLARE @PortalBit		BIT
	DECLARE @Phone			NVARCHAR(100)
	DECLARE @Mobile			NVARCHAR(100)
	DECLARE @LocationName	NVARCHAR(100)

	SET @ValidationMessage	= ''''
	SET @ContactMethod		= ''@contactMethod@''
	SET @ActiveStr			= LOWER(''@active@'')
	SET @ActiveBit			= 0
	SET @RankStr			= ''@rank@''
	SET @Rank				= 1
	SET @PortalStr			= LOWER(''@portal@'')
	SET @PortalBit			= 0
	SET @Phone				= ''@phone@''
	SET @Mobile				= ''@mobile@''
	SET @LocationName		= ''@locname@''

	DECLARE @EmailDistribution NVARCHAR(MAX)
	DECLARE @EmailDistributionList NVARCHAR(MAX)
	DECLARE @EmailDistributionValid NVARCHAR(MAX)
	DECLARE @EmailDistributionInvalid NVARCHAR(MAX)

	SET @EmailDistributionList = ''Invoices,Transport Quote,Statements,AP remittance,AR Remittance,Contracts,Sales Order,Credit Memo,Quote Order,Scale,Storage,Cash,Cash Refund,Debit Memo,Customer Prepayment,CF Invoice,Letter,PR Remittance,Dealer CC Notification,Purchase Order,Settlement''


	SET @EmailDistribution = ''@emailDistribution@''

	select @EmailDistributionInvalid = COALESCE(@EmailDistributionInvalid + '','', '''') + RTRIM(LTRIM(a.Item))
		from dbo.fnSplitString(@EmailDistribution, '','') a
			left join dbo.fnSplitString(@EmailDistributionList, '','') b
			on ltrim(rtrim(a.Item)) = b.Item
			where b.Item is null


	select @EmailDistributionValid = COALESCE(@EmailDistributionValid + '','', '''') + RTRIM(LTRIM(a.Item))
		from dbo.fnSplitString(@EmailDistribution, '','') a
			left join dbo.fnSplitString(@EmailDistributionList, '','') b
			on ltrim(rtrim(a.Item)) = b.Item
			where b.Item is not null

	SET @EmailDistributionInvalid	= ISNULL(@EmailDistributionInvalid, '''')
	SET @EmailDistributionValid		= ISNULL(@EmailDistributionValid, '''')

	IF @ContactMethod <> '''' AND @ContactMethod NOT IN (''Email'', ''Phone'', ''Email or Phone'')
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Contact Method ['' + @ContactMethod + ''] setting it to Blank''
		SET @ContactMethod = ''''
	END

	IF ISNULL(@EmailDistributionInvalid, '''') <> ''''
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Email Distribution ['' + @EmailDistributionInvalid + ''] has been exluded for the email distribution''
	END

	IF @ActiveStr = ''1'' OR @ActiveStr = ''yes'' OR @ActiveStr = ''true''
	BEGIN
		SET @ActiveBit = 1
	END
	ELSE IF lower(@ActiveStr) NOT IN (''1'', ''0'', ''yes'', ''no'', ''true'', ''false'')
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Active ['' + @ActiveStr + ''] should only be (0, 1, Yes, No, True, False)''
	END

	IF @PortalStr = ''1'' OR @PortalStr = ''yes'' OR @PortalStr = ''true''
	BEGIN
		SET @PortalBit = 1
	END
	ELSE IF lower(@PortalStr) NOT IN (''1'', ''0'', ''yes'', ''no'', ''true'', ''false'')
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Portal Access ['' + @PortalStr + ''] should only be (0, 1, Yes, No, True, False)''
	END

	IF ISNUMERIC(@RankStr) = 1
	BEGIN
		SET @Rank = @RankStr
	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Rank ['' + @RankStr + ''] should be a number''
	END



	SELECT @EntityId = intEntityId
		FROM tblEMEntity
			where strEntityNo = ''@entityCustomerId@''

	SET @EntityLocationId = null
	IF ISNULL(@EntityId, 0) > 0 and @LocationName <> ''''
	BEGIN
		SELECT TOP  1 @EntityLocationId = intEntityLocationId FROM tblEMEntityLocation where intEntityId = @EntityId and rtrim(ltrim(lower(@LocationName))) = rtrim(ltrim(lower(strLocationName)))

	END

	DECLARE @RoleId INT

	IF ISNULL(@EntityId, 0) > 0
	BEGIN

		DECLARE @NewEntityId INT
		INSERT INTO tblEMEntity(
			strName,			strContactNumber,	strEmail,		strSuffix,			strTitle,
			strNickName,		strDepartment,		strNotes,		intEntityRank,		ysnActive,
			strContactMethod,	strEmailDistributionOption
		)

		SELECT
			''@name@'',			'''',				''@email@'',	''@suffix@'',		''@title@'',
			''@nickname@'',		''@dept@'',			''@notes@'',	@Rank,				@ActiveBit,
			@ContactMethod,		@EmailDistributionValid


		SET @NewEntityId = @@IDENTITY

		INSERT INTO tblEMEntityToContact(intEntityId, intEntityContactId, ysnPortalAccess, intEntityLocationId)
		SELECT  @EntityId, @NewEntityId, 0, @EntityLocationId

		if @Phone <> ''''
		BEGIN
			insert into tblEMEntityPhoneNumber(intEntityId, strPhone)
			select @NewEntityId, @Phone
		END

		if @Mobile <> ''''
		BEGIN
			insert into tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)
			select @NewEntityId, @Mobile, null
		END

		IF @PortalBit = 1
		BEGIN
			DECLARE @ToggleOutput	NVARCHAR(200)
			DECLARE @UserRoleId		INT
			EXEC uspEMTogglePortalAccess
				@intEntityId				= @EntityId,
				@intEntityContactId			= @NewEntityId,
				@ysnEnablePortalAccess		= 1,
				@message					= @ToggleOutput OUTPUT,
				@intUserRoleId				= @UserRoleId OUTPUT

			IF ISNULL(@ToggleOutput, '''') <> ''''
			BEGIN
				SET @ToggleOutput = ''Creating portal access error:'' + @ToggleOutput
				RAISERROR(@ToggleOutput, 16, 1);
			END
		END


	END

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	Union All
	SELECT @NewHeaderId, 'name', 'Name*', 1
	Union All
	SELECT @NewHeaderId, 'suffix', 'Suffix', 0
	Union All
	SELECT @NewHeaderId, 'title', 'Title', 0
	Union All
	SELECT @NewHeaderId, 'nickname', 'NickName', 0
	Union All
	SELECT @NewHeaderId, 'email', 'Email', 0
	Union All
	SELECT @NewHeaderId, 'phone', 'Phone', 0
	Union All
	SELECT @NewHeaderId, 'mobile', 'Mobile', 0
	Union All
	SELECT @NewHeaderId, 'locname', 'Location Name', 0
	Union All
	SELECT @NewHeaderId, 'contactMethod', 'Contact Method', 0
	Union All
	SELECT @NewHeaderId, 'dept', 'Dept', 0
	Union All
	SELECT @NewHeaderId, 'emailDistribution', 'Email Distribution', 0
	Union All
	SELECT @NewHeaderId, 'notes', 'Notes', 0
	Union All
	SELECT @NewHeaderId, 'active', 'Active', 0
	Union All
	SELECT @NewHeaderId, 'rank', 'Rank', 0
	Union All
	SELECT @NewHeaderId, 'portal', 'Portal Access', 0

-- Customer Contact Import End

--Customer Import Begin
SET @NewHeaderId = 2

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Import','1'
END

UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Import',
	strCommand = '
	
	
	DECLARE @IsValid 		BIT

	SELECT @IsValid = 1,
			@ValidationMessage	= ''''

	declare @entityno								nvarchar(100)
	declare @name									nvarchar(100)
	declare @phone									nvarchar(100)
	declare @contactname							nvarchar(100)
	declare @suffix									nvarchar(100)
	declare @email									nvarchar(100)
	declare @mobileno								nvarchar(100)
	declare @locationname							nvarchar(100)


	declare @printedname							nvarchar(100)
	declare @address								nvarchar(100)
	declare @city									nvarchar(100)
	declare @state									nvarchar(100)
	declare @zip									nvarchar(100)
	declare @country								nvarchar(100)
	declare @timezone								nvarchar(100)
	declare @language								nvarchar(100)
	declare @documentdelivery						nvarchar(100)
	declare @externalerpid							nvarchar(100)
	declare @originationdate						nvarchar(100)
	declare @internalnotes							nvarchar(100)
	declare @detailtype								nvarchar(100)
	declare @detailaccountno						nvarchar(100)
	declare @detailcurrency							nvarchar(100)
	declare @detailpaymentmethod					nvarchar(100)
	declare @detailterms							nvarchar(100)
	declare @detailshipvia							nvarchar(100)
	declare @detailsalesperson						nvarchar(100)
	declare @detailwarehouse						nvarchar(100)
	declare @detailstatus							nvarchar(100)
	declare @detailfloid							nvarchar(100)
	declare @detailpricing							nvarchar(100)
	declare @detailtaxno							nvarchar(100)
	declare @detailexemptalltax						nvarchar(100)
	declare @detailtaxcounty						nvarchar(100)
	declare @detailvatnumber						nvarchar(100)
	declare @detailemployeecount					nvarchar(100)
	declare @detailrevenue							nvarchar(100)
	declare @detailcurrentsystem					nvarchar(100)
	declare @misccreditlimit						nvarchar(100)
	declare @misccreditstopdays						nvarchar(100)
	declare @misccreditcode							nvarchar(100)
	declare @miscactive								nvarchar(100)
	declare @miscporequired							nvarchar(100)
	declare @misccredithold							nvarchar(100)
	declare @miscbudgetbegindate					nvarchar(100)
	declare @miscbudgetmonthlybudget				nvarchar(100)
	declare @miscbudgetnoperiod						nvarchar(100)
	declare @miscbudgettiecustomeraging				nvarchar(100)
	declare @miscstatementdetail					nvarchar(100)
	declare @miscstatementcreditlimit				nvarchar(100)
	declare @miscstatementformat					nvarchar(100)
	declare @miscservicecharge						nvarchar(100)
	declare @misclastservicecharge					nvarchar(100)
	declare @miscapplyprepaidtax					nvarchar(100)
	declare @miscapplysalestax						nvarchar(100)
	declare @misccalcautofreight					nvarchar(100)
	declare @miscupdatequote						nvarchar(100)
	declare @miscdiscschedule						nvarchar(100)
	declare @miscprintinvoice						nvarchar(100)
	declare @misclinkcustomerno						nvarchar(100)
	declare @miscreferencebycustomer				nvarchar(100)
	declare @miscspecialpricegroup					nvarchar(100)
	declare @miscreceivedsignedlicense				nvarchar(100)
	declare @miscincluenameinaddress				nvarchar(100)
	declare @miscexcludedunningletter				nvarchar(100)
	declare @miscprintpriceonpickticket				nvarchar(100)
	
	
	declare @approvalnotrequired					nvarchar(100)
	declare @approvalinvoiceposting					nvarchar(100)
	declare @approvalovercreditlimit				nvarchar(100)
	declare @approvalorderapproval					nvarchar(100)
	declare @approvalquoteapproval					nvarchar(100)
	declare @approvalorderquantityshortage			nvarchar(100)
	declare @approvalreceivepaymentposting			nvarchar(100)
	declare @approvalcommision						nvarchar(100)
	declare @approvalpastdue						nvarchar(100)
	declare @approvalpricecharge					nvarchar(100)
	
	
	declare @grainlastdpcontractno					nvarchar(100) 
	declare @grainlastdpissuedate					nvarchar(100)
	declare @grainbankreceiptno						nvarchar(100)
	declare @graincheckoffexempt					nvarchar(100)
	declare @grainvoluntarycheckoff					nvarchar(100)
	declare @graincheckoffstate						nvarchar(100)
	declare @grainmarketagreementsigned				nvarchar(100)
	declare @grainmarketzone						nvarchar(100)
	declare @grainholdingprintinggraincheck			nvarchar(100)
	declare @grainfederalwithholding				nvarchar(100)
	declare @agrimineno								nvarchar(100)
	declare @agrimineharvestpartnercustomerno		nvarchar(100)
	declare @agriminecomments						nvarchar(100)
	declare @agriminetransmittedcustomer			nvarchar(100)
	declare @patronagemembershipdate				nvarchar(100)
	declare @patronagebirthdate						nvarchar(100)
	declare @patronagestockstatus					nvarchar(100)
	declare @patronagedeceaseddate					nvarchar(100)
	declare @patronagelastactivitydate				nvarchar(100)

	SELECT 
		@entityno = ''@entityno@'',														@name = ''@name@'',
		@phone = ''@phone@'',																@contactname= ''@contactname@'',
		@suffix = ''@suffix@'',															@email= ''@email@'',
		@mobileno = ''@mobileno@'',														@locationname= ''@locationname@'',
		@printedname = ''@printedname@'',													@address = ''@address@'',
		@city = ''@city@'',																@state = ''@state@'',
		@zip = ''@zip@'',																	@country = ''@country@'',
		@timezone = ''@timezone@'',														@language = ''@language@'',
		@documentdelivery = ''@documentdelivery@'',										@externalerpid = ''@externalerpid@'',
		@originationdate = ''@originationdate@'',											@internalnotes = ''@internalnotes@'',

		@detailtype = ''@detailtype@'',													@detailaccountno = ''@detailaccountno@'',
		@detailcurrency = ''@detailcurrency@'',											@detailpaymentmethod = ''@detailpaymentmethod@'',
		@detailterms = ''@detailterms@'',													@detailshipvia = ''@detailshipvia@'',
		@detailsalesperson = ''@detailsalesperson@'',										@detailwarehouse = ''@detailwarehouse@'',
		@detailstatus = ''@detailwarehouse@'',											@detailfloid = ''@detailfloid@'',
		@detailpricing = ''@detailpricing@'',												@detailtaxno = ''@detailtaxno@'',
		@detailexemptalltax = ''@detailexemptalltax@'',									@detailtaxcounty = ''@detailtaxcounty@'',
		@detailvatnumber = ''@detailvatnumber@'',											@detailemployeecount = ''@detailemployeecount@'',
		@detailrevenue = ''@detailrevenue@'',												@detailcurrentsystem = ''@detailcurrentsystem@'',

		@misccreditstopdays = ''@misccreditstopdays@'',									@misccreditcode = ''@misccreditcode@'',
		@miscactive = ''@miscactive@'',													@miscporequired = ''@miscporequired@'',
		@misccredithold = ''@misccredithold@'',											@miscbudgetbegindate = ''@miscbudgetbegindate@'',
		@miscbudgetmonthlybudget = ''@miscbudgetmonthlybudget@'',							@miscbudgetnoperiod = ''@miscbudgetnoperiod@'',
		@miscbudgettiecustomeraging = ''@miscbudgettiecustomeraging@'', 					@miscstatementdetail = ''@miscstatementdetail@'',
		@miscstatementcreditlimit = ''@miscstatementcreditlimit@'',						@miscstatementformat = ''@miscstatementformat@'',
		@miscservicecharge = ''@miscservicecharge@'',										@misclastservicecharge = ''@misclastservicecharge@'',
		@miscapplyprepaidtax = ''@miscapplyprepaidtax@'',									@miscapplysalestax = ''@miscapplysalestax@'',
		@misccalcautofreight = ''@misccalcautofreight@'',									@miscupdatequote = ''@miscupdatequote@'',
		@miscdiscschedule = ''@miscdiscschedule@'',										@miscprintinvoice = ''@miscprintinvoice@'',
		@misclinkcustomerno = ''@misclinkcustomerno@'',									@miscreferencebycustomer = ''@miscreferencebycustomer@'',
		@miscspecialpricegroup = ''@miscspecialpricegroup@'',								@miscreceivedsignedlicense = ''@miscreceivedsignedlicense@'',
		@miscincluenameinaddress = ''@miscincluenameinaddress@'',							@miscexcludedunningletter = ''@miscexcludedunningletter@'',
		@miscprintpriceonpickticket = ''@miscprintpriceonpickticket@'',					
		
		@approvalnotrequired = ''@approvalnotrequired@'',
		@approvalinvoiceposting = ''@approvalinvoiceposting@'',							@approvalovercreditlimit = ''@approvalovercreditlimit@'',
		@approvalorderapproval = ''@approvalorderapproval@'',								@approvalquoteapproval = ''@approvalquoteapproval@'',
		@approvalorderquantityshortage = ''@approvalorderquantityshortage@'',				@approvalreceivepaymentposting = ''@approvalreceivepaymentposting@'',
		@approvalcommision = ''@approvalcommision@'',										@approvalpastdue = ''@approvalpastdue@'',
		@approvalpricecharge = ''@approvalpricecharge@'',									
		
		
		
		@grainlastdpcontractno = ''@grainlastdpcontractno@'',
		@grainlastdpissuedate = ''@grainlastdpissuedate@'',								@grainbankreceiptno = ''@grainbankreceiptno@'',
		@graincheckoffexempt = ''@graincheckoffexempt@'',									@grainvoluntarycheckoff = ''@grainvoluntarycheckoff@'',
		@graincheckoffstate = ''@graincheckoffstate@'',									@grainmarketagreementsigned = ''@grainmarketagreementsigned@'',
		@grainmarketzone = ''@grainmarketzone@'',											@grainholdingprintinggraincheck = ''@grainholdingprintinggraincheck@'',
		@grainfederalwithholding = ''@grainfederalwithholding@'',							
		
		
		
		@agrimineno = ''@agrimineno@'',
		@agrimineharvestpartnercustomerno = ''@agrimineharvestpartnercustomerno@'',		@agriminecomments = ''@agriminecomments@'',
		@agriminetransmittedcustomer = ''@agriminetransmittedcustomer@'',					
		
		
		
		@patronagemembershipdate = ''@patronagemembershipdate@'',
		@patronagebirthdate = ''@patronagebirthdate@'',									@patronagestockstatus = ''@patronagestockstatus@'',
		@patronagedeceaseddate = ''@patronagedeceaseddate@'',								@patronagelastactivitydate = ''@patronagelastactivitydate@'',


		@IsValid = 1
	
		declare @entityId							int
		declare @contactId							int
		declare @locationId							int
		declare @languageId							int
		declare @originationdated					datetime
		declare @defaultCurId						int
		declare @detailPaymentMethodId				int
		declare @detailTermsId						int
		declare @detailShipViaId					int
		declare @detailSalespersonId				int
		declare @detailStatusId						int
		declare @detailTaxCodeId					int
		declare @detailCurrentSysId					int
		declare @miscbudgetbegindated				datetime
		declare @miscservicechargeid				int
		declare @misclastservicecharged				datetime
		declare @miscreferencebycustomerid			int
		declare @grainlastdpissuedated				datetime
		declare @grainmarketzoneid					int
		declare @patronagemembershipdated			datetime
		declare @patronagebirthdated				datetime			
		declare @patronagedeceaseddated				datetime
		declare @patronagelastactivitydated			datetime		
		declare @approvalinvoicepostingid			int		
		declare @approvalovercreditlimitid			int
		declare @approvalorderapprovalid			int
		declare @approvalquoteapprovalid			int
		declare @approvalorderquantityshortageid	int
		declare @approvalreceivepaymentpostingid	int
		declare @approvalcommisionid				int
		declare @approvalpastdueid					int
		declare @approvalpricechargeid				int

		if @entityno <> '''' 
		begin
			if exists(select top 1 intEntityId from tblEMEntity where strEntityNo = @entityno)
			begin
				set @ValidationMessage = ''Entity No already exists.''
				set @IsValid = 0
			end			
		end
		else
		begin			
			exec uspSMGetStartingNumber 43, @entityno OUT
		end

		if @language <> ''''
		begin
			select top 1 @languageId = intLanguageId from tblSMLanguage where strLanguage = @language
			if isnull(@languageId, 0) <= 0 
			begin
				set @ValidationMessage = @ValidationMessage + '', Language (''+  @language +'') does not exists.''
				set @IsValid = 0
			end
		end

		if @documentdelivery <> '''' and @documentdelivery not in (''Direct Mail'', ''Email'' , ''Fax'', ''Web Portal'')               
		begin
			set @ValidationMessage = @ValidationMessage + '', Document Delivery (''+  @documentdelivery +'') does not exists. Use one in (Direct Mail, Email, Fax, Web Portal).''
			set @IsValid = 0
		end
		if @originationdate <> ''''
		begin
			begin try
				select @originationdated = cast(@originationdate as datetime)
			end try
			begin catch
				set @originationdated = GETDATE()
			end catch
		end
		else
			set @originationdated = GETDATE()


		if @detailtype = '''' or @detailtype not in (''Company'', ''Person'')
		begin
			set @detailtype = ''Company''
		end

		if @detailcurrency <> ''''
		begin
			select @defaultCurId = intCurrencyID from tblSMCurrency where strCurrency = @detailcurrency
			if isnull(@defaultCurId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Currency (''+  @detailcurrency +'') does not exists.''
				set @IsValid = 0
			end
		end	
		
		
		if @detailpaymentmethod <> ''''
		begin
			select @detailPaymentMethodId = intPaymentMethodID from tblSMPaymentMethod where strPaymentMethod = @detailpaymentmethod
			if isnull(@detailPaymentMethodId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Payment Method (''+  @detailpaymentmethod +'') does not exists.''
				set @IsValid = 0
			end
		end
		
		if @detailterms <> ''''
		begin
			select @detailTermsId = intTermID from tblSMTerm where strTerm = @detailterms

			if isnull(@detailTermsId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Terms (''+  @detailterms +'') does not exists.''
				set @IsValid = 0
			end
		end

		if @detailshipvia <> ''''
		begin
			select @detailShipViaId = a.intEntityId from tblSMShipVia a
				join tblEMEntity b on a.intEntityId = b.intEntityId where a.strShipVia = @detailshipvia

			if isnull(@detailShipViaId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Ship Via (''+  @detailshipvia +'') does not exists.''
				set @IsValid = 0
			end
		end

		if @detailsalesperson <> ''''
		begin
			select @detailSalespersonId = a.intEntityId from tblARSalesperson a
				join tblEMEntity b on a.intEntityId = b.intEntityId 
					where a.strSalespersonId = @detailsalesperson or b.strEntityNo = @detailsalesperson

			if isnull(@detailSalespersonId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Salesperson (''+  @detailsalesperson +'') does not exists.''
				set @IsValid = 0
			end
		end

		if @detailstatus <> ''''
		begin
			
			select @detailStatusId = intAccountStatusId from tblARAccountStatus where strAccountStatusCode = @detailstatus

			if isnull(@detailStatusId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Status (''+  @detailstatus +'') does not exists.''
				set @IsValid = 0
			end
		end

		if @detailtaxcounty <> ''''
		begin
			
			select  @detailTaxCodeId = intTaxCodeId from tblSMTaxCode where strCounty <> ''''  and strCounty = @detailtaxcounty

			if isnull(@detailTaxCodeId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Tax County (''+  @detailtaxcounty +'') does not exists.''
				set @IsValid = 0
			end
		end

		if @detailcurrentsystem <> ''''
		begin
			select @detailCurrentSysId = a.intEntityId 
				from tblEMEntity a join tblEMEntityType b on a.intEntityId = b.intEntityId and b.strType = ''Competitor''
					where strName = @detailcurrentsystem
			
			if isnull(@detailCurrentSysId, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Current System (''+  @detailcurrentsystem +'') does not exists.''
				set @IsValid = 0
			end
			
		end

		if @misccreditcode <> '''' and @misccreditcode not in (''Always Allow'', ''Normal'' , ''Monitoring'', ''Always Hold'', ''Always Hold'', ''Reject Orders'')               
		begin
			set @ValidationMessage = @ValidationMessage + '', Credit Code (''+  @misccreditcode +'') does not exists. Use one in (Always Allow, Normal, Monitoring, Always Hold, Always Hold, Reject Orders).''
			set @IsValid = 0
		end

		if @miscbudgetbegindate <> ''''
		begin
			begin try
				select @miscbudgetbegindated = cast(@miscbudgetbegindate as datetime)
			end try
			begin catch
				SET @ValidationMessage	= @ValidationMessage + '',Budget Begin Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end catch
		end
		if @miscstatementformat <> '''' and @miscstatementformat not in (''Open Item'', ''Open Statement - Lazer'', ''Balance Forward'', ''Budget Reminder'', ''Payment Activity'', ''Running Balance'', ''Full Details - No Card Lock'', ''None'')               
		begin
			set @ValidationMessage = @ValidationMessage + '', Statement Format (''+  @miscstatementformat +'') does not exists. Use one in (Open Item, Open Statement - Lazer, Balance Forward, Budget Reminder, Payment Activity, Running Balance, Full Details - No Card Lock, None).''
			set @IsValid = 0
		end

		if @miscservicecharge <> ''''
		begin
			
			select @miscservicechargeid = intServiceChargeId from tblARServiceCharge where strServiceChargeCode = @miscservicecharge

			if isnull(@miscservicechargeid, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Service Charge (''+  @miscservicecharge +'') does not exists.''
				set @IsValid = 0
			end
		end
		
		if @misclastservicecharge <> ''''
		begin
			begin try
				select @misclastservicecharged = cast(@misclastservicecharge as datetime)
			end try
			begin catch
				SET @ValidationMessage	= @ValidationMessage + '',Last Service Charge Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end catch
		end		

		if @miscupdatequote <> '''' and @miscupdatequote not in (''Yes'', ''No'', ''Deviation'')               
		begin
			set @ValidationMessage = @ValidationMessage + '', Update Quote (''+  @miscupdatequote +'') does not exists. Use one in (Yes, No, Deviation).''
			set @IsValid = 0
		end	

		if @miscprintinvoice <> '''' and @miscprintinvoice not in (''Yes'', ''Petrolac Only'', ''Transports Only'',''None'')               
		begin
			set @ValidationMessage = @ValidationMessage + '', Print Invoice(''+  @miscprintinvoice +'') does not exists. Use one in (Yes, Petrolac Only,Transports Only,None).''
			set @IsValid = 0
		end



		if @miscreferencebycustomer <> ''''
		begin
			select @miscreferencebycustomerid = a.intEntityId 
				from tblEMEntity a join tblEMEntityType b on a.intEntityId = b.intEntityId and b.strType = ''Customer''
					where a.strEntityNo = @miscreferencebycustomer
			
			if isnull(@miscreferencebycustomerid, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Customer (''+  @miscreferencebycustomer +'') does not exists.''
				set @IsValid = 0
			end
			
		end		


		
		if lower(isnull(@approvalnotrequired, '''')) in ( ''1'',''y'',''yes'',''true'')
		begin
			select @approvalinvoicepostingid = null,
					@approvalovercreditlimitid = null,
					@approvalorderapprovalid = null,
					@approvalquoteapprovalid = null,
					@approvalorderquantityshortageid = null,
					@approvalreceivepaymentpostingid = null,
					@approvalcommisionid = null,
					@approvalpastdueid = null,
					@approvalpricechargeid = null
		end
		else
		begin
			if @approvalinvoiceposting <> ''''
			begin
				
				select @approvalinvoicepostingid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalinvoiceposting
				if isnull(@approvalinvoicepostingid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Invoice Posting (''+  @approvalinvoiceposting +'') does not exists.''
					set @IsValid = 0
				end			
			end	
			
			if @approvalovercreditlimit <> ''''
			begin
				
				select @approvalovercreditlimitid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalovercreditlimit
				if isnull(@approvalovercreditlimitid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Over Credit Limit (''+  @approvalovercreditlimit +'') does not exists.''
					set @IsValid = 0
				end			
			end	
			
			if @approvalorderapproval <> ''''
			begin
				
				select @approvalorderapprovalid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalorderapproval
				if isnull(@approvalorderapprovalid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Order Approval (''+  @approvalorderapproval +'') does not exists.''
					set @IsValid = 0
				end			
			end		
			
			if @approvalquoteapproval <> ''''
			begin
				
				select @approvalquoteapprovalid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalquoteapproval
				if isnull(@approvalquoteapprovalid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Qoute Approval (''+  @approvalquoteapproval +'') does not exists.''
					set @IsValid = 0
				end			
			end		
			
			if @approvalorderquantityshortage <> ''''
			begin
				
				select @approvalorderquantityshortageid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalorderquantityshortage
				if isnull(@approvalorderquantityshortageid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Order Quantity Shortage (''+  @approvalorderquantityshortage +'') does not exists.''
					set @IsValid = 0
				end			
			end	
			
			if @approvalreceivepaymentposting <> ''''
			begin
				
				select @approvalreceivepaymentpostingid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalreceivepaymentposting
				if isnull(@approvalreceivepaymentpostingid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Receive Payment Posting (''+  @approvalreceivepaymentposting +'') does not exists.''
					set @IsValid = 0
				end			
			end	
			
			if @approvalcommision <> ''''
			begin
				
				select @approvalcommisionid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalcommision
				if isnull(@approvalcommisionid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Commisions (''+  @approvalcommision +'') does not exists.''
					set @IsValid = 0
				end			
			end	
			
			if @approvalpastdue <> ''''
			begin
				
				select @approvalpastdueid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalpastdue
				if isnull(@approvalpastdueid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Past Due (''+  @approvalpastdue +'') does not exists.''
					set @IsValid = 0
				end			
			end	
			
			if @approvalpricecharge <> ''''
			begin
				
				select @approvalpricechargeid = intApprovalListId from tblSMApprovalList where strApprovalList = @approvalpricecharge
				if isnull(@approvalpricechargeid, 0) <= 0
				begin
					set @ValidationMessage = @ValidationMessage + '', Price Change (''+  @approvalpricecharge +'') does not exists.''
					set @IsValid = 0
				end			
			end					
	
		end
		

		if @grainlastdpissuedate <> ''''
		begin
			begin try
				select @grainlastdpissuedated = cast(@grainlastdpissuedate as datetime)
			end try
			begin catch
				SET @ValidationMessage	= @ValidationMessage + '',Last DP Issue Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end catch
		end	


		if @grainmarketzone <> ''''
		begin
			select @grainmarketzoneid = intMarketZoneId from tblARMarketZone where strMarketZoneCode = @grainmarketzone

			if isnull(@grainmarketzoneid, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Market Zone (''+  @grainmarketzone +'') does not exists.''
				set @IsValid = 0
			end
		end
		
		if @patronagemembershipdate <> ''''
		begin
			begin try
				select @patronagemembershipdated = cast(@patronagemembershipdate as datetime)
			end try
			begin catch
				SET @ValidationMessage	= @ValidationMessage + '',Membership Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end catch
		end	
		if @patronagebirthdate <> ''''
		begin
			begin try
				select @patronagebirthdated = cast(@patronagebirthdate as datetime)
			end try
			begin catch
				SET @ValidationMessage	= @ValidationMessage + '',Birth Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end catch
		end					 
				
		if @patronagestockstatus <> '''' and @patronagestockstatus not in (''Voting'', ''Non-Voting'', ''Producer'', ''Other'')               
		begin
			set @ValidationMessage = @ValidationMessage + '', Stock Status (''+  @patronagestockstatus +'') does not exists. Use one in (Voting, Non-Voting, Producer, Other).''
			set @IsValid = 0
		end	

		if @patronagedeceaseddate <> ''''
		begin
			begin try
				select @patronagedeceaseddated = cast(@patronagedeceaseddate as datetime)
			end try
			begin catch
				SET @ValidationMessage	= @ValidationMessage + '',Deceased Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end catch
		end	
		if @patronagelastactivitydate <> ''''
		begin
			begin try
				select @patronagelastactivitydated = cast(@patronagelastactivitydate as datetime)
			end try
			begin catch
				SET @ValidationMessage	= @ValidationMessage + '',Last Activity Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end catch
		end	
		


		if isnull(@printedname, '''') = ''''
		BEGIN
			SET @printedname = @name
		END

		if @IsValid = 1 
		begin

			insert into tblEMEntity(strEntityNo, strName, strContactNumber, dtmOriginationDate, strDocumentDelivery, strExternalERPId)
			select @entityno, @name, '''', @originationdated, @documentdelivery, @externalerpid

			set @entityId = @@IDENTITY

			insert into tblEMEntity(strName, strContactNumber, strSuffix, strEmail, intLanguageId, strInternalNotes)
			select @contactname, '''', @suffix, @email, @languageId, @internalnotes

			set @contactId = @@IDENTITY

			insert into tblEMEntityLocation(intEntityId, strLocationName, strCheckPayeeName, strAddress, strCity, strState, strZipCode, strCountry, strTimezone, intDefaultCurrencyId, intTermsId, intShipViaId, ysnDefaultLocation)
			select @entityId, @locationname, @printedname, @address, @city, @state, @zip, @country, @timezone, @defaultCurId, @detailTermsId, @detailShipViaId, 1

			set @locationId = @@IDENTITY

			insert into tblEMEntityToContact(intEntityId, intEntityContactId, intEntityLocationId, ysnPortalAccess, ysnDefaultContact)
			select @entityId, @contactId, @locationId, 0, 1
			
			insert into tblEMEntityType( intEntityId, strType, intConcurrencyId)
			SELECT @entityId, ''Customer'', 1

			insert into tblARCustomer(intEntityId, strType, strAccountNumber, intCurrencyId, intPaymentMethodId, intTermsId, intSalespersonId, strFLOId,
				strTaxNumber,
				ysnTaxExempt,
				intTaxCodeId, strVatNumber,
				intEmployeeCount,
				dblRevenue,
				dblCreditLimit,
				intCreditStopDays,
				strCreditCode,
				ysnActive,
				ysnPORequired,
				ysnCreditHold,
				dtmBudgetBeginDate,
				dblMonthlyBudget,
				intNoOfPeriods,
				ysnCustomerBudgetTieBudget,
				ysnStatementDetail,
				ysnStatementCreditLimit,
				strStatementFormat,
				intServiceChargeId,
				dtmLastServiceCharge,
				ysnApplyPrepaidTax,
				ysnApplySalesTax,
				ysnCalcAutoFreight,
				strUpdateQuote,
				strDiscSchedule,
				strPrintInvoice,
				strLinkCustomerNumber,
				intReferredByCustomer,
				ysnSpecialPriceGroup,
				ysnExcludeDunningLetter,
				ysnReceivedSignedLiscense,
				ysnPrintPriceOnPrintTicket,
				ysnIncludeEntityName,
				strDPAContract,
				dtmDPADate,
				strGBReceiptNumber,
				ysnCheckoffExempt,
				ysnVoluntaryCheckoff,
				strCheckoffState,
				ysnMarketAgreementSigned,
				intMarketZoneId,
				ysnHoldBatchGrainPayment,
				ysnFederalWithholding,
				strAgrimineId,
				strHarvestPartnerCustomerId,
				strComments,
				ysnTransmittedCustomer,
				dtmMembershipDate,
				dtmBirthDate,
				strStockStatus,
				dtmDeceasedDate,
				dtmLastActivityDate,


				ysnApprovalsNotRequired,
				intInvoicePostingApprovalId,
				intOverCreditLimitApprovalId,
				intOrderApprovalApprovalId,
				intQuoteApprovalApprovalId,
				intOrderQuantityShortageApprovalId,
				intReceivePaymentPostingApprovalId,
				intCommisionsApprovalId,
				intPastDueApprovalId,
				intPriceChangeApprovalId,
				intBillToId,
				intShipToId,
				



				dblARBalance
				)

			select @entityId, @detailtype, @detailaccountno, @defaultCurId, @detailPaymentMethodId, @detailTermsId, @detailSalespersonId, @detailfloid,
				@detailtaxno,
				case when lower(isnull(@detailexemptalltax, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@detailTaxCodeId, @detailvatnumber,
				case when isnull(@detailemployeecount, '''') <> '''' and ISNUMERIC(@detailemployeecount) = 1 then @detailemployeecount else 0 end,
				case when isnull(@detailrevenue, '''') <> '''' and ISNUMERIC(@detailrevenue) = 1 then @detailrevenue else 0 end,
				case when isnull(@misccreditlimit, '''') <> '''' and ISNUMERIC(@misccreditlimit) = 1 then @misccreditlimit else 0 end,
				case when isnull(@misccreditstopdays, '''') <> '''' and ISNUMERIC(@misccreditstopdays) = 1 then @misccreditstopdays else 0 end,
				@misccreditcode,
				case when lower(isnull(@miscactive, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscporequired, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@misccredithold, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@miscbudgetbegindated,
				case when isnull(@miscbudgetmonthlybudget, '''') <> '''' and ISNUMERIC(@miscbudgetmonthlybudget) = 1 then @miscbudgetmonthlybudget else 0 end,
				case when isnull(@miscbudgetnoperiod, '''') <> '''' and ISNUMERIC(@miscbudgetnoperiod) = 1 then @miscbudgetnoperiod else 0 end,
				case when lower(isnull(@miscbudgettiecustomeraging, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscstatementdetail, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscstatementcreditlimit, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@miscstatementformat,
				@miscservicechargeid,
				@misclastservicecharged,
				case when lower(isnull(@miscapplyprepaidtax, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscapplysalestax, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@misccalcautofreight, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@miscupdatequote,
				case when isnull(@miscdiscschedule, '''') <> '''' and ISNUMERIC(@miscdiscschedule) = 1 then @miscdiscschedule else 0 end,
				@miscprintinvoice,
				@misclinkcustomerno,
				@miscreferencebycustomerid,
				case when lower(isnull(@miscspecialpricegroup, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscexcludedunningletter, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscreceivedsignedlicense, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscprintpriceonpickticket, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@miscincluenameinaddress, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@grainlastdpcontractno,
				@grainlastdpissuedated,
				@grainbankreceiptno,
				case when lower(isnull(@graincheckoffexempt, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@grainvoluntarycheckoff, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@graincheckoffstate,
				case when lower(isnull(@grainmarketagreementsigned, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@grainmarketzoneid,
				case when lower(isnull(@grainholdingprintinggraincheck, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				case when lower(isnull(@grainfederalwithholding, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@agrimineno,
				@agrimineharvestpartnercustomerno,
				@agriminecomments,
				case when lower(isnull(@agriminetransmittedcustomer, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@patronagemembershipdated,
				@patronagebirthdated,
				@patronagestockstatus,
				@patronagedeceaseddated,
				@patronagelastactivitydated,
				case when lower(isnull(@misccalcautofreight, '''')) in ( ''1'',''y'',''yes'',''true'') then 1 else 0 end,
				@approvalinvoicepostingid,
				@approvalovercreditlimitid,
				@approvalorderapprovalid,
				@approvalquoteapprovalid,
				@approvalorderquantityshortageid,
				@approvalreceivepaymentpostingid,
				@approvalcommisionid,
				@approvalpastdueid,
				@approvalpricechargeid,
				@locationId,
				@locationId,





				0
				





			if @phone <> ''''
			BEGIN			
				insert into tblEMEntityPhoneNumber(intEntityId, strPhone)
				select @contactId, @phone
			END

			if @mobileno <> ''''
			BEGIN			
				insert into tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)
				select @contactId, @mobileno, null
			END

			if isnull(@detailStatusId, 0) > 0 
				insert into tblARCustomerAccountStatus( intEntityCustomerId, intAccountStatusId)
				select @entityId, @detailStatusId
			
			if isnull(@detailCurrentSysId, 0) > 0
				insert into tblARCustomerCompetitor(intEntityCustomerId, intEntityId)
					select @entityId, @detailCurrentSysId


		end

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityno', 'Customer Entity No', 0
	UNION All
	SELECT @NewHeaderId, 'name', 'Name*', 1
	UNION All
	SELECT @NewHeaderId, 'contactname', 'Contact Name*', 1
	UNION All
	SELECT @NewHeaderId, 'locationname', 'Location Name*', 1
	UNION All
	SELECT @NewHeaderId, 'detailcurrency', 'Detail Currency*', 1
	UNION All
	SELECT @NewHeaderId, 'detailterms', 'DetailTerms*', 1
	Union All
	SELECT @NewHeaderId, 'phone', 'Phone', 0
	Union All
	SELECT @NewHeaderId, 'suffix', 'Suffix', 0
	Union All
	SELECT @NewHeaderId, 'email', 'Email', 0
	Union All
	SELECT @NewHeaderId, 'mobileno', 'Mobile No', 0
	Union All
	SELECT @NewHeaderId, 'printedname', 'Printed Name', 0
	Union All
	SELECT @NewHeaderId, 'address', 'Address', 0
	Union All
	SELECT @NewHeaderId, 'city', 'City', 0
	Union All
	SELECT @NewHeaderId, 'state', 'State', 0
	Union All
	SELECT @NewHeaderId, 'zip', 'Zip', 0
	Union All
	SELECT @NewHeaderId, 'country', 'Country', 0
	Union All
	SELECT @NewHeaderId, 'timezone', 'TimeZone', 0
	Union All
	SELECT @NewHeaderId, 'language', 'Language', 0
	Union All
	SELECT @NewHeaderId, 'documentdelivery', 'Document Delivery', 0
	Union All
	SELECT @NewHeaderId, 'externalerpid', 'External ERP Id', 0
	Union All
	SELECT @NewHeaderId, 'originationdate', 'Origination Date', 0
	Union All
	SELECT @NewHeaderId, 'internalnotes', 'Internal Notes', 0
	etail
	Union All
	SELECT @NewHeaderId, 'detailtype', 'Detail Type', 0
	Union All
	SELECT @NewHeaderId, 'detailaccountno', 'Detail Account No', 0
	Union All
	SELECT @NewHeaderId, 'detailpaymentmethod', 'Detail Payment Method', 0
	Union All
	SELECT @NewHeaderId, 'detailshipvia', 'Detail Ship Via', 0
	Union All
	SELECT @NewHeaderId, 'detailsalesperson', 'Detail Salesperson', 0
	Union All
	SELECT @NewHeaderId, 'detailwarehouse', 'Detail Warehouse', 0
	Union All
	SELECT @NewHeaderId, 'detailstatus', 'Detail Status', 0
	Union All
	SELECT @NewHeaderId, 'detailfloid', 'Detail Flo Id', 0
	Union All
	SELECT @NewHeaderId, 'detailpricing', 'Detail Pricing', 0
	Union All
	SELECT @NewHeaderId, 'detailtaxno', 'Detail Tax No', 0
	Union All
	SELECT @NewHeaderId, 'detailexemptalltax', 'Detail Exempt All Tax', 0
	Union All
	SELECT @NewHeaderId, 'detailtaxcounty', 'Detail Tax County', 0
	Union All
	SELECT @NewHeaderId, 'detailvatnumber', 'Detail Vat Number', 0
	Union All
	SELECT @NewHeaderId, 'detailemployeecount', 'Detail Employee Count', 0
	Union All
	SELECT @NewHeaderId, 'detailrevenue', 'Detail Revenue', 0
	Union All
	SELECT @NewHeaderId, 'detailcurrentsystem', 'Detail Current System', 0
	--Misc
	Union All
	SELECT @NewHeaderId, 'misccreditlimit', 'Misc Credit Limit', 0
	Union All
	SELECT @NewHeaderId, 'misccreditstopdays', 'Misc CreditStop Days', 0
	Union All
	SELECT @NewHeaderId, 'misccreditcode', 'Misc Credit Code', 0
	Union All
	SELECT @NewHeaderId, 'miscactive', 'Misc Active', 0
	Union All
	SELECT @NewHeaderId, 'miscporequired', 'Misc PO Required', 0
	Union All
	SELECT @NewHeaderId, 'misccredithold', 'Misc Credit Hold', 0
	Union All
	SELECT @NewHeaderId, 'miscbudgetbegindate', 'Misc Budget Begin Date', 0
	Union All
	SELECT @NewHeaderId, 'miscbudgetmonthlybudget', 'Misc Budget Monthly Budget', 0
	Union All
	SELECT @NewHeaderId, 'miscbudgetnoperiod', 'Misc Budget No Period', 0
	Union All
	SELECT @NewHeaderId, 'miscbudgettiecustomeraging', 'Misc Budget Tie Customer Aging', 0
	Union All
	SELECT @NewHeaderId, 'miscstatementdetail', 'Misc Statement Detail', 0
	Union All
	SELECT @NewHeaderId, 'miscstatementcreditlimit', 'Misc Statement Credit Limit', 0
	Union All
	SELECT @NewHeaderId, 'miscstatementformat', 'Misc Statement Format', 0
	Union All
	SELECT @NewHeaderId, 'miscservicecharge', 'Misc Service Charge', 0
	Union All
	SELECT @NewHeaderId, 'misclastservicecharge', 'Misc Last Service Charge', 0
	Union All
	SELECT @NewHeaderId, 'miscapplyprepaidtax', 'Misc Apply Prepaid Tax', 0
	Union All
	SELECT @NewHeaderId, 'miscapplysalestax', 'Misc Apply Sales Tax', 0
	Union All
	SELECT @NewHeaderId, 'misccalcautofreight', 'Misc Calc Auto Freight', 0
	Union All
	SELECT @NewHeaderId, 'miscupdatequote', 'Misc Update Quote', 0
	Union All
	SELECT @NewHeaderId, 'miscdiscschedule', 'Misc Disc Schedule', 0
	Union All
	SELECT @NewHeaderId, 'miscprintinvoice', 'Misc Print Invoice', 0
	Union All
	SELECT @NewHeaderId, 'misclinkcustomerno', 'Misc Link Customer No', 0
	Union All
	SELECT @NewHeaderId, 'miscreferencebycustomer', 'Misc Reference By Customer', 0
	Union All
	SELECT @NewHeaderId, 'miscspecialpricegroup', 'Misc Special Price Group', 0
	Union All
	SELECT @NewHeaderId, 'miscreceivedsignedlicense', 'Misc Received Signed License', 0
	Union All
	SELECT @NewHeaderId, 'miscincluenameinaddress', 'Misc Inclue Name In Address', 0
	Union All
	SELECT @NewHeaderId, 'miscexcludedunningletter', 'Misc Exclude Dunning Letter', 0
	Union All
	SELECT @NewHeaderId, 'miscprintpriceonpickticket', 'Misc Print Price On Pick Ticket', 0
	--Approval
	Union All
	SELECT @NewHeaderId, 'approvalnotrequired', 'Approval Not Required', 0
	Union All
	SELECT @NewHeaderId, 'approvalinvoiceposting', 'Approval Invoice Posting', 0
	Union All
	SELECT @NewHeaderId, 'approvalovercreditlimit', 'Approval Over Credit Limit', 0
	Union All
	SELECT @NewHeaderId, 'approvalorderapproval', 'Approval Order Approval', 0
	Union All
	SELECT @NewHeaderId, 'approvalquoteapproval', 'Approval Quote Approval', 0
	Union All
	SELECT @NewHeaderId, 'approvalorderquantityshortage', 'Approval Order Quantity Shortage', 0
	Union All
	SELECT @NewHeaderId, 'approvalreceivepaymentposting', 'Approval Receive Payment Posting', 0
	Union All
	SELECT @NewHeaderId, 'approvalcommision', 'Approval Commision', 0
	Union All
	SELECT @NewHeaderId, 'approvalpastdue', 'Approval Past Due', 0
	Union All
	SELECT @NewHeaderId, 'approvalpricecharge', 'Approval Price Charge', 0
	--Grain
	Union All
	SELECT @NewHeaderId, 'grainlastdpcontractno', 'Grain Last DP Contract No', 0
	Union All
	SELECT @NewHeaderId, 'grainlastdpissuedate', 'Grain Last DP Issue Date', 0
	Union All
	SELECT @NewHeaderId, 'grainbankreceiptno', 'Grain Bank Receipt No', 0
	Union All
	SELECT @NewHeaderId, 'graincheckoffexempt', 'Grain Checkoff Exempt', 0
	Union All
	SELECT @NewHeaderId, 'grainvoluntarycheckoff', 'Grain Voluntary Checkoff', 0
	Union All
	SELECT @NewHeaderId, 'graincheckoffstate', 'Grain Checkoff State', 0
	Union All
	SELECT @NewHeaderId, 'grainmarketagreementsigned', 'Grain Market Agreement Signed', 0
	Union All
	SELECT @NewHeaderId, 'grainmarketzone', 'Grain Market Zone', 0
	Union All
	SELECT @NewHeaderId, 'grainholdingprintinggraincheck', 'Grain Holding Printing Grain Check', 0
	Union all
	SELECT @NewHeaderId, 'grainfederalwithholding', 'Grain Federal With Holding', 0
	--Agrimine
	Union All
	SELECT @NewHeaderId, 'agrimineno', 'Agrimine No', 0
	Union All
	SELECT @NewHeaderId, 'agrimineharvestpartnercustomerno', 'Agrimine Harvest Partner Customer No', 0
	Union All
	SELECT @NewHeaderId, 'agriminecomments', 'Agrimine Comments', 0
	Union all
	SELECT @NewHeaderId, 'agriminetransmittedcustomer', 'Agrimine Transmitted Customer', 0
	--Patronage
	Union All
	SELECT @NewHeaderId, 'patronagemembershipdate', 'Patronage Membership Date', 0
	Union All
	SELECT @NewHeaderId, 'patronagebirthdate', 'Patronage Birth Date', 0
	Union All
	SELECT @NewHeaderId, 'patronagestockstatus', 'Patronage Stock Status', 0
	Union All
	SELECT @NewHeaderId, 'patronagedeceaseddate', 'Patronage Deceased Date', 0
	Union All
	SELECT @NewHeaderId, 'patronagelastactivitydate', 'Patronage Last Activity Date', 0
--Customer Import End
-- Customer Special Taxing Import Begin
SET @NewHeaderId = 3

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Special Taxing Import','1'
END



UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Special Taxing Import',
	strCommand = '
	DECLARE @EntityId 		INT
	DECLARE @EntityNo 		NVARCHAR(100)
	--validation stage
	DECLARE @IsValid 		BIT

	DECLARE @TaxGroup		NVARCHAR(100)
	DECLARE @TaxGroupId		INT
	DECLARE @CusLoc			NVARCHAR(100)
	DECLARE @CusLocId		INT
	DECLARE @VenNo			NVARCHAR(100)
	DECLARE @VenNoId		INT
	DECLARE @ItemCat		NVARCHAR(100)
	DECLARE @ItemNo			NVARCHAR(100)
	DECLARE @ItemCatId		INT
	DECLARE @ItemNoId		INT

	SELECT @CusLoc = ''@cusloc@'',
			@VenNo = ''@venno@'',
			@ItemCat = ''@itemcat@'',
			@ItemNo = ''@itemno@'',
			@TaxGroup = ''@taxgroup@'',
			@EntityNo = ''@entityCustomerId@'',


			@TaxGroupId 	= NULL,
			@CusLocId 		= NULL,
			@VenNoId		= NULL,
			@ItemCatId 		= NULL,
			@ItemNoId		= NULL



	SET @IsValid = 1
	SET @ValidationMessage	= ''''

	SELECT @EntityId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Customer'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @EntityNo



	SELECT TOP 1 @VenNoId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Vendor'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @VenNo


	SELECT TOP 1 @TaxGroupId = intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = @TaxGroup

	IF ISNULL(@TaxGroupId, 0) <= 0 AND @TaxGroup <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Tax Group does not exists''
		SET @IsValid = 0
	END

	IF ISNULL(@VenNoId, 0) <= 0 AND @VenNo <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Vendor does not exists''
		SET @IsValid = 0
	END

	select

		@ItemNoId = CASE WHEN @ItemNo <> '''' THEN ITM.intItemId ELSE NULL END,
		--ITM.strItemNo,
		@ItemCatId = CASE WHEN @ItemCat <> '''' THEN CAT.intCategoryId ELSE NULL END--,
		--CAT.strCategoryCode
		from tblICItem ITM
	JOIN ( select intCategoryId, strCategoryCode from tblICCategory) CAT
		on ITM.intCategoryId = CAT.intCategoryId

	WHERE
		( (@ItemCat <> '''' and @ItemNo <> '''' )  and @ItemNo = ITM.strItemNo and @ItemCat = CAT.strCategoryCode)
		OR ( (@ItemCat = '''' and @ItemNo <> '''' )  and @ItemNo = ITM.strItemNo)
		OR ( (@ItemCat <> '''' and @ItemNo = '''' ) and @ItemCat = CAT.strCategoryCode)

	IF (ISNULL(@ItemNoId, 0)) <= 0 AND @ItemNo <> ''''	AND (ISNULL(@ItemCatId, 0)) <= 0 AND @ItemCat <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Item and Cateogry does not exists''
		SET @IsValid = 0
	END
	ELSE IF (ISNULL(@ItemNoId, 0)) <= 0 AND @ItemNo <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Item does not exists''
		SET @IsValid = 0
	END
	ELSE IF (ISNULL(@ItemCatId, 0)) <= 0 AND @ItemCat <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Category does not exists''
		SET @IsValid = 0
	END

	IF ISNULL(@EntityId, 0) > 0 AND @CusLoc <> ''''
	BEGIN
		SELECT @CusLocId = intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @EntityId AND strLocationName = @CusLoc
		IF ISNULL(@CusLocId,0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Customer Location does not exists''
			SET @IsValid = 0
		END
	END



	IF ISNULL(@EntityId, 0) > 0
	BEGIN
		IF (@IsValid = 1)
		BEGIN

			INSERT INTO tblARSpecialTax(
					intEntityCustomerId, 	intEntityVendorId, 		intItemId,
					intCategoryId, 			intTaxGroupId, 			intEntityCustomerLocationId)
			SELECT 	@EntityId,				@VenNoId, 				@ItemNoId,
					@ItemCatId, 			@TaxGroupId, 			@CusLocId
		END

	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Customer (@entityCustomerId@) does not exists.''
	END

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	UNION All
	SELECT @NewHeaderId, 'taxgroup', 'Tax Group*', 1
	Union All
	SELECT @NewHeaderId, 'cusloc', 'Customer Location', 0
	Union All
	SELECT @NewHeaderId, 'venno', 'Vendor No', 0
	Union All
	SELECT @NewHeaderId, 'itemcat', 'Item Category', 0
	Union All
	SELECT @NewHeaderId, 'itemno', 'Item No', 0
-- Customer Special Taxing Import End


--License Tab Begin

SET @NewHeaderId = 4

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Master License Import','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Master License Import',
	strCommand = '
	DECLARE @EntityId 		INT
	DECLARE @EntityNo 		NVARCHAR(100)
	--validation stage
	DECLARE @IsValid 		BIT

	SELECT @IsValid = 1,
			@ValidationMessage	= ''''
	DECLARE @LicenseCode 	NVARCHAR(100)
	DECLARE @LicenseCodeId 	INT
	DECLARE @BeginDateS		NVARCHAR(100)
	DECLARE @BeginDate		DATETIME
	DECLARE @EndDateS		NVARCHAR(100)
	DECLARE @EndDate		DATETIME
	DECLARE @Comments		NVARCHAR(100)
	DECLARE @ActiveS		NVARCHAR(100)
	DECLARE @Active			BIT


	SELECT
			@EntityNo = ''@entityCustomerId@'',
			@LicenseCode = ''@liccode@'',
			@BeginDateS = ''@begdate@'',
			@EndDateS = ''@enddate@'',
			@Comments = ''@com@'',
			@ActiveS = LOWER(''@active@''),


			@LicenseCodeId 	= NULL,
			@BeginDate 		= NULL,
			@EndDate		= NULL,
			@Active 		= NULL,
			@EntityId		= NULL




	SELECT @EntityId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Customer'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @EntityNo

	IF ISNULL(@LicenseCode, '''') <> ''''
	BEGIN

		SELECT @LicenseCodeId = intLicenseTypeId FROM tblSMLicenseType where strCode = @LicenseCode

		IF ISNULL(@LicenseCodeId, 0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',License Code does not exists.''
			SET @IsValid = 0
		END
	END


	IF @BeginDateS <> ''''
	BEGIN

		BEGIN TRY
			SELECT @BeginDate = CAST(@BeginDateS AS DATETIME)
		END TRY
		BEGIN CATCH
			SET @ValidationMessage	= @ValidationMessage + '',Begin Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
			SET @IsValid = 0
		END CATCH
	END

	IF @EndDateS <> ''''
	BEGIN

		BEGIN TRY
			SELECT @EndDate = CAST(@EndDateS AS DATETIME)
		END TRY
		BEGIN CATCH
			SET @ValidationMessage	= @ValidationMessage + '',End Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
			SET @IsValid = 0

		END CATCH
	END

	IF @BeginDate IS NOT NULL AND @EndDate IS NOT NULL AND @BeginDate > @EndDate
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Begin Date should not be greater than End Date.''
		SET @IsValid = 0
	END

	IF @ActiveS = ''1'' OR @ActiveS = ''yes'' OR @ActiveS = ''true''
	BEGIN
		SET @Active = 1
	END

	IF ISNULL(@EntityId, 0) > 0
	BEGIN


		IF (@IsValid = 1)
		BEGIN
			if not exists(select top 1 1 
							from tblARCustomerMasterLicense 
								where intEntityCustomerId = @EntityId and 
									intLicenseTypeId = @LicenseCodeId
							)
			begin
				INSERT INTO tblARCustomerMasterLicense(
					intEntityCustomerId, 	intLicenseTypeId,
					dtmBeginDate, 			dtmEndDate,
					strComment, 			ysnAcvite)
				SELECT
					@EntityId,				@LicenseCodeId,
					@BeginDate,				@EndDate,
					@Comments,				@Active				
			end
			else
			begin
				RAISERROR(''Customer and License Code combination already exists.'', 16, 1);
			end
			
		END

	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Customer (@entityCustomerId@) does not exists.''
	END

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	UNION All
	SELECT @NewHeaderId, 'liccode', 'License Code*', 1
	Union All
	SELECT @NewHeaderId, 'begdate', 'Begin Date', 0
	Union All
	SELECT @NewHeaderId, 'enddate', 'End Date', 0
	Union All
	SELECT @NewHeaderId, 'com', 'Comment', 0
	Union All
	SELECT @NewHeaderId, 'active', 'Active', 0


--License Tab End
--Transport Freight Tab Begin
SET @NewHeaderId = 5

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Transport Freight Import','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Transport Freight Import',
	strCommand = '
	DECLARE @EntityId 		INT
	DECLARE @EntityNo 		NVARCHAR(100)
	
	DECLARE @IsValid 		BIT

	SELECT @IsValid = 1,
			@ValidationMessage	= ''''

	DECLARE @CusLoc			NVARCHAR(100)
	DECLARE @CusLocId		INT
	DECLARE @ZipCode 		NVARCHAR(100)
	DECLARE @ItemCat		NVARCHAR(100)
	DECLARE @ItemCatId		INT
	DECLARE @FreightOnly	NVARCHAR(100)
	DECLARE @FreightOnlyB	BIT
	DECLARE @FreightType	NVARCHAR(100)
	DECLARE @ShipVia		NVARCHAR(100)
	DECLARE @ShipViaId		INT
	DECLARE @AmountS		NVARCHAR(100)
	DECLARE @Amount			NUMERIC (18, 6)	
	DECLARE @RateS			NVARCHAR(100)
	DECLARE @Rate			NUMERIC (18, 6)
	DECLARE @MilesS			NVARCHAR(100)
	DECLARE @Miles			NUMERIC (18, 6)
	DECLARE @FreightPrice	NVARCHAR(100)
	DECLARE @FreightPriceB	BIT
	DECLARE @UnitS			NVARCHAR(100)
	DECLARE @Unit			NUMERIC (18, 6)	

	SELECT
			@EntityNo 		= ''@entityCustomerId@'',
			@CusLoc 		= ''@cusloc@'',
			@ZipCode 		= ''@zipcode@'',
			@ItemCat 		= ''@itemcat@'',
			@FreightOnly 	= LOWER(''@freightonly@''),
			@FreightType 	= ''@freighttype@'',
			@ShipVia 		= ''@freightshipvia@'',
			@AmountS		= ''@freightamount@'',
			@RateS			= ''@freightrate@'',
			@MilesS			= ''@freightmiles@'',
			@FreightPrice	= LOWER(''@freightprice@''),
			@UnitS			= ''@freightunit@'',
			
			@CusLocId 		= NULL,
			@ItemCatId		= NULL,
			@FreightOnlyB	= 0,
			@ShipViaId		= NULL,
			@Amount			= 0,
			@Rate			= 0,
			@Miles			= 0,
			@FreightPriceB	= 0,
			@Unit			= 0,
			@EntityId		= NULL

	


	SELECT @EntityId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Customer'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @EntityNo


	IF ISNULL(@EntityId, 0) > 0 AND @CusLoc <> ''''
	BEGIN
		SELECT @CusLocId = intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @EntityId AND strLocationName = @CusLoc
		IF ISNULL(@CusLocId,0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Customer Location does not exists''
			SET @IsValid = 0
		END
	END

	IF @ShipVia <> '''' 
	BEGIN
		SELECT @ShipViaId = A.intEntityId
		from 
			tblSMShipVia A
				JOIN tblEMEntity B
					on A.[intEntityId] = B.intEntityId
		WHERE A.strShipVia = @ShipVia

		IF ISNULL(@ShipViaId, 0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Ship Via does not exists.''
			SET @IsValid = 0
		END			

	END
		
	IF @AmountS <> ''''
	BEGIN
		IF ISNUMERIC(@AmountS) = 1
			SELECT @Amount = CAST(@AmountS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Amount is invalid.''
			SET @IsValid = 0
		END

	END
	
	IF @RateS <> ''''
	BEGIN
		IF ISNUMERIC(@RateS) = 1
			SELECT @Rate = CAST(@RateS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Rate is invalid.''
			SET @IsValid = 0
		END

	END
	
	IF @MilesS <> ''''
	BEGIN
		IF ISNUMERIC(@MilesS) = 1
			SELECT @Miles = CAST(@MilesS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Miles is invalid.''
			SET @IsValid = 0
		END

	END
	
	IF @UnitS <> ''''
	BEGIN
		IF ISNUMERIC(@UnitS) = 1
			SELECT @Unit = CAST(@UnitS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Unit is invalid.''
			SET @IsValid = 0
		END

	END


	

	IF @FreightOnly = ''1'' OR @FreightOnly = ''yes'' OR @FreightOnly = ''true''
	BEGIN
		SET @FreightOnlyB = 1
	END

	IF @FreightPrice = ''1'' OR @FreightPrice = ''yes'' OR @FreightPrice = ''true''
	BEGIN
		SET @FreightPriceB = 1
	END
	


	select		
		@ItemCatId = CASE WHEN @ItemCat <> '''' THEN CAT.intCategoryId ELSE NULL END
		from tblICCategory CAT
	WHERE
		( (@ItemCat <> '''' ) and @ItemCat = CAT.strCategoryCode)

	IF (ISNULL(@ItemCatId, 0)) <= 0 AND @ItemCat <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Category does not exists''
		SET @IsValid = 0
	END


	IF ISNULL(@EntityId, 0) > 0
	BEGIN

		IF (@IsValid = 1)
		BEGIN
			IF LOWER(@FreightType) = ''amount''
			BEGIN
				SELECT @ShipViaId = NULL, 	
						@Rate = 0,			@Miles = 0,
						@Unit = 0
			END
			ELSE IF LOWER(@FreightType) = ''miles''
			BEGIN
				SELECT @Amount = 0,
						@Rate = 0,			
						@Unit = 0

			END
			ELSE IF LOWER(@FreightType) = ''rate''
			BEGIN
				SELECT @ShipViaId = NULL, 	@Amount = 0,
						@Miles = 0
			END
			ELSE
			BEGIN
				SELECT @ShipViaId = NULL, 	@Amount = 0,
						@Rate = 0,			@Miles = 0,
						@Unit = 0
			END
			BEGIN TRY
				INSERT INTO tblARCustomerFreightXRef(
					intEntityCustomerId,		intCategoryId,
					ysnFreightOnly,				strFreightType,
					dblFreightAmount,			dblFreightRate,
					dblMinimumUnits,			ysnFreightInPrice,
					dblFreightMiles,			intShipViaId,
					intEntityLocationId,		strZipCode,
					intConcurrencyId	
				)
				SELECT
					@EntityId,					@ItemCatId,
					@FreightOnlyB,				@FreightType,
					@Amount,					@Rate,
					@Unit,						@FreightPriceB,
					@Miles,						@ShipViaId,
					@CusLocId,					@ZipCode,
					0
			END TRY
			BEGIN CATCH
				DECLARE @Err NVARCHAR(MAX)
				SET @Err = Error_Message()
				SELECT @Err
				IF CHARINDEX(''uk_tblarcustomerfreightxref_reference_columns'', LOWER(@Err)) > 0
				BEGIN
					SET @ValidationMessage = ''Duplicate combination of (Location, Zip Code & Category) entry for Customer (@entityCustomerId@).''
				END
				ELSE
				BEGIN
					SET @ValidationMessage = ''Customer (@entityCustomerId@) does not exists.''
				END

				
			END CATCH
				
		END

	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Customer (@entityCustomerId@) does not exists.''
	END

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	UNION All
	SELECT @NewHeaderId, 'cusloc', 'Customer Location*', 1
	Union All
	SELECT @NewHeaderId, 'zipcode', 'Supplier Zip Code', 0
	Union All
	SELECT @NewHeaderId, 'itemcat', 'Category', 0
	Union All
	SELECT @NewHeaderId, 'freightonly', 'Freight Only', 0
	Union All
	SELECT @NewHeaderId, 'freighttype', 'Freight Type', 0
	Union All
	SELECT @NewHeaderId, 'freightshipvia', 'Fixed Ship Via', 0
	Union All
	SELECT @NewHeaderId, 'freightamount', 'Freight Amount', 0
	Union All
	SELECT @NewHeaderId, 'freightrate', 'Freight Rate', 0
	Union All
	SELECT @NewHeaderId, 'freightmiles', 'Freight Miles', 0
	Union All
	SELECT @NewHeaderId, 'freightprice', 'Freight in Price', 0
	Union All
	SELECT @NewHeaderId, 'freightunit', 'Minimum Units', 0

--Transport Freight Tab End







PRINT '---------- END DYNAMIC CSV DEFAULT DATA ----------'


SET IDENTITY_INSERT tblSMCSVDynamicImport  OFF

GO
SET NOCOUNT OFF


/*
--Test Data for Customer Special Taxing Import
Customer Entity No*,Tax Group*,Customer Location,Vendor No,Item Category,Item No
[failed ] 1005252,1241,124,124,124,124
[failed ] 1005252,1241,Fort Wayne,124,124,124
[failed ] 1005252,OR-Reedsport,Fort Wayne,124,124,124
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS,1234
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,4213,87G
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS12,
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,,1287G
[success] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS,
[success] 1005252,OR-Reedsport,Fort Wayne,1005532,,87G
[success] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS,87G


*/

/*
--TEST DATA Customer Master License Import

Customer Entity No*,License Code*,Begin Date,End Date,Comment,Active
[success] 1005252,Haz mat,1/1/2017,,Success,1
[success] 1005252,Haz mat,1/1/2017,3/1/2017,Success,0
[success] 1005252,Haz mat,,,,1
[failed ] 1005252,Haz mate,,,,1
[failed ] 05252,Haz mate,,,,1
[failed ] 1005252,Haz mat,9/1/2017,3/1/2017,Success,0
[failed ] 1005252,Haz mat,9/1/2017,3/1/2017,Success,1

*/