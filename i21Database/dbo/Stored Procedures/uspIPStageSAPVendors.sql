CREATE PROCEDURE [dbo].[uspIPStageSAPVendors]
	@strXml nvarchar(max),
	@strSessionId NVARCHAR(50)=''
AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
		
	DECLARE @idoc INT
	DECLARE @ErrMsg nvarchar(max)
	If ISNULL(@strSessionId,'')='' Set  @strSessionId=NEWID()

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	DECLARE @tblVendor TABLE (
		strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strAddress NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strAddress1 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strCity NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strCountry NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strZipCode NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strPhone NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strTaxNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strFLOId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		dtmCreated DATETIME NULL DEFAULT((getdate())),
		strCreatedUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strMarkForDeletion NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

	DECLARE @tblVendorContact TABLE (
		[strAccountNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strFirstName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strLastName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	 )

	INSERT INTO @tblVendor (
		strName
		,strAddress
		,strAddress1
		,strCity
		,strCountry
		,strZipCode
		,strPhone
		,strAccountNo
		,strTaxNo
		,strFLOId
		,dtmCreated
		,strCreatedUserName
		,strMarkForDeletion
		,strTerm
		,strCurrency
		)
	SELECT NAME1
		,STRAS
		,PFACH
		,ORT01
		,LAND1
		,PSTL2
		,TELF1
		,LIFNR
		,STCEG
		,KTOKK
		,CASE WHEN ISDATE(ERDAT)=0 THEN NULL ELSE ERDAT END
		,ERNAM
		,LOEVM
		,ZTERM
		,WAERS
	FROM OPENXML(@idoc, 'CREMAS06/IDOC/E1LFA1M', 2) WITH (
			 NAME1 NVARCHAR(100)
			,STRAS NVARCHAR(MAX)
			,PFACH NVARCHAR(MAX)
			,ORT01 NVARCHAR(MAX)
			,LAND1 NVARCHAR(MAX)
			,PSTL2 NVARCHAR(MAX)
			,TELF1 NVARCHAR(50)
			,LIFNR NVARCHAR(50)
			,STCEG NVARCHAR(50)
			,KTOKK NVARCHAR(100)
			,ERDAT NVARCHAR(50)
			,ERNAM NVARCHAR(100)
			,LOEVM NVARCHAR(50)
			,ZTERM NVARCHAR(100) 'E1LFM1M/ZTERM'
			,WAERS NVARCHAR(50) 'E1LFM1M/WAERS'
			)

	If NOT Exists (Select 1 From @tblVendor)
		RaisError('Unable to process. Xml tag (CREMAS06/IDOC/E1LFA1M) not found.',16,1)

	Insert Into @tblVendorContact(strAccountNo,strFirstName,strLastName,strPhone)
		SELECT
		 LIFNR 
		,NAMEV
		,NAME1
		,TELF1
	FROM OPENXML(@idoc, 'CREMAS06/IDOC/E1LFA1M/E1KNVKM', 2) WITH (
			 LIFNR NVARCHAR(50) '../LIFNR'
			,NAMEV NVARCHAR(100)
			,NAME1 NVARCHAR(100)
			,TELF1 NVARCHAR(50)
	)

	--if contact name not there use acc no as contact name
	Insert Into @tblVendorContact(strAccountNo,strFirstName,strLastName,strPhone)
	Select strAccountNo,strAccountNo,'',''
	From @tblVendor Where strAccountNo NOT IN (Select strAccountNo From @tblVendorContact)

	Begin Tran

	--Add to Staging tables
	Insert into tblIPEntityStage(strName,strAddress,strAddress1,strCity,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,dtmCreated,strCreatedUserName,strEntityType,strCurrency,strTerm,ysnDeleted,strSessionId)
	Select strName,strAddress,strAddress1,strCity,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,dtmCreated,strCreatedUserName,'Vendor',strCurrency,strTerm,CASE WHEN ISNULL(strMarkForDeletion,'')='X' THEN 1 ELSE 0 END,@strSessionId
	From @tblVendor

	Insert Into tblIPEntityContactStage(intStageEntityId,strEntityName,strFirstName,strLastName,strPhone)
	Select s.intStageEntityId,vc.strAccountNo,vc.strFirstName,vc.strLastName,vc.strPhone
	From @tblVendorContact vc 
	Join tblIPEntityStage s on s.strAccountNo=vc.strAccountNo

	Commit Tran

	Select TOP 1 strAccountNo AS strInfo1,strName AS strInfo2,@strSessionId AS strSessionId From @tblVendor

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH