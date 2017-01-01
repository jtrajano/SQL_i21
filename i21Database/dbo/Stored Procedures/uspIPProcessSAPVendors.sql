CREATE PROCEDURE [dbo].[uspIPProcessSAPVendors]
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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

Select TOP 1 @intStageEntityId=intStageEntityId,@strVendorName=strName,@strTerm=strTerm,@strCurrency=strCurrency From tblIPEntityStage Where strEntityType='Vendor'

Select @intEntityId=intEntityId From tblEMEntity Where strName=@strVendorName

Select @intTermId=intTermID From tblSMTerm Where strTerm=@strTerm

Select @intCurrencyId=intCurrencyID From tblSMCurrency Where strCurrency=@strCurrency

If ISNULL(@intTermId,0)=0
	RaisError('Term not found.',16,1)

If ISNULL(@intCurrencyId,0)=0
	RaisError('Currency not found.',16,1)

Begin Tran

If ISNULL(@intEntityId,0)=0 --Create
Begin
	Exec uspSMGetStartingNumber 43,@strEntityNo OUT

	--Entity
	Insert Into tblEMEntity(strName,strEntityNo,ysnActive,strContactNumber)
	Select strName,@strEntityNo,1,''
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intEntityId=SCOPE_IDENTITY()

	--Entity Type
	Insert Into tblEMEntityType(intEntityId,strType,intConcurrencyId)
	Values (@intEntityId,'Vendor',0)

	--Entity Location
	Insert Into tblEMEntityLocation(intEntityId,strLocationName,strAddress,strCity,strCountry,strZipCode,intTermsId,ysnDefaultLocation,ysnActive)
	Select @intEntityId,LEFT(@strVendorName,50),strAddress,strCity,strCountry,strZipCode,@intTermId,1,1
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intEntityLocationId=SCOPE_IDENTITY()

	--Vendor
	Insert Into tblAPVendor(intEntityVendorId,intCurrencyId,strVendorId,ysnPymtCtrlActive,strTaxNumber,intBillToId,intShipFromId,strFLOId,intVendorType,ysnWithholding,dblCreditLimit)
	Select @intEntityId,@intCurrencyId,@strEntityNo,1,strTaxNo,@intEntityLocationId,@intEntityLocationId,strFLOId,0,0,0.0
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	--Add Contacts to Entity table
	Insert Into tblEMEntity(strName,strContactNumber,ysnActive)
	Select strName,strName,1
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	--Map Contacts to Vendor
	Insert Into tblEMEntityToContact(intEntityId,intEntityContactId,intEntityLocationId,ysnPortalAccess)
	Select @intEntityId,intEntityId,@intEntityLocationId,0
	From tblEMEntity Where strName In (Select strName From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId)
	AND intEntityId>@intEntityId

	--Set default contact
	Update tblEMEntityToContact Set ysnDefaultContact=1 Where intEntityToContactId=(Select TOP 1 intEntityToContactId From tblEMEntityToContact Where intEntityId=@intEntityId)

	--Add Phone
	Insert Into tblEMEntityPhoneNumber(intEntityId,strPhone,intCountryId)
	Select intEntityId,ec.strPhone,(Select TOP 1 intCountryID From tblSMCountry Where strCountry=(Select strCountry From tblEMEntityLocation Where intEntityLocationId=@intEntityLocationId))
	From tblEMEntity e Join tblIPEntityContactStage ec on e.strName=ec.strName 
	Where ec.intStageEntityId=@intStageEntityId
	AND intEntityId>@intEntityId
End
Else
Begin --Update
	Update tblEMEntityLocation 
	Set strAddress=(Select strAddress From tblIPEntityStage Where intStageEntityId=@intStageEntityId),
	strCity=(Select strCity From tblIPEntityStage Where intStageEntityId=@intStageEntityId),
	strCountry=(Select strCountry From tblIPEntityStage Where intStageEntityId=@intStageEntityId),
	strZipCode=(Select strZipCode From tblIPEntityStage Where intStageEntityId=@intStageEntityId),
	intTermsId=@intTermId
	Where intEntityLocationId=(Select TOP 1 intEntityLocationId From tblEMEntityLocation Where intEntityId=@intEntityId)
End

	--Move to Archive
	Insert into tblIPEntityArchive(strName,strEntityType,strAddress,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,dtmCreated,strCreatedUserName)
	Select strName,strEntityType,strAddress,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,dtmCreated,strCreatedUserName
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intNewStageEntityId=SCOPE_IDENTITY()

	Insert Into tblIPEntityContactArchive(intStageEntityId,strEntityName,strName,strFirstName,strPhone)
	Select @intNewStageEntityId,@strVendorName,strName,strFirstName,strPhone
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	Delete From tblIPEntityStage Where intStageEntityId=@intStageEntityId
	Delete From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	Commit Tran

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	--Move to Error
	Insert into tblIPEntityError(strName,strEntityType,strAddress,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,dtmCreated,strCreatedUserName,strErrorMessage,strImportStatus)
	Select strName,strEntityType,strAddress,strCity,strState,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,strTerm,strCurrency,dtmCreated,strCreatedUserName,@ErrMsg,'Failed'
	From tblIPEntityStage Where intStageEntityId=@intStageEntityId

	Select @intNewStageEntityId=SCOPE_IDENTITY()

	Insert Into tblIPEntityContactError(intStageEntityId,strEntityName,strName,strFirstName,strPhone)
	Select @intNewStageEntityId,@strVendorName,strName,strFirstName,strPhone
	From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	Delete From tblIPEntityStage Where intStageEntityId=@intStageEntityId
	Delete From tblIPEntityContactStage Where intStageEntityId=@intStageEntityId

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH