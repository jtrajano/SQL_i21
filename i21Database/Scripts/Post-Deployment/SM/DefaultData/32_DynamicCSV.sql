
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
	declare @freightterm							nvarchar(100)


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
	declare @detailcustomerno						nvarchar(100)
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
	
	declare @genfederaltaxid						nvarchar(50)
	declare @genstatetaxid							nvarchar(50)
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
		@detailcustomerno = ''@detailcustomerno@'',
		@detailtype = ''@detailtype@'',													@detailaccountno = ''@detailaccountno@'',
		@detailcurrency = ''@detailcurrency@'',											@detailpaymentmethod = ''@detailpaymentmethod@'',
		@detailterms = ''@detailterms@'',													@detailshipvia = ''@detailshipvia@'',
		@detailsalesperson = ''@detailsalesperson@'',										@detailwarehouse = ''@detailwarehouse@'',
		@detailstatus = ''@detailstatus@'',											@detailfloid = ''@detailfloid@'',
		@detailpricing = ''@detailpricing@'',												@detailtaxno = ''@detailtaxno@'',
		@detailexemptalltax = ''@detailexemptalltax@'',									@detailtaxcounty = ''@detailtaxcounty@'',
		@detailvatnumber = ''@detailvatnumber@'',											@detailemployeecount = ''@detailemployeecount@'',
		@detailrevenue = ''@detailrevenue@'',												@detailcurrentsystem = ''@detailcurrentsystem@'',

		@misccreditlimit = ''@misccreditlimit@'',
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
		@genstatetaxid = ''@genstatetaxid@'', @genfederaltaxid = ''@genfederaltaxid@'', @freightterm = ''@freightterm@'',


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
		declare @freighttermid						int

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
			if isdate(@originationdate) = 1
				select @originationdated = cast(@originationdate as datetime)
			else
				set @originationdated = GETDATE()		
		end
		else
			set @originationdated = GETDATE()

		if @detailcustomerno <> '''' and exists(select top 1 1 from tblARCustomer where strCustomerNumber = @detailcustomerno)
		begin
			
			set @ValidationMessage = @ValidationMessage + '', Customer Number (''+  @detailcustomerno +'') already exists.''
		end

		if @detailcustomerno = ''''
		begin
			set @detailcustomerno = @entityno
		end

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
			if(isdate(@miscbudgetbegindate) = 1)
				select @miscbudgetbegindated = cast(@miscbudgetbegindate as datetime)
			else
			begin
				SET @ValidationMessage	= @ValidationMessage + '',Budget Begin Date('' + @miscbudgetbegindate + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end
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
			if isdate(@misclastservicecharge) = 1
				select @misclastservicecharged = cast(@misclastservicecharge as datetime)	
			else
			begin
				SET @ValidationMessage	= @ValidationMessage + '',Last Service Charge Date('' + @misclastservicecharge + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end
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
			if isdate(@grainlastdpissuedate) = 1
				select @grainlastdpissuedated = cast(@grainlastdpissuedate as datetime)
			else
			begin
				SET @ValidationMessage	= @ValidationMessage + '',Last DP Issue Date('' + @grainlastdpissuedate + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end			
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
			if isdate(@patronagemembershipdate) = 1
				select @patronagemembershipdated = cast(@patronagemembershipdate as datetime)			
			else
			begin
				SET @ValidationMessage	= @ValidationMessage + '',Membership Date('' + @patronagemembershipdate + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end
		end	

		if @patronagebirthdate <> '''' 
		begin
			if isdate(@patronagebirthdate) = 1
				select @patronagebirthdated = cast(@patronagebirthdate as datetime)
			else
			begin
				SET @ValidationMessage	= @ValidationMessage + '',Birth Date('' + @patronagebirthdate + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end		
		end			 
				
		if @patronagestockstatus <> '''' and @patronagestockstatus not in (''Voting'', ''Non-Voting'', ''Producer'', ''Other'')               
		begin
			set @ValidationMessage = @ValidationMessage + '', Stock Status (''+  @patronagestockstatus +'') does not exists. Use one in (Voting, Non-Voting, Producer, Other).''
			set @IsValid = 0
		end	

		if @patronagedeceaseddate <> '''' 
		begin
			if isdate(@patronagedeceaseddate) = 1
				select @patronagedeceaseddated = cast(@patronagedeceaseddate as datetime)
			else
			begin
				SET @ValidationMessage	= @ValidationMessage + '',Deceased Date('' + @patronagedeceaseddate + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end			
		end	

		if @patronagelastactivitydate <> '''' 
		begin
			if isdate(@patronagelastactivitydate) = 1
				select @patronagelastactivitydated = cast(@patronagelastactivitydate as datetime)
			else
			begin
				SET @ValidationMessage	= @ValidationMessage + '',Last Activity Date('' + @patronagelastactivitydate + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
				SET @IsValid = 0
			end
		end	
		
		if @freightterm <> ''''
		begin
			select @freighttermid = intFreightTermId from tblSMFreightTerms where strFreightTerm = @freightterm

			if isnull(@freighttermid, 0) <= 0
			begin
				set @ValidationMessage = @ValidationMessage + '', Freight Term (''+  @freightterm +'') does not exists.''
				set @IsValid = 0
			end
		end


		if isnull(@printedname, '''') = ''''
		BEGIN
			SET @printedname = @name
		END

		if @IsValid = 1 
		begin

			insert into tblEMEntity(strEntityNo, strName, strContactNumber, dtmOriginationDate, strDocumentDelivery, strExternalERPId, strFederalTaxId, strStateTaxId)
			select @entityno, @name, '''', @originationdated, @documentdelivery, @externalerpid, @genfederaltaxid, @genstatetaxid

			set @entityId = @@IDENTITY

			insert into tblEMEntity(strName, strContactNumber, strSuffix, strEmail, intLanguageId, strInternalNotes)
			select @contactname, '''', @suffix, @email, @languageId, @internalnotes

			set @contactId = @@IDENTITY

			insert into tblEMEntityLocation(intEntityId, strLocationName, strCheckPayeeName, strAddress, strCity, strState, strZipCode, strCountry, strTimezone, intDefaultCurrencyId, intTermsId, intShipViaId, ysnDefaultLocation, intFreightTermId)
			select @entityId, @locationname, @printedname, @address, @city, @state, @zip, @country, @timezone, @defaultCurId, @detailTermsId, @detailShipViaId, 1, @freighttermid

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
				



				dblARBalance,
				strCustomerNumber
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





				0,
				@detailcustomerno
				





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
	SELECT @NewHeaderId, 'freightterm', 'Freight Term*', 1
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
	Union All
	SELECT @NewHeaderId, 'detailcustomerno', 'Detail Customer Number', 0
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
	SELECT @NewHeaderId, 'detailstatus', 'Detail Status', 0
	Union All
	SELECT @NewHeaderId, 'detailwarehouse', 'Detail Warehouse', 0
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
	--General Tab
	Union All
	SELECT @NewHeaderId, 'genfederaltaxid', 'GEN FEDTAX ID', 0
	Union All
	SELECT @NewHeaderId, 'genstatetaxid', 'GEN STATE TAX ID', 0

	--General Tab


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
		if isdate(@BeginDateS) = 1
			SELECT @BeginDate = CAST(@BeginDateS AS DATETIME)
		else
		begin
			SET @ValidationMessage	= @ValidationMessage + '',Begin Date('' + @BeginDateS + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
			SET @IsValid = 0
		end
	END

	IF @EndDateS <> '''' 
	BEGIN		
		if isdate(@EndDateS) = 1
			SELECT @EndDate = CAST(@EndDateS AS DATETIME)				
		else
		begin
			SET @ValidationMessage	= @ValidationMessage + '',End Date('' + @EndDateS + '') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
			SET @IsValid = 0
		end
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

--Customer Location Import Begin
SET @NewHeaderId = 6

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Location Import','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Location Import',
	strCommand = '
		DECLARE @entity_no					NVARCHAR (MAX) 		
		DECLARE @location_name				NVARCHAR (200) 
		DECLARE @address					NVARCHAR (MAX) 			
		DECLARE @city						NVARCHAR (MAX) 
		DECLARE @country					NVARCHAR (MAX) 			

		DECLARE @county						NVARCHAR (MAX) 
		DECLARE @state						NVARCHAR (MAX) 		
		DECLARE @zipcode					NVARCHAR (MAX) 
		DECLARE @phone						NVARCHAR (MAX) 
		DECLARE @fax						NVARCHAR (MAX) 

		DECLARE @pricing_level				NVARCHAR (MAX) 
		DECLARE @notes						NVARCHAR (MAX) 
		DECLARE @oregon_faclity_number		NVARCHAR (MAX) 
		DECLARE @shipvia					NVARCHAR (MAX)	
		DECLARE @terms						NVARCHAR (MAX)
													
		DECLARE @warehouse					NVARCHAR (MAX)
		DECLARE @default_location			NVARCHAR (MAX)		
		DECLARE @freight_term				NVARCHAR (MAX)	
		DECLARE @country_tax_code			NVARCHAR (MAX)	
		DECLARE @tax_group					NVARCHAR (MAX)	 
				
		DECLARE @tax_class					NVARCHAR (MAX)						
		DECLARE @active						NVARCHAR (MAX)		
		DECLARE @longtitude					NVARCHAR (MAX) 			
		DECLARE @latitude					NVARCHAR (MAX) 
		DECLARE @timezone					NVARCHAR (MAX) 

		DECLARE @check_payee_name			NVARCHAR (MAX) 
		DECLARE @default_currency			NVARCHAR (MAX) 
		DECLARE @vendor_link				NVARCHAR (MAX) 
		DECLARE @location_description		NVARCHAR (MAX) 
		DECLARE @location_type				NVARCHAR (MAX) 
			
		DECLARE @farm_field_number			NVARCHAR (MAX) 
		DECLARE @farm_field_description		NVARCHAR (MAX) 
		DECLARE @farm_fsa_number			NVARCHAR (MAX) 
		DECLARE @farm_split_number			NVARCHAR (MAX) 
		DECLARE @farm_split_type			NVARCHAR (MAX) 
			
		DECLARE @farm_acres					NVARCHAR (MAX)  
		DECLARE @img_field_map_file			VARBINARY (MAX)
		DECLARE @field_map_file				NVARCHAR (MAX) 
		DECLARE @print_1099					NVARCHAR (MAX)       
		DECLARE @1099_name					NVARCHAR (MAX)   
			
		DECLARE @1099_form					NVARCHAR (MAX)   			
		DECLARE @1099_type					NVARCHAR (MAX)   
		DECLARE @federal_tax				NVARCHAR (MAX)   
		DECLARE @w9signed					NVARCHAR (MAX)  



		SELECT 
			@entity_no						= ''@entity_no@'',		
			@location_name					= ''@location_name@'',
			@address						= ''@address@'',				
			@city							= ''@city@'',
			@country						= ''@country@'',
											
			@county							= ''@county@'',
			@state							= ''@state@'',
			@zipcode						= ''@zipcode@'',
			@phone							= ''@phone@'',
			@fax							= ''@fax@'',
											
			@pricing_level					= ''@pricing_level@'',
			@notes							= ''@notes@'',
			@oregon_faclity_number			= ''@oregon_faclity_number@'',
			@shipvia						= ''@shipvia@'',
			@terms							= ''@terms@'',
									
			@warehouse						= ''@warehouse@'',
			@default_location				=	0,
			@freight_term					= ''@freight_term@'',
			@country_tax_code				= ''@country_tax_code@'',
			@tax_group						= ''@tax_group@'',
									
			@tax_class						= ''@tax_class@'',
			@active							= ''@active@'',
			@longtitude						= ''@longtitude@'',
			@latitude						= ''@latitude@'',
			@timezone						= ''@timezone@'',
					
										
			@check_payee_name				= ''@check_payee_name@'',
			@default_currency				= ''@default_currency@'',
			@vendor_link					= ''@vendor_link@'',
			@location_description			= ''@location_description@'',
			@location_type					= '''',
									
			@farm_field_number				= ''@farm_field_number@'',
			@farm_field_description			= ''@farm_field_description@'',
			@farm_fsa_number				= ''@farm_fsa_number@'',
			@farm_split_number				= ''@farm_split_number@'',
			@farm_split_type				= ''@farm_split_type@'',
											
			@farm_acres						= ''@farm_acres@'',
			@img_field_map_file				=	NULL,
			@field_map_file					= '''',
			@print_1099						= ''@print_1099@'',
			@1099_name						= ''@1099_name@'',
											
			@1099_form						= ''@1099_form@'',
			@1099_type						= ''@1099_type@'',
			@federal_tax					= ''@federal_tax@'',
			@w9signed						= ''@w9signed@''
			

			
			DECLARE @entityId INT
			DECLARE @termsId INT
			DECLARE @shipviaId INT
			DECLARE @warehouseId INT
			DECLARE @defaultlocationId INT
			DECLARE @freighttermId INT
			DECLARE @countrytaxcodeId INT
			DECLARE @taxgroupId INT
			DECLARE @taxclassId INT
			DECLARE @isactive BIT
			DECLARE @longtitudeNo NUMERIC(18,6)
			DECLARE @latitudeNo NUMERIC(18,6)
			DECLARE @defaultcurrencyId INT
			DECLARE @vendorlinkId INT
			DECLARE @farmacresNo NUMERIC(18,6)
			DECLARE @isprint1099 BIT
			DECLARE @w9signedTime DATETIME

			


			DECLARE @IsValid INT = 1

			SELECT @IsValid = 1,
				@ValidationMessage	= ''''



			
			IF NOT EXISTS(Select TOP 1 1 from tblARCustomer Where strCustomerNumber = @entity_no)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''Customer No :''+@entity_no+'' is not Exist''
			END
			ELSE
			BEGIN
				SELECT  TOP 1  @entityId = intEntityId from tblARCustomer Where strCustomerNumber = @entity_no
			END
			


			
			
			IF(@terms = '''') 
			BEGIN
				SET @termsId = NULL	
			END
			ELSE IF NOT EXISTS(Select TOP 1 1 from tblSMTerm Where strTerm = @terms)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''Terms :''+@terms+'' is not Exist''
			END
			ELSE
			BEGIN
				Select TOP 1 @termsId = intTermID from tblSMTerm Where strTerm = @terms
			END
			

			IF(@shipvia = '''') 
			BEGIN
				SET @shipviaId = NULL	
			END
			ELSE IF NOT EXISTS(Select TOP 1 1 from tblSMShipVia Where strShipVia = @shipvia)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''Shipvia :''+@shipvia+'' is not Exist''
			END
			ELSE
			BEGIN
				Select TOP 1 @shipviaId = intEntityId from tblSMShipVia Where strShipVia = @shipvia
			END
			
			IF(@warehouse = '''')
			BEGIN
				SET @warehouseId = NULL
			END
			ELSE
			BEGIN
				IF(TRY_PARSE(@shipvia AS INT) IS NULL )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''Ship Via should be numeric''
				END
				ELSE 
				BEGIN
					SET @warehouseId = CONVERT(INT,@warehouse)
				END
			END


			IF(@default_location = '''')
			BEGIN
				SET @defaultlocationId = NULL
			END
			ELSE
			BEGIN
				SET @defaultlocationId = CONVERT(BIT,@default_location)
			END

			IF(@freight_term = '''')
			BEGIN
				SET @freighttermId = NULL
			END
			ELSE IF NOT EXISTS(Select TOP 1 1 from tblSMFreightTerms Where strFreightTerm = @freight_term )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''Freight Term Id :''+@freighttermId+'' is not Exist''
			END
			ELSE
			BEGIN
				Select TOP 1 @freighttermId = intFreightTermId from tblSMFreightTerms Where strFreightTerm = @freight_term
			END


			IF(@tax_group = '''')
			BEGIN
				SET @taxgroupId = NULL
			END
			ELSE IF NOT EXISTS(Select TOP 1 1 from tblSMTaxGroup Where strTaxGroup = @tax_group  )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''Tax Group:''+@tax_group+'' is not Exist''
			END
			BEGIN
				Select TOP 1 @taxgroupId = intTaxGroupId from tblSMTaxGroup Where strTaxGroup = @tax_group 
			END
			

			IF(@tax_class = '''')
			BEGIN
				SET @taxclassId = NULL
			END
			ELSE IF NOT EXISTS(Select TOP 1 1 from tblSMTaxClass Where strTaxClass = @tax_class )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''Tax Class Id :''+@tax_class+'' is not Exist''
			END
			ELSE
			BEGIN
				Select TOP 1 @taxclassId = intTaxClassId from tblSMTaxClass Where strTaxClass = @tax_class
			END
		

			IF(@active = ''Yes'' OR @active = ''No'')
			BEGIN
				SET @isactive = CONVERT(BIT,1)
			END
			ELSE
			BEGIN
				SET @isactive = CONVERT(BIT,0)
			END



			
			IF(TRY_PARSE(@longtitude AS NUMERIC(18,6)) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''longtitude should be numeric''
			END
			ELSE 
			BEGIN
				SET @longtitudeNo = CAST(@longtitude AS NUMERIC(18,6))
			END
		
			
			IF(TRY_PARSE(@latitude AS NUMERIC(18,6)) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''latitude should be numeric''
			END
			ELSE 
			BEGIN
				SET @latitudeNo = CAST(@latitude AS NUMERIC(18,6))
			END
		

			IF(@default_currency = '''')
			BEGIN
				SET @defaultcurrencyId = NULL
			END
			ELSE
			BEGIN
					IF NOT EXISTS(Select TOP 1 1 from tblSMCurrency Where strCurrency = @default_currency )
					BEGIN
						SET @IsValid = 0
						SET @ValidationMessage = @ValidationMessage + '' ''+''Default Currency :''+@default_currency+'' is not Exist''
					END
					ELSE
					BEGIN
						Select TOP 1 defaultcurrencyId = intCurrencyID from tblSMCurrency Where strCurrency = @default_currency
					END
			END

			IF(@vendor_link = '''')
			BEGIN
				SET @vendorlinkId = NULL
			END
			ELSE
			BEGIN
				SET @vendorlinkId = CONVERT(INT,@vendor_link)
			END

			IF(@farm_acres = '''')
			BEGIN
				SET @farmacresNo = 0
			END
			ELSE
			BEGIN
				SET @farmacresNo = CAST(ISNULL(NULLIF(@farm_acres,''''),''0'') AS NUMERIC(18,6))
			END

			IF(@print_1099 = '''')
			BEGIN
				SET @isprint1099 = NULL
			END
			ELSE
			BEGIN
				SET @isprint1099 = CONVERT(BIT,@print_1099)
			END

			IF(@w9signed = '''')
			BEGIN
				SET @w9signedTime = NULL
			END
			ELSE
			BEGIN
				SET @w9signedTime = CONVERT(DATETIME,@w9signed)
			END


			IF @IsValid = 1
			BEGIN
		
			INSERT INTO tblEMEntityLocation(
				[intEntityId],
				[strLocationName],
				[strAddress],
				[strCity],
				[strCountry],

				[strCounty],
				[strState],
				[strZipCode],
				[strPhone],
				[strFax],

				[strPricingLevel],
				[strNotes],
				[strOregonFacilityNumber],
				[intShipViaId],
				[intTermsId],

				[intWarehouseId],
				[ysnDefaultLocation],
				[intFreightTermId],
				[intCountyTaxCodeId],
				[intTaxGroupId],

				[intTaxClassId],
				[ysnActive],
				[dblLongitude],
				[dblLatitude],	
				[strTimezone],

				[strCheckPayeeName],
				[intDefaultCurrencyId],
				[intVendorLinkId],
				[strLocationDescription],
				[strLocationType],
				
				[strFarmFieldNumber],
				[strFarmFieldDescription],
				[strFarmFSANumber],
				[strFarmSplitNumber],    
				[strFarmSplitType],

				[dblFarmAcres],
				[imgFieldMapFile], 
				[strFieldMapFile], 
				[ysnPrint1099],
				[str1099Name],

				[str1099Form],
				[str1099Type],
				[strFederalTaxId],
				[dtmW9Signed]
			)
			SELECT
				@entityId,		
				@location_name,
				@address,				
				@city, 
				@country,				

				@county,
				@state,					
				@zipcode,
				@phone,					
				@fax,

				@pricing_level,			
				@notes,
				@oregon_faclity_number,
				@shipviaId,				
				@termsId,
				
				@warehouseId,
				@defaultlocationId,
				@freighttermId,
				@countrytaxcodeId,		
				@taxgroupId,

				@tax_class,				
				@isactive,
				@longtitudeNo,
				@latitudeNo,
				@timezone,	
				
				@check_payee_name,
				@defaultcurrencyId,
				@vendorlinkId,
				@location_description,	
				@location_type,	
				
				@farm_field_number,
				@farm_field_description,
				@farm_fsa_number,		
				@farm_split_number,
				@farm_split_type,	
					
				@farmacresNo,
				@img_field_map_file,
				@field_map_file,
				@isprint1099,
				@1099_name,

				@1099_form,				
				@1099_type,
				@federal_tax,			
				@w9signedTime
			END
		
	'
	WHERE intCSVDynamicImportId = @NewHeaderId



INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	
	
	SELECT @NewHeaderId, 'entity_no', 'entity_no', 1
	UNION All
	SELECT @NewHeaderId, 'location_name', 'location_name', 1
	Union All
	SELECT @NewHeaderId, 'address', 'address', 0
	Union All
	SELECT @NewHeaderId, 'city', 'city', 0
	Union All
	SELECT @NewHeaderId, 'country', 'country', 0

	Union All
	SELECT @NewHeaderId, 'county', 'county', 0
	Union All
	SELECT @NewHeaderId, 'state', 'state', 0
	Union All
	SELECT @NewHeaderId, 'zipcode', 'zipcode', 0
	Union All
	SELECT @NewHeaderId, 'phone', 'phone', 0
	Union All
	SELECT @NewHeaderId, 'fax', 'fax', 0


		
	Union All
	SELECT @NewHeaderId, 'pricing_level', 'pricing_level', 0
	Union All
	SELECT @NewHeaderId, 'notes', 'notes', 0
	Union All
	SELECT @NewHeaderId, 'oregon_faclity_number', 'oregon_faclity_number', 0
	Union All
	SELECT @NewHeaderId, 'shipvia', 'shipvia', 0
	Union All
	SELECT @NewHeaderId, 'terms', 'terms', 0

	Union All
	SELECT @NewHeaderId, 'warehouse', 'warehouse', 0
	Union All
	SELECT @NewHeaderId, 'freight_term', 'freight_term', 0
	Union All
	SELECT @NewHeaderId, 'country_tax_code', 'country_tax_code', 0
	Union All
	SELECT @NewHeaderId, 'tax_group', 'tax_group', 0

	Union All
	SELECT @NewHeaderId, 'tax_class', 'tax_class', 0
	Union All
	SELECT @NewHeaderId, 'active', 'active', 0
	Union All
	SELECT @NewHeaderId, 'longtitude', 'longtitude', 1
	Union All
	SELECT @NewHeaderId, 'latitude', 'latitude', 1
	Union All
	SELECT @NewHeaderId, 'timezone', 'timezone', 0

	Union All
	SELECT @NewHeaderId, 'check_payee_name', 'check_payee_name', 0
	Union All
	SELECT @NewHeaderId, 'default_currency', 'default_currency', 0
	Union All
	SELECT @NewHeaderId, 'vendor_link', 'vendor_link', 0
	Union All
	SELECT @NewHeaderId, 'location_description', 'location_description', 0

	Union All
	SELECT @NewHeaderId, 'farm_field_number', 'farm_field_number', 0
	Union All
	SELECT @NewHeaderId, 'farm_field_description', 'farm_field_description', 0
	Union All
	SELECT @NewHeaderId, 'farm_fsa_number', 'farm_fsa_number', 0
	Union All
	SELECT @NewHeaderId, 'farm_split_number', 'farm_split_number', 0
	Union All
	SELECT @NewHeaderId, 'farm_split_type', 'farm_split_type', 0

	Union All
	SELECT @NewHeaderId, 'farm_acres', 'farm_acres', 0
	Union All
	SELECT @NewHeaderId, 'print_1099', 'print_1099', 0
	Union All
	SELECT @NewHeaderId, '1099_name', '1099_name', 0

	Union All
	SELECT @NewHeaderId, '1099_form', '1099_form', 0
	Union All
	SELECT @NewHeaderId, '1099_type', '1099_type', 0
	Union All
	SELECT @NewHeaderId, 'federal_tax', 'federal_tax', 0
	Union All
	SELECT @NewHeaderId, 'w9signed', 'w9signed', 0




--Customer Location Import End


--Customer Special Pricing Import Begin
SET @NewHeaderId = 7

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Special Pricing Import','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Special Pricing Import',
	strCommand = '

		DECLARE	@id								NVARCHAR(MAX)
		DECLARE	@customer_id					NVARCHAR(MAX)
		DECLARE	@customer_location				NVARCHAR(MAX)
		DECLARE	@price_basis					NVARCHAR(MAX)
		DECLARE	@cost_to_use					NVARCHAR(MAX)
		DECLARE	@origin_vendor_no				NVARCHAR(MAX)
		DECLARE	@origin_vendor_location			NVARCHAR(MAX)
		DECLARE	@item_no						NVARCHAR(MAX)
		DECLARE	@item_category					NVARCHAR(MAX)
		DECLARE	@customer_group					NVARCHAR(MAX)
		DECLARE	@deviation						NVARCHAR(MAX)
		DECLARE	@line_note						NVARCHAR(MAX)
		DECLARE	@begin_date						NVARCHAR(MAX)
		DECLARE	@end_date						NVARCHAR(MAX)
		DECLARE	@fixed_rack_vendor_no			NVARCHAR(MAX)
		DECLARE	@fixed_rack_no					NVARCHAR(MAX)
		DECLARE	@fixed_rack_vendor_location		NVARCHAR(MAX)
		DECLARE	@source							NVARCHAR(MAX)


		SELECT 
			@id								= ''@id@'',
			@customer_id					= ''@customer_id@'',
			@customer_location				= ''@customer_location@'',
			@price_basis					= ''@price_basis@'',
			@cost_to_use					= ''@cost_to_use@'',
			@origin_vendor_no				= ''@origin_vendor_no@'',
			@origin_vendor_location			= ''@origin_vendor_location@'',
			@item_no						= ''@item_no@'',
			@item_category					= ''@item_category@'',
			@customer_group					= ''@customer_group@'',
			@deviation						= ''@deviation@'',
			@line_note						= ''@line_note@'',
			@begin_date						= ''@begin_date@'',
			@end_date						= ''@end_date@'',
			@fixed_rack_vendor_no			= ''@fixed_rack_vendor_no@'',
			@fixed_rack_no					= ''@fixed_rack_no@'',
			@fixed_rack_vendor_location		= ''@fixed_rack_vendor_location@'',
			@source							= ''@source@''


		DECLARE @intSpecialPriceId			INT
		DECLARE @intEntityCustomerId		INT
		DECLARE @intCustomerLocationId		INT
		DECLARE @strPriceBasis				NVARCHAR(MAX)
		DECLARE @strCostToUse				NVARCHAR(MAX)
		DECLARE @intEntityVendorId			INT
		DECLARE @intEntityLocationId		INT
		DECLARE @intItemId					INT
		DECLARE @intCategoryId				INT
		DECLARE @strCustomerGroup			NVARCHAR(MAX)	
		DECLARE @dblDeviation				NUMERIC(18,6)
		DECLARE @strLineNote				NVARCHAR(MAX)
		DECLARE @dtmBeginDate				DATETIME
		DECLARE @dtmEndDate					DATETIME
		DECLARE @intRackVendorId			INT
		DECLARE @intRackItemId				INT
		DECLARE @intRackLocationId			INT
		DECLARE @strInvoiceType				NVARCHAR(MAX)


		DECLARE @IsValid INT = 1

		SELECT @IsValid = 1,
			@ValidationMessage	= ''''



		IF(TRY_PARSE(@id AS INT) IS NULL)
		BEGIN
			SET @IsValid = 0
			SET @ValidationMessage = @ValidationMessage + '' ''+''id No should be numeric''
		END
		ELSE 
		BEGIN
			SET @intSpecialPriceId = CONVERT(INT,@id)
		END

		
		IF(@customer_id = '''')
		BEGIN
			SET @intEntityCustomerId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@customer_id AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''customer_id should be numeric''
			END
			ELSE 
			BEGIN
				SET @intEntityCustomerId = CONVERT(INT,@customer_id)
				IF NOT EXISTS(Select TOP 1 1 from tblARCustomer Where intEntityId = @intEntityCustomerId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''intEntityCustomerId :''+CAST(@intEntityCustomerId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@customer_location = '''')
		BEGIN
			SET @intCustomerLocationId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@customer_location AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''customer_location should be numeric''
			END
			ELSE 
			BEGIN
				SET @intCustomerLocationId = CONVERT(INT,@customer_location)
				IF NOT EXISTS(Select TOP 1 1 from tblSMCompanyLocation Where intCompanyLocationId = @intCustomerLocationId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''customer_location id :''+CAST(@intCustomerLocationId AS NVARCHAR(100) ) +'' is not Exist''
				END
			END
		END

		IF(@origin_vendor_no = '''')
		BEGIN
			SET @intEntityVendorId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@origin_vendor_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''origin_vendor_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intEntityVendorId = CONVERT(INT,@origin_vendor_no)
				IF NOT EXISTS(Select TOP 1 1 from tblAPVendor Where intEntityId = @intEntityVendorId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''origin_vendor_no  :''+CAST(@intEntityVendorId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@origin_vendor_location = '''')
		BEGIN
			SET @intEntityLocationId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@origin_vendor_location AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''origin_vendor_location should be numeric''
			END
			ELSE 
			BEGIN
				SET @intEntityLocationId = CONVERT(INT,@origin_vendor_location)
				IF NOT EXISTS(Select TOP 1 1 from tblSMCompanyLocation Where intCompanyLocationId = @intEntityLocationId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''origin_vendor_location  :''+CAST(@intEntityLocationId AS NVARCHAR(100) )+'' is not Exist''
				END
			END
		END

		IF(@item_no = '''')
		BEGIN
			SET @intItemId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@item_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''item_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intItemId = CONVERT(INT,@item_no)
				IF NOT EXISTS(Select TOP 1 1 from tblICItem Where intItemId = @intItemId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''item_no  :''+CAST(@intItemId AS NVARCHAR(100) )+'' is not Exist''
				END
			END
		END

		IF(@item_category = '''')
		BEGIN
			SET @intCategoryId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@item_category AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''item_category should be numeric''
			END
			ELSE 
			BEGIN
				SET @intCategoryId = CONVERT(INT,@item_category)
				IF NOT EXISTS(Select TOP 1 1 from tblICCategory Where intCategoryId = @intCategoryId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''item_no  :''+CAST(@intCategoryId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@deviation = '''')
		BEGIN
			SET @dblDeviation = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@deviation AS NUMERIC(18,6)) IS NULL)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''deviation No should be numeric''
			END
			ELSE 
			BEGIN
				SET @dblDeviation = CAST(@deviation AS NUMERIC(18,6))
			END
		END


		IF(@begin_date = '''')
		BEGIN
			SET @IsValid = 0
			SET @ValidationMessage = @ValidationMessage + '' ''+''begin_date should not be Empty''
		
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@begin_date AS DATETIME) IS NULL)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''begin_date  should be a valid date format''
			END
			ELSE 
			BEGIN
				SET @dtmBeginDate = CAST(@begin_date AS DATETIME)
			END
		END

		IF(@end_date = '''')
		BEGIN
			SET @IsValid = 0
			SET @ValidationMessage = @ValidationMessage + '' ''+''end_date should not be Empty''
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@end_date AS DATETIME) IS NULL)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''end_date  should be a valid date format''
			END
			ELSE 
			BEGIN
				SET @dtmEndDate = CAST(@end_date AS DATETIME)
			END
		END

		IF(@fixed_rack_vendor_no = '''')
		BEGIN
			SET @intRackVendorId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@fixed_rack_vendor_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''fixed_rack_vendor_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intRackVendorId = CONVERT(INT,@fixed_rack_vendor_no)
				IF NOT EXISTS(Select TOP 1 1 from tblAPVendor Where intEntityId = @intRackVendorId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''fixed_rack_vendor_no :''+CAST(@intRackVendorId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@fixed_rack_no = '''')
		BEGIN
			SET @intRackItemId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@fixed_rack_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''fixed_rack_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intRackItemId = CONVERT(INT,@fixed_rack_no)
				IF NOT EXISTS(Select TOP 1 1 from tblICItem Where intItemId = @intRackItemId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''fixed_rack_no :''+CAST(@intRackItemId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@fixed_rack_vendor_location = '''')
		BEGIN
			SET @intRackLocationId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@fixed_rack_vendor_location AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''fixed_rack_vendor_location should be numeric''
			END
			ELSE 
			BEGIN
				SET @intRackLocationId = CONVERT(INT,@fixed_rack_vendor_location)
				IF NOT EXISTS(Select TOP 1 1 from tblSMCompanyLocation Where intCompanyLocationId = @intRackLocationId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''fixed_rack_vendor_location :''+CAST(@intRackLocationId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END


		IF @IsValid = 1
		BEGIN
		
			INSERT INTO tblARCustomerSpecialPrice(
				[intEntityCustomerId],
				[intCustomerLocationId],
				[strPriceBasis],
				[strCostToUse],
				[intEntityVendorId],
				[intEntityLocationId],
				[intItemId],
				[intCategoryId],
				[strCustomerGroup],
				[dblDeviation],
				[strLineNote],
				[dtmBeginDate],
				[dtmEndDate],
				[intRackVendorId],
				[intRackItemId]	,
				[intRackLocationId]	,
				[strInvoiceType],
				[intConcurrencyId]
			)
			SELECT
				@intEntityCustomerId,
				@intCustomerLocationId,
				@strPriceBasis,
				@strCostToUse,
				@intEntityVendorId,
				@intEntityLocationId,
				@intItemId,
				@intCategoryId,
				@strCustomerGroup,
				@dblDeviation,
				@strLineNote,
				@dtmBeginDate,
				@dtmEndDate,
				@intRackVendorId,
				@intRackItemId,
				@intRackLocationId,
				@strInvoiceType,
				0			
		END
		
	'
	WHERE intCSVDynamicImportId = @NewHeaderId



INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
						
	SELECT @NewHeaderId, 'id', 'id', 1
	UNION All
	SELECT @NewHeaderId, 'customer_id', 'customer_id', 1
	Union All
	SELECT @NewHeaderId, 'customer_location', 'customer_location', 0
	Union All
	SELECT @NewHeaderId, 'price_basis', 'price_basis', 0
	Union All
	SELECT @NewHeaderId, 'cost_to_use', 'cost_to_use', 0
	Union All
	SELECT @NewHeaderId, 'origin_vendor_no', 'origin_vendor_no', 0
	Union All
	SELECT @NewHeaderId, 'origin_vendor_location', 'origin_vendor_location', 0
	Union All
	SELECT @NewHeaderId, 'item_no', 'item_no', 0
	Union All
	SELECT @NewHeaderId, 'item_category', 'item_category', 0
	Union All
	SELECT @NewHeaderId, 'customer_group', 'customer_group', 0
	Union All
	SELECT @NewHeaderId, 'deviation', 'deviation', 0
	Union All
	SELECT @NewHeaderId, 'line_note', 'line_note', 0
	Union All
	SELECT @NewHeaderId, 'begin_date', 'begin_date', 0
	Union All
	SELECT @NewHeaderId, 'end_date', 'end_date', 0
	Union All
	SELECT @NewHeaderId, 'fixed_rack_vendor_no', 'fixed_rack_vendor_no', 0
	Union All
	SELECT @NewHeaderId, 'fixed_rack_no', 'fixed_rack_no', 0
	Union All
	SELECT @NewHeaderId, 'fixed_rack_vendor_location', 'fixed_rack_vendor_location', 0
	Union All
	SELECT @NewHeaderId, 'source', 'source', 0

--Customer Special Pricing Import End




--Customer Special Tax Exemption Import Begin
SET @NewHeaderId = 8

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Tax Exemption Import','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Tax Exemption Import',
	strCommand = '
		DECLARE @id						NVARCHAR(100)
		DECLARE @customer_id			NVARCHAR(100)
		DECLARE @customer_location		NVARCHAR(100)
		DECLARE @item_no				NVARCHAR(100)
		DECLARE @item_category			NVARCHAR(100)
		DECLARE @tax_code				NVARCHAR(100)
		DECLARE @tax_class				NVARCHAR(100)
		DECLARE @state					NVARCHAR(100)
		DECLARE @exemption_no			NVARCHAR(100)
		DECLARE @partial				NVARCHAR(100)
		DECLARE @start_date				NVARCHAR(100)
		DECLARE @end_date				NVARCHAR(100)
		DECLARE @card_no				NVARCHAR(100)
		DECLARE @vehicle_no				NVARCHAR(100)


		SELECT 
			@id							= ''@id@'',	
			@customer_id				= ''@customer_id@'',
			@customer_location			= ''@customer_location@'',
			@item_no					= ''@item_no@'',
			@item_category				= ''@item_category@'',
			@tax_code					= ''@tax_code@'',
			@tax_class					= ''@tax_class@'',
			@state						= ''@state@'',
			@exemption_no				= ''@exemption_no@'',
			@partial					= ''@partial@'',
			@start_date					= ''@start_date@'',
			@end_date					= ''@end_date@'',
			@card_no					= ''@card_no@'',
			@vehicle_no					= ''@vehicle_no@''

	
		DECLARE @intCustomerTaxingTaxExceptionId	INT 
        DECLARE @intEntityCustomerId				INT
		DECLARE @intItemId						    INT    
		DECLARE @intCategoryId						INT
		DECLARE @intTaxCodeId						INT
		DECLARE @intTaxClassId						INT
        DECLARE @strState							NVARCHAR(100)
        DECLARE @strException						NVARCHAR(100)
        DECLARE @dtmStartDate						DATETIME
        DECLARE @dtmEndDate							DATETIME
        DECLARE @intEntityCustomerLocationId		INT
        DECLARE @dblPartialTax						NUMERIC(18,6)
        DECLARE @intCardId							INT
        DECLARE @intVehicleId						INT


		DECLARE @IsValid INT = 1

		SELECT @IsValid = 1,
			@ValidationMessage	= ''''

		IF(@customer_id = '''')
		BEGIN
			SET @intEntityCustomerId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@customer_id AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''customer_id should be numeric''
			END
			ELSE 
			BEGIN
				SET @intEntityCustomerId = CONVERT(INT,@customer_id)
				IF NOT EXISTS(Select TOP 1 1 from tblARCustomer Where intEntityId = @intEntityCustomerId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''customer_id :''+CAST(@intEntityCustomerId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@customer_location = '''')
		BEGIN
			SET @intEntityCustomerLocationId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@customer_location AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''customer_location should be numeric''
			END
			ELSE 
			BEGIN
				SET @intEntityCustomerLocationId = CONVERT(INT,@customer_location)
				IF NOT EXISTS(Select TOP 1 1 from tblSMCompanyLocation Where intCompanyLocationId = @intEntityCustomerLocationId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''customer_location :''+CAST(@intEntityCustomerLocationId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@item_no = '''')
		BEGIN
			SET @intItemId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@item_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''item_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intItemId = CONVERT(INT,@item_no)
				IF NOT EXISTS(Select TOP 1 1 from tblICItem Where intItemId = @intItemId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''item_no :''+CAST(@intItemId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@item_category = '''')
		BEGIN
			SET @intCategoryId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@item_category AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''item_category should be numeric''
			END
			ELSE 
			BEGIN
				SET @intCategoryId = CONVERT(INT,@item_category)
				IF NOT EXISTS(Select TOP 1 1 from tblICItem Where intCategoryId = @intCategoryId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''item_category :''+CAST(@intCategoryId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@tax_code = '''')
		BEGIN
			SET @intTaxCodeId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@tax_code AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''tax_code should be numeric''
			END
			ELSE 
			BEGIN
				SET @intTaxCodeId = CONVERT(INT,@tax_code)
				IF NOT EXISTS(Select TOP 1 1 from tblSMTaxCode Where intTaxCodeId = @intTaxCodeId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''tax_code :''+CAST(@intTaxCodeId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@tax_class = '''')
		BEGIN
			SET @intTaxClassId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@tax_class AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''tax_class should be numeric''
			END
			ELSE 
			BEGIN
				SET @intTaxClassId = CONVERT(INT,@tax_class)
				IF NOT EXISTS(Select TOP 1 1 from tblSMTaxClass Where intTaxClassId = @intTaxClassId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''tax_class :''+CAST(@intTaxClassId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@state = '''')
		BEGIN
			SET @strState = NULL
		END
		ELSE
		BEGIN
			SET @strState = @state
		END

		IF(@exemption_no = '''')
		BEGIN
			SET @strException = NULL
		END
		ELSE
		BEGIN
			SET @strException = @exemption_no
		END

		IF(@partial = '''')
		BEGIN
			SET @dblPartialTax = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@partial AS NUMERIC(18,6)) IS NULL)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''partial should be numeric''
			END
			ELSE 
			BEGIN
				SET @dblPartialTax = CAST(@partial AS NUMERIC(18,6))
			END
		END
		
		IF(@start_date = '''')
		BEGIN
			SET @IsValid = 0
			SET @ValidationMessage = @ValidationMessage + '' ''+''start_date should not be Empty''
		
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@start_date AS DATETIME) IS NULL)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''start_date  should be a valid date format''
			END
			ELSE 
			BEGIN
				SET @dtmStartDate = CAST(@start_date AS DATETIME)
			END
		END

		IF(@end_date = '''')
		BEGIN
			SET @IsValid = 0
			SET @ValidationMessage = @ValidationMessage + '' ''+''end_date should not be Empty''
		
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@end_date AS DATETIME) IS NULL)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''end_date  should be a valid date format''
			END
			ELSE 
			BEGIN
				SET @dtmEndDate = CAST(@end_date AS DATETIME)
			END
		END

		IF(@card_no = '''')
		BEGIN
			SET @intCardId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@card_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''card_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intCardId = CONVERT(INT,@card_no)
				IF NOT EXISTS(Select TOP 1 1 from tblCFCard Where intCardId = @intCardId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''card_no :''+CAST(@intCardId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF(@vehicle_no = '''')
		BEGIN
			SET @intVehicleId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@vehicle_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''vehicle_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intVehicleId = CONVERT(INT,@vehicle_no)
				IF NOT EXISTS(Select TOP 1 1 from tblCFVehicle Where intVehicleId = @intVehicleId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''vehicle_no :''+CAST(@intVehicleId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		IF @IsValid = 1
		BEGIN
			INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
			   (
			    [intEntityCustomerId]
			   ,[intItemId]
			   ,[intCategoryId]
			   ,[intTaxCodeId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   ,[intEntityCustomerLocationId]
			   ,[dblPartialTax]
			   ,[intCardId]
			   ,[intVehicleId]
			   ,[intConcurrencyId]
			  )
			 SELECT
				@intEntityCustomerId,			
				@intItemId,				
				@intCategoryId,					
				@intTaxCodeId,					
				@intTaxClassId,				
				@strState,						
				@strException,					
				@dtmStartDate,					
				@dtmEndDate,					
				@intEntityCustomerLocationId,	
				@dblPartialTax,					
				@intCardId,						
				@intVehicleId,	
				0				
		END
	'
WHERE intCSVDynamicImportId = @NewHeaderId
	

	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'id', 'id', 1
	UNION All
	SELECT @NewHeaderId, 'customer_id', 'customer_id', 1
	UNION All
	SELECT @NewHeaderId, 'customer_location', 'customer_location', 0
	UNION All
	SELECT @NewHeaderId, 'item_no', 'item_no', 0
	UNION All
	SELECT @NewHeaderId, 'item_category', 'item_category', 0
	UNION All
	SELECT @NewHeaderId, 'tax_code', 'tax_code', 0
	UNION All
	SELECT @NewHeaderId, 'tax_class', 'tax_class', 0
	UNION All
	SELECT @NewHeaderId, 'state', 'state', 0
	UNION All
	SELECT @NewHeaderId, 'exemption_no', 'exemption_no', 0
	UNION All
	SELECT @NewHeaderId, 'partial', 'partial', 0
	UNION All
	SELECT @NewHeaderId, 'start_date', 'start_date', 0
	UNION All
	SELECT @NewHeaderId, 'end_date', 'end_date', 0
	UNION All
	SELECT @NewHeaderId, 'card_no', 'card_no', 0
	UNION All
	SELECT @NewHeaderId, 'vehicle_no', 'vehicle_no', 0			

--Customer Tax Exemption Import End





--Customer Entity Split Import Begin
SET @NewHeaderId = 9

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Import_Split','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Import_Split',
	strCommand = '
		DECLARE @entity_no					NVARCHAR(100)
		DECLARE @split_number				NVARCHAR(100)
		DECLARE @exception_categories		NVARCHAR(100)
		DECLARE @farm						NVARCHAR(100)
		DECLARE @description				NVARCHAR(100)
		DECLARE @entity_type				NVARCHAR(100)
		DECLARE @split_entity_no			NVARCHAR(100)
		DECLARE @percent					NVARCHAR(100)
		DECLARE @option						NVARCHAR(100)
		DECLARE @storage_type_code			NVARCHAR(100)

		SELECT
			@entity_no				= ''@entity_no@'',									
			@split_number			= ''@split_number@'',			
			@exception_categories	= ''@exception_categories@'',	
			@farm					= ''@farm@'',	
			@description			= ''@description@'',	
			@entity_type			= ''@entity_type@'',	
			@split_entity_no		= ''@split_entity_no@'',	
			@percent				= ''@percent@'',
			@option					= ''@option@'',
			@storage_type_code		= ''@storage_type_code@''
		
		DECLARE @intEntityId			INT
		DECLARE @strSplitNumber			NVARCHAR(100)
		DECLARE @strDescription			NVARCHAR(100)
		DECLARE @intFarmId 				INT
		DECLARE @strSplitType			NVARCHAR(100)


		DECLARE @ExpCategoryies			Table(Category NVARCHAR(100))

		DECLARE @dblSplitPercent		NUMERIC(18,6)
		DECLARE @strOption			    NVARCHAR(100)
		DECLARE @intStorageId 			INT



		DECLARE @IsValid INT = 1

		SELECT @IsValid = 1,
			@ValidationMessage	= ''''

		IF(@entity_no = '''')
		BEGIN
			SET @intEntityId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@entity_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''entity_no should be numeric''
			END
			ELSE 
			BEGIN
				SET @intEntityId = CONVERT(INT,@entity_no)
				IF NOT EXISTS(Select TOP 1 1 from tblEMEntity Where intEntityId = @intEntityId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''entity_no :''+CAST(@intEntityId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END

		SET @strSplitNumber = @split_number
		SET @strDescription = @description


		IF(@farm = '''')
		BEGIN
			SET @intFarmId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@farm AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''farm should be numeric''
			END
			ELSE 
			BEGIN
				SET @intFarmId = CONVERT(INT,@farm)
			END
		END

		SET @strSplitType = @entity_type

		INSERT INTO @ExpCategoryies
		SELECT Item from dbo.fnSplitString(@exception_categories,''.'')

		BEGIN TRY
			SELECT CONVERT(INT, Category) from @ExpCategoryies
		END TRY
		BEGIN CATCH
			SET @IsValid = 0
			SET @ValidationMessage = @ValidationMessage + '' ''+@exception_categories +''Categories Id should be numerics''
		END CATCH



		IF(@percent = '''')
		BEGIN
			SET @dblSplitPercent = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@percent AS NUMERIC(18,6)) IS NULL)
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''percent should be numeric''
			END
			ELSE 
			BEGIN
				SET @dblSplitPercent = CAST(REPLACE(@percent,''%'','''') AS NUMERIC(18,6))
			END
		END
		
		SET @strOption = @option

		IF(@storage_type_code = '''')
		BEGIN
			SET @intStorageId = NULL
		END
		ELSE
		BEGIN
			IF(TRY_PARSE(@entity_no AS INT) IS NULL )
			BEGIN
				SET @IsValid = 0
				SET @ValidationMessage = @ValidationMessage + '' ''+''storage_type_code should be numeric''
			END
			ELSE 
			BEGIN
				SET @intStorageId = CONVERT(INT,@entity_no)
				IF NOT EXISTS(Select TOP 1 1 from tblGRStorageType Where intStorageScheduleTypeId = @intStorageId )
				BEGIN
					SET @IsValid = 0
					SET @ValidationMessage = @ValidationMessage + '' ''+''storage_type_code :''+CAST(@intStorageId AS NVARCHAR(100))+'' is not Exist''
				END
			END
		END


		IF(@IsValid = 1)
		BEGIN

			DECLARE @NewSplitId INT

			IF EXISTS(SELECT TOP 1 NULL FROM tblEMEntitySplit WHERE strSplitNumber = @strSplitNumber)
			BEGIN
				SELECT TOP 1 @NewSplitId = intSplitId FROM tblEMEntitySplit WHERE strSplitNumber = @strSplitNumber
			END
			ELSE
			BEGIN
				INSERT INTO tblEMEntitySplit(
					intEntityId,
					strSplitNumber,
					strDescription,
					intFarmId,
					strSplitType,
					intConcurrencyId
				)
				SELECT
					@intEntityId,	
					@strSplitNumber,
					@strDescription,	
					@intFarmId,		
					@strSplitType,
					0	
			
				SELECT @NewSplitId = IDENT_CURRENT( ''tblEMEntitySplit'' ) 
			END


			INSERT INTO tblEMEntitySplitExceptionCategory(intSplitId,intCategoryId)
			SELECT @NewSplitId, CONVERT(INT, TEMP.Category) from @ExpCategoryies TEMP
			LEFT JOIN tblEMEntitySplitExceptionCategory	CUR
			ON CUR.intSplitId = @NewSplitId AND CONVERT(INT, TEMP.Category) = intCategoryId
			WHERE CUR.intCategoryId IS NULL


			IF NOT EXISTS(SELECT TOP 1 NULL from tblEMEntitySplitDetail WHERE @NewSplitId = intSplitId AND intEntityId = @intEntityId )
			BEGIN
				INSERT INTO tblEMEntitySplitDetail(
				intSplitId,
				intEntityId,
				dblSplitPercent,
				strOption,
				intStorageScheduleTypeId,
				intConcurrencyId
				)
				SELECT 
				@NewSplitId,
				@intEntityId,
				@dblSplitPercent,
				@strOption,
				@intStorageId,
				0
			END
			


		END
	'
WHERE intCSVDynamicImportId = @NewHeaderId
--Customer Entity Split Exemption Import End


					
		
INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entity_no', 'entity_no', 1
	UNION All
	SELECT @NewHeaderId, 'split_number', 'split_number', 1
	UNION All
	SELECT @NewHeaderId, 'exception_categories', 'exception_categories', 0
	UNION All
	SELECT @NewHeaderId, 'farm', 'farm', 0
	UNION All
	SELECT @NewHeaderId, 'description', 'description', 0
	UNION All
	SELECT @NewHeaderId, 'entity_type', 'entity_type', 0
	UNION All
	SELECT @NewHeaderId, 'split_entity_no', 'split_entity_no', 0
	UNION All
	SELECT @NewHeaderId, 'percent', 'percent', 0
	UNION All
	SELECT @NewHeaderId, 'exemption_no', 'exemption_no', 0
	UNION All
	SELECT @NewHeaderId, 'option', 'option', 0
	UNION All
	SELECT @NewHeaderId, 'storage_type_code', 'storage_type_code', 0


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