CREATE PROCEDURE [dbo].[uspIPProcessSAPVendors]
@strSessionId NVARCHAR(50)=''
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intMinVendor INT
Declare @strVendorName nvarchar(100)
Declare @ErrMsg nvarchar(max)
Declare @intStageEntityId int
Declare @intNewStageEntityId int
Declare @intEntityId int
Declare @strEntityNo NVARCHAR(50)
Declare @strTerm NVARCHAR(100)
Declare @intTermId int
Declare @strCurrency NVARCHAR(50)
Declare @intCurrencyId Int
Declare @intEntityLocationId Int
Declare @strCity NVARCHAR(MAX)
Declare @strCountry NVARCHAR(MAX)
Declare @strZipCode NVARCHAR(MAX)
Declare @strAddress NVARCHAR(MAX)
Declare @strAddress1 NVARCHAR(MAX)
Declare @strAccountNo NVARCHAR(100)
Declare @strTaxNo NVARCHAR(100)
Declare @strFLOId NVARCHAR(100)
Declare @intEntityContactId Int
Declare @strPhone NVARCHAR(100)
Declare @strJson NVARCHAR(Max)
Declare @dtmDate DateTime
Declare @intUserId Int
Declare @strUserName NVARCHAR(100)
Declare @intCountryId INT
Declare @ysnDeleted bit
Declare @strFinalErrMsg NVARCHAR(MAX)=''

DECLARE @tblEntityContactIdOutput table (intEntityId int)

If ISNULL(@strSessionId,'')=''
	Select @intMinVendor=MIN(intStageEntityId) From tblIPEntityStage Where strEntityType='Vendor'
Else
	Select @intMinVendor=MIN(intStageEntityId) From tblIPEntityStage Where strEntityType='Vendor' AND strSessionId=@strSessionId

While(@intMinVendor is not null)
Begin
Begin Try

Set @strVendorName = NULL
Set @intEntityId = NULL
Set @strEntityNo = NULL
Set @strTerm = NULL
Set @intTermId = NULL
Set @strCurrency = NULL
Set @intCurrencyId = NULL
Set @intEntityLocationId = NULL
Set @strCity = NULL
Set @strCountry = NULL
Set @strZipCode = NULL
Set @strAddress = NULL
Set @strAddress1 = NULL
Set @strAccountNo = NULL
Set @strTaxNo = NULL
Set @strFLOId = NULL
Set @intEntityContactId = NULL
Set @strPhone = NULL
Set @intCountryId = NULL
Set @ysnDeleted = 0

Delete From @tblEntityContactIdOutput

Select @intStageEntityId=intStageEntityId,@strVendorName=strName,@strTerm=strTerm,@strCurrency=strCurrency,@strAccountNo=strAccountNo,@ysnDeleted=ISNULL(ysnDeleted,0)
From tblIPEntityStage Where strEntityType='Vendor' AND intStageEntityId=@intMinVendor

Select @strAccountNo AS strInfo1,@strVendorName AS strInfo2

Select @intEntityId=[intEntityId] From tblAPVendor Where strVendorAccountNum=@strAccountNo
Select @intTermId=intTermID From tblSMTerm Where strTermCode=@strTerm
Select @intCurrencyId=intCurrencyID From tblSMCurrency Where strCurrency=@strCurrency

If ISNULL(@strAccountNo,'')=''
	RaisError('Account No is required.',16,1)

Begin Tran

If ISNULL(@intEntityId,0)=0 --Create
Begin
	If @ysnDeleted=1
		RaisError('Vendor does not exist for deletion.',16,1)

	If ISNULL(@intTermId,0)=0
		RaisError('Term not found.',16,1)

	If ISNULL(@intCurrencyId,0)=0
		RaisError('Currency not found.',16,1)

	If ISNULL(@strVendorName,'')=''
		RaisError('Vendor Name is required.',16,1)

	If (Select ISNULL(strCity,'') From tblIPEntityStage Where intStageEntityId=@intStageEntityId)=''
		RaisError('City is required.',16,1)

	If (Select ISNULL(strAccountNo,'') From tblIPEntityStage Where intStageEntityId=@intStageEntityId)=''
		RaisError('Account No is required.',16,1)

	If Not Exists (Select 1 From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId)
		RaisError('Contact Name is required.',16,1)

	If (Select TOP 1 ISNULL(strFirstName,'') From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId)=''
		RaisError('Contact Name is required.',16,1)

	Select @intCountryId=c.intCountryID,@strCountry=c.strCountry 
	From tblIPEntityStage e Join  tblSMCountry c on e.strCountry=c.strISOCode Where intStageEntityId=@intStageEntityId

	Exec uspSMGetStartingNumber 43,@strEntityNo OUT

	--Entity
	Insert Into tblEMEntity(strName,strEntityNo,ysnActive,strContactNumber)
	Select strName,@strEntityNo,1,''
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intEntityId=SCOPE_IDENTITY()

	--Entity Type
	Insert Into tblEMEntityType(intEntityId,strType,intConcurrencyId)
	Values (@intEntityId,'Vendor',0)
	Insert Into tblEMEntityType(intEntityId,strType,intConcurrencyId)
	Values (@intEntityId,'Producer',0)

	--Entity Location
	Insert Into tblEMEntityLocation(intEntityId,strLocationName,strAddress,strCity,strCountry,strZipCode,intTermsId,ysnDefaultLocation,ysnActive)
	Select @intEntityId,LEFT(strCity,50),ISNULL(strAddress,'') + ' ' + ISNULL(strAddress1,'') ,strCity,@strCountry,strZipCode,@intTermId,1,1
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intEntityLocationId=SCOPE_IDENTITY()

	--Vendor
	Insert Into tblAPVendor([intEntityId],intCurrencyId,strVendorId,ysnPymtCtrlActive,strTaxNumber,intBillToId,intShipFromId,strFLOId,intVendorType,ysnWithholding,dblCreditLimit,strVendorAccountNum,intTermsId)
	Select @intEntityId,@intCurrencyId,@strEntityNo,1,strTaxNo,@intEntityLocationId,@intEntityLocationId,strFLOId,0,0,0.0,strAccountNo,@intTermId
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	--available to term list
	If not exists(Select 1 From tblAPVendorTerm Where intEntityVendorId=@intEntityId AND intTermId=@intTermId)
		Insert Into tblAPVendorTerm(intEntityVendorId,intTermId)
		Values(@intEntityId,@intTermId)

	--Add Contacts to Entity table
	Insert Into tblEMEntity(strName,strContactNumber,ysnActive)
	OUTPUT inserted.intEntityId INTO @tblEntityContactIdOutput
	Select ISNULL([strFirstName],'') + ' ' + ISNULL([strLastName],''),ISNULL([strFirstName],'') + ' ' + ISNULL([strLastName],''),1
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	--Map Contacts to Vendor
	Insert Into tblEMEntityToContact(intEntityId,intEntityContactId,intEntityLocationId,ysnPortalAccess)
	Select @intEntityId,intEntityId,@intEntityLocationId,0
	From @tblEntityContactIdOutput

	--Set default contact
	Update tblEMEntityToContact Set ysnDefaultContact=1 Where intEntityToContactId=(Select TOP 1 intEntityToContactId From tblEMEntityToContact Where intEntityId=@intEntityId)

	--Add Phone
	Insert Into tblEMEntityPhoneNumber(intEntityId,strPhone,intCountryId)
	Select t1.intEntityId,t2.strPhone,@intCountryId 
	From
	(Select ROW_NUMBER() OVER(ORDER BY intEntityId ASC) AS intRowNo,* from @tblEntityContactIdOutput) t1
	Join
	(Select ROW_NUMBER() OVER(ORDER BY intStageEntityContactId ASC) AS intRowNo,* from tblIPEntityContactStage Where intStageEntityId=@intStageEntityId) t2
	on t1.intRowNo=t2.intRowNo

	--Add Audit Trail Record
	Set @strJson='{"action":"Created","change":"Created - Record: ' + CONVERT(VARCHAR,@intEntityId) + '","keyValue":' + CONVERT(VARCHAR,@intEntityId) + ',"iconCls":"small-new-plus","leaf":true}'
	
	Select @dtmDate=DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), dtmCreated) From tblIPEntityStage Where intStageEntityId=@intStageEntityId
	If @dtmDate is null
		Set @dtmDate =  GETUTCDATE()

	Select @strUserName=strCreatedUserName From tblIPEntityStage Where intStageEntityId=@intStageEntityId
	Select @intUserId=e.intEntityId From tblEMEntity e Join tblEMEntityType et on e.intEntityId=et.intEntityId  Where e.strExternalERPId=@strUserName AND et.strType='User'

	Insert Into tblSMAuditLog(strActionType,strTransactionType,strRecordNo,strDescription,strRoute,strJsonData,dtmDate,intEntityId,intConcurrencyId)
	Values('Created','EntityManagement.view.Entity',@intEntityId,'','',@strJson,@dtmDate,@intUserId,1)
End
Else
Begin --Update
	If @ysnDeleted=1
		Begin
			Update tblEMEntity Set ysnActive=0 Where intEntityId=@intEntityId
			Update tblAPVendor Set ysnPymtCtrlActive=0,ysnDeleted=1 Where [intEntityId]=@intEntityId

			GOTO MOVE_TO_ARCHIVE
		End
	Else			
		Begin
			Update tblEMEntity Set ysnActive=1 Where intEntityId=@intEntityId
			Update tblAPVendor Set ysnPymtCtrlActive=1,ysnDeleted=0 Where [intEntityId]=@intEntityId
		End

	Select TOP 1 @intEntityLocationId=intEntityLocationId From tblEMEntityLocation Where intEntityId=@intEntityId

	Select @strAddress=strAddress,@strAddress1=strAddress1,@strCity=strCity,@strCountry=strCountry,@strZipCode=strZipCode,
	@strTaxNo=strTaxNo,@strFLOId=strFLOId 
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId
	
	--Update Address details
	If ISNULL(@strTerm,'/')<>'/' AND ISNULL(@intTermId,0)=0
		RaisError('Term not found.',16,1)

	If ISNULL(@strCurrency,'/')<>'/' AND ISNULL(@intCurrencyId,0)=0
		RaisError('Currency not found.',16,1)

	If ISNULL(@strCity,'/')<>'/' AND ISNULL(@strCity,'')=''
		RaisError('City is required.',16,1)

	If ISNULL(@strAddress,'/')<>'/'
	Begin
		If ISNULL(@strAddress1,'/')<>'/'
			Set @strAddress = @strAddress + ' '	+ @strAddress1

		Update tblEMEntityLocation Set strAddress=@strAddress Where intEntityLocationId=@intEntityLocationId
	End
		
	If ISNULL(@strCity,'/')<>'/'
		Update tblEMEntityLocation Set strLocationName=@strCity,strCity=@strCity Where intEntityLocationId=@intEntityLocationId

	If ISNULL(@strCountry,'/')<>'/'
		Update tblEMEntityLocation Set strCountry=(Select TOP 1 strCountry From tblSMCountry Where strISOCode=@strCountry) Where intEntityLocationId=@intEntityLocationId

	If ISNULL(@strZipCode,'/')<>'/'
		Update tblEMEntityLocation Set strZipCode=@strZipCode Where intEntityLocationId=@intEntityLocationId

	If ISNULL(@strTerm,'/')<>'/'
		Begin
			Update tblEMEntityLocation Set intTermsId=@intTermId Where intEntityLocationId=@intEntityLocationId
			Update tblAPVendor Set intTermsId=@intTermId Where [intEntityId]=@intEntityId

			--available to term list
			If not exists(Select 1 From tblAPVendorTerm Where intEntityVendorId=@intEntityId AND intTermId=@intTermId)
				Insert Into tblAPVendorTerm(intEntityVendorId,intTermId)
				Values(@intEntityId,@intTermId)
		End

	--Entity table Update
	If ISNULL(@strVendorName,'/')<>'/'
		Update tblEMEntity Set strName=@strVendorName,strContactNumber=@strVendorName Where intEntityId=@intEntityId

	--Vendor table update
	If ISNULL(@strCurrency,'/')<>'/'
		Update tblAPVendor Set intCurrencyId=@intCurrencyId Where [intEntityId]=@intEntityId

	If ISNULL(@strFLOId,'/')<>'/'
		Update tblAPVendor Set strFLOId=@strFLOId Where [intEntityId]=@intEntityId

	If ISNULL(@strTaxNo,'/')<>'/'
		Update tblAPVendor Set strTaxNumber=@strTaxNo Where [intEntityId]=@intEntityId

	--Update Phone
	Select @intEntityContactId=intEntityId From tblEMEntity Where strName=(Select TOP 1 ISNULL([strFirstName],'') + ' ' + ISNULL([strLastName],'')
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId)

	Select TOP 1 @strPhone=strPhone
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	If ISNULL(@strPhone,'/')<>'/'
		Update tblEMEntityPhoneNumber Set strPhone=@strPhone Where intEntityId=@intEntityContactId

	--Add New Contacts
	--Add Contacts to Entity table
	Insert Into tblEMEntity(strName,strContactNumber,ysnActive)
	OUTPUT inserted.intEntityId INTO @tblEntityContactIdOutput
	Select ISNULL([strFirstName],'') + ' ' + ISNULL([strLastName],''),ISNULL([strFirstName],'') + ' ' + ISNULL([strLastName],''),1
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId
	AND ISNULL([strFirstName],'') + ' ' + ISNULL([strLastName],'') NOT IN (Select strName From tblEMEntity)

	--Map Contacts to Vendor
	Insert Into tblEMEntityToContact(intEntityId,intEntityContactId,intEntityLocationId,ysnPortalAccess)
	Select @intEntityId,intEntityId,@intEntityLocationId,0
	From @tblEntityContactIdOutput

	--Add Phone
	Insert Into tblEMEntityPhoneNumber(intEntityId,strPhone,intCountryId)
	Select t1.intEntityId,t2.strPhone,(Select TOP 1 intCountryID From tblSMCountry Where strCountry=(Select TOP 1 strCountry From tblEMEntityLocation Where intEntityLocationId=@intEntityLocationId)) 
	From
	(Select ROW_NUMBER() OVER(ORDER BY intEntityId ASC) AS intRowNo,* from @tblEntityContactIdOutput) t1
	Join
	(Select ROW_NUMBER() OVER(ORDER BY intStageEntityContactId ASC) AS intRowNo,* from tblIPEntityContactStage Where intStageEntityId=@intStageEntityId) t2
	on t1.intRowNo=t2.intRowNo
End

	MOVE_TO_ARCHIVE:

	--Move to Archive
	Insert into tblIPEntityArchive(strName,strEntityType,strAddress,strAddress1,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,ysnDeleted,dtmCreated,strCreatedUserName,strSessionId)
	Select strName,strEntityType,strAddress,strAddress1,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,ysnDeleted,dtmCreated,strCreatedUserName,@strSessionId
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intNewStageEntityId=SCOPE_IDENTITY()

	Insert Into tblIPEntityContactArchive(intStageEntityId,strEntityName,strFirstName,strLastName,strPhone)
	Select @intNewStageEntityId,strEntityName,strFirstName,strLastName,strPhone
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	Delete From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Commit Tran

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()
	SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

	--Move to Error
	Insert into tblIPEntityError(strName,strEntityType,strAddress,strAddress1,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,ysnDeleted,dtmCreated,strCreatedUserName,strErrorMessage,strImportStatus,strSessionId)
	Select strName,strEntityType,strAddress,strAddress1,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,ysnDeleted,dtmCreated,strCreatedUserName,@ErrMsg,'Failed',@strSessionId
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intNewStageEntityId=SCOPE_IDENTITY()

	Insert Into tblIPEntityContactError(intStageEntityId,strEntityName,strFirstName,strLastName,strPhone)
	Select @intNewStageEntityId,strEntityName,strFirstName,strLastName,strPhone
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	Delete From tblIPEntityStage Where intStageEntityId=@intStageEntityId
END CATCH

	If ISNULL(@strSessionId,'')=''
		Select @intMinVendor=MIN(intStageEntityId) From tblIPEntityStage Where strEntityType='Vendor' AND intStageEntityId>@intMinVendor
	Else
		Select @intMinVendor=MIN(intStageEntityId) From tblIPEntityStage Where strEntityType='Vendor' AND intStageEntityId>@intMinVendor AND strSessionId=@strSessionId
End

If ISNULL(@strFinalErrMsg,'')<>'' RaisError(@strFinalErrMsg,16,1)

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH