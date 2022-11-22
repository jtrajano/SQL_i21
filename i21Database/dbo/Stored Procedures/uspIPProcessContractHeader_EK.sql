CREATE PROCEDURE uspIPProcessContractHeader_EK @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@strError NVARCHAR(MAX)
	DECLARE @intActionId INT
		,@Date DATETIME = GETDATE()
		,@UTCDate DATETIME = GETUTCDATE()
	DECLARE @SingleAuditLogParam SingleAuditLogParam
	DECLARE @intContractHeaderStageId INT
		,@strContractNo NVARCHAR(50)
		,@dtmContractDate DATETIME
		,@strVendorAccountNo NVARCHAR(100)
		,@strLocation NVARCHAR(50)
		,@strCommodity NVARCHAR(50)
		,@strTermsCode NVARCHAR(50)
		,@strIncoTerm NVARCHAR(100)
		,@strIncoTermLocation NVARCHAR(100)
		,@strSalesPerson NVARCHAR(100)
		,@dblContractValue NUMERIC(18, 6)
		,@strCurrency NVARCHAR(40)
		,@dtmPeriodFrom DATETIME
		,@dtmPeriodTo DATETIME
		,@strStatus NVARCHAR(50)
		,@strBuyingOrderNo NVARCHAR(50)
	DECLARE @intContractHeaderId INT
		,@intEntityId INT
		,@intCompanyLocationId INT
		,@intCommodityId INT
		,@intTermId INT
		,@intFreightTermId INT
		,@intINCOLocationTypeId INT
		,@intCountryId INT
		,@intSalespersonId INT
		,@intValueCurrencyId INT
	DECLARE @intCommodityUOMId INT
		,@intPricingTypeId INT
		,@strOrgContractNo NVARCHAR(50)
	DECLARE @tblIPContractHeaderStage TABLE (intContractHeaderStageId INT)

	INSERT INTO @tblIPContractHeaderStage (intContractHeaderStageId)
	SELECT intContractHeaderStageId
	FROM tblIPContractHeaderStage
	WHERE intStatusId IS NULL

	SELECT @intContractHeaderStageId = MIN(intContractHeaderStageId)
	FROM @tblIPContractHeaderStage

	IF @intContractHeaderStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPContractHeaderStage S
	JOIN @tblIPContractHeaderStage TS ON TS.intContractHeaderStageId = S.intContractHeaderStageId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strContractNo, '') + ', '
	FROM @tblIPContractHeaderStage a
	JOIN tblIPContractHeaderStage b ON a.intContractHeaderStageId = b.intContractHeaderStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strBuyingOrderNo, '') + ', '
	FROM (
		SELECT DISTINCT b.strBuyingOrderNo
		FROM @tblIPContractHeaderStage a
		JOIN tblIPContractHeaderStage b ON a.intContractHeaderStageId = b.intContractHeaderStageId
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intContractHeaderStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intActionId = NULL

			SELECT @strContractNo = NULL
				,@dtmContractDate = NULL
				,@strVendorAccountNo = NULL
				,@strLocation = NULL
				,@strCommodity = NULL
				,@strTermsCode = NULL
				,@strIncoTerm = NULL
				,@strIncoTermLocation = NULL
				,@strSalesPerson = NULL
				,@dblContractValue = NULL
				,@strCurrency = NULL
				,@dtmPeriodFrom = NULL
				,@dtmPeriodTo = NULL
				,@strStatus = NULL
				,@strBuyingOrderNo = NULL

			SELECT @intContractHeaderId = NULL
				,@intEntityId = NULL
				,@intCompanyLocationId = NULL
				,@intCommodityId = NULL
				,@intTermId = NULL
				,@intFreightTermId = NULL
				,@intINCOLocationTypeId = NULL
				,@intCountryId = NULL
				,@intSalespersonId = NULL
				,@intValueCurrencyId = NULL

			SELECT @intCommodityUOMId = NULL
				,@intPricingTypeId = NULL
				,@strOrgContractNo = NULL

			SELECT @strContractNo = strContractNo
				,@dtmContractDate = dtmContractDate
				,@strVendorAccountNo = strVendorAccountNo
				,@strLocation = strLocation
				,@strCommodity = strCommodity
				,@strTermsCode = strTermsCode
				,@strIncoTerm = strIncoTerm
				,@strIncoTermLocation = strIncoTermLocation
				,@strSalesPerson = strSalesPerson
				,@dblContractValue = dblContractValue
				,@strCurrency = strCurrency
				,@dtmPeriodFrom = dtmPeriodFrom
				,@dtmPeriodTo = dtmPeriodTo
				,@strStatus = strStatus
				,@strBuyingOrderNo = strBuyingOrderNo
			FROM tblIPContractHeaderStage
			WHERE intContractHeaderStageId = @intContractHeaderStageId

			IF ISNULL(@strContractNo, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Contract No. '
						,16
						,1
						)
			END

			SELECT @intContractHeaderId = intContractHeaderId
				,@strOrgContractNo = strContractNumber
			FROM dbo.tblCTContractHeader WITH (NOLOCK)
			WHERE strCustomerContract = @strContractNo

			IF @intContractHeaderId IS NOT NULL
				SELECT @intActionId = 2 --Update
			ELSE
				SELECT @intActionId = 1 --Create

			IF ISNULL(@strStatus, '') = 'Cancel'
			BEGIN
				SELECT @intActionId = 3 --Cancel

				IF @intContractHeaderId IS NULL
				BEGIN
					SELECT @strError = 'Contract No ' + @strContractNo + ' is not availble. '

					RAISERROR (
							@strError
							,16
							,1
							)
				END
			END

			IF @dtmContractDate IS NULL
			BEGIN
				RAISERROR (
						'Invalid Contract Date. '
						,16
						,1
						)
			END

			SELECT @intEntityId = t.intEntityId
			FROM dbo.tblEMEntity t WITH (NOLOCK)
			JOIN dbo.tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
			JOIN tblAPVendor V WITH (NOLOCK) ON V.intEntityId = t.intEntityId
			WHERE ET.strType = 'Vendor'
				AND V.strVendorAccountNum = @strVendorAccountNo

			IF ISNULL(@intEntityId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Vendor. '
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
			WHERE strLocationName = @strLocation

			IF ISNULL(@intCompanyLocationId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Location. '
						,16
						,1
						)
			END

			SELECT @intCommodityId = intCommodityId
			FROM dbo.tblICCommodity WITH (NOLOCK)
			WHERE strCommodityCode = @strCommodity

			IF ISNULL(@intCommodityId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Commodity. '
						,16
						,1
						)
			END

			IF ISNULL(@strTermsCode, '') <> ''
			BEGIN
				SELECT @intTermId = intTermID
				FROM dbo.tblSMTerm WITH (NOLOCK)
				WHERE strTerm = @strTermsCode

				IF ISNULL(@intTermId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Terms Code. '
							,16
							,1
							)
				END
			END

			SELECT @intFreightTermId = intFreightTermId
			FROM dbo.tblSMFreightTerms WITH (NOLOCK)
			WHERE strFreightTerm = @strIncoTerm

			IF @intFreightTermId IS NULL
			BEGIN
				SELECT @intFreightTermId = intFreightTermId
				FROM dbo.tblSMFreightTerms WITH (NOLOCK)
				WHERE strFreightTerm = 'FOB'
			END

			IF ISNULL(@strIncoTermLocation, '') <> ''
			BEGIN
				SELECT @intINCOLocationTypeId = intCityId
					,@intCountryId = intCountryId
				FROM dbo.tblSMCity WITH (NOLOCK)
				WHERE strCity = @strIncoTermLocation

				IF ISNULL(@intINCOLocationTypeId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Inco Term Location. '
							,16
							,1
							)
				END
			END

			SELECT @intSalespersonId = t.intEntityId
			FROM dbo.tblEMEntity t WITH (NOLOCK)
			JOIN dbo.tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'Salesperson'
				AND t.strName = @strSalesPerson

			IF ISNULL(@intSalespersonId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Sales Person. '
						,16
						,1
						)
			END

			IF ISNULL(@dblContractValue, 0) <= 0
			BEGIN
				RAISERROR (
						'Contract Value should be greater than 0. '
						,16
						,1
						)
			END

			SELECT @intValueCurrencyId = intCurrencyID
			FROM dbo.tblSMCurrency WITH (NOLOCK)
			WHERE strCurrency = @strCurrency

			IF ISNULL(@intValueCurrencyId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Currency. '
						,16
						,1
						)
			END

			IF @dtmPeriodFrom IS NULL
			BEGIN
				RAISERROR (
						'Invalid Period From. '
						,16
						,1
						)
			END

			IF @dtmPeriodTo IS NULL
			BEGIN
				RAISERROR (
						'Invalid Period To. '
						,16
						,1
						)
			END

			IF @dtmPeriodTo < @dtmPeriodFrom
			BEGIN
				RAISERROR (
						'Period To should be greater than Period From. '
						,16
						,1
						)
			END

			IF ISNULL(@strBuyingOrderNo, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Buying Order No. '
						,16
						,1
						)
			END

			-- Default Values
			SELECT @intCommodityUOMId = intCommodityUnitMeasureId
			FROM dbo.tblICCommodityUnitMeasure WITH (NOLOCK)
			WHERE intCommodityId = @intCommodityId
				AND (
					ysnDefault = 1
					OR ysnStockUnit = 1
					)

			SELECT @intPricingTypeId = intPricingTypeId
			FROM dbo.tblCTPricingType WITH (NOLOCK)
			WHERE strPricingType = 'Cash'

			IF @intActionId = 1
			BEGIN
				EXEC dbo.uspCTGenerateContractNumber @intPatternCode = 25
					,@intEntityId = @intUserId
					,@strPatternString = @strOrgContractNo OUTPUT

				INSERT INTO tblCTContractHeader (
					intConcurrencyId
					,intContractTypeId
					,intEntityId
					,intCommodityId
					,dblQuantity
					,intCommodityUOMId
					,intCompanyLocationId
					,strContractNumber
					,dtmContractDate
					,strCustomerContract
					,intSalespersonId
					,intTermId
					,intPricingTypeId
					,intFreightTermId
					,intINCOLocationTypeId
					,intCountryId
					,intCreatedById
					,dtmCreated
					,strContractBase
					,dblValue
					,intValueCurrencyId
					,dtmPeriodStartDate
					,dtmPeriodEndDate
					,strExternalContractNumber
					)
				SELECT 1
					,1
					,@intEntityId
					,@intCommodityId
					,0.0
					,@intCommodityUOMId
					,@intCompanyLocationId
					,@strOrgContractNo
					,@dtmContractDate
					,@strContractNo
					,@intSalespersonId
					,@intTermId
					,@intPricingTypeId
					,@intFreightTermId
					,@intINCOLocationTypeId
					,@intCountryId
					,@intUserId
					,@UTCDate
					,'Value'
					,@dblContractValue
					,@intValueCurrencyId
					,@dtmPeriodFrom
					,@dtmPeriodTo
					,@strBuyingOrderNo

				SELECT @intContractHeaderId = SCOPE_IDENTITY()

				--Audit Log
				DELETE
				FROM @SingleAuditLogParam

				INSERT INTO @SingleAuditLogParam (
					[Id]
					,[Action]
					,[Change]
					)
				SELECT 1
					,'Created'
					,''

				EXEC uspSMSingleAuditLog @screenName = 'ContractManagement.view.Contract'
					,@recordId = @intContractHeaderId
					,@entityId = @intUserId
					,@AuditLogParam = @SingleAuditLogParam
			END
			ELSE IF @intActionId = 2
			BEGIN
				UPDATE tblCTContractHeader
				SET intConcurrencyId = intConcurrencyId + 1
					,intEntityId = @intEntityId
					,intCompanyLocationId = @intCompanyLocationId
					,dtmContractDate = @dtmContractDate
					,intSalespersonId = @intSalespersonId
					,intTermId = @intTermId
					,intFreightTermId = @intFreightTermId
					,intINCOLocationTypeId = @intINCOLocationTypeId
					,intCountryId = @intCountryId
					,intLastModifiedById = @intUserId
					,dtmLastModified = @UTCDate
					,dblValue = @dblContractValue
					,intValueCurrencyId = @intValueCurrencyId
					,dtmPeriodStartDate = @dtmPeriodFrom
					,dtmPeriodEndDate = @dtmPeriodTo
					,strExternalContractNumber = @strBuyingOrderNo
				WHERE intContractHeaderId = @intContractHeaderId

				--Audit Log
				DELETE
				FROM @SingleAuditLogParam

				--	INSERT INTO @SingleAuditLogParam ([Id], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
				--	SELECT 1, 'Updated', 'Updated - Record: ' + CAST(@intContractHeaderId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
				
				--	INSERT INTO @SingleAuditLogParam ([Id], [Change], [From], [To], [Alias], [ParentId])
				--	SELECT 2, 'Vendor', 'Test 1', 'Test 2', NULL, 1
				--	UNION ALL
				--	SELECT 3, 'Country', 'Origin 1', 'Origin 2', NULL, 1
				
				--	EXEC uspSMSingleAuditLog
				--		@screenName     = 'ContractManagement.view.Contract',
				--		@recordId       = @intContractHeaderId,
				--		@entityId       = @intUserId,
				--		@AuditLogParam  = @SingleAuditLogParam
			END
			ELSE IF @intActionId = 3
			BEGIN
				IF EXISTS (
						SELECT TOP 1 1
						FROM tblCTContractDetail WITH (NOLOCK)
						WHERE intContractHeaderId = @intContractHeaderId
						)
				BEGIN
					RAISERROR (
							'Contract cannot be cancelled since line item already exists. '
							,16
							,1
							)
				END

				EXEC dbo.uspCTChangeContractStatus @strIds = @intContractHeaderId
					,@intContractStatusId = 3
					,@intEntityId = @intUserId
					,@strIdType = 'Header'
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPContractHeaderArchive (
				strSender
				,strContractNo
				,dtmContractDate
				,strVendorAccountNo
				,strLocation
				,strCommodity
				,strTermsCode
				,strIncoTerm
				,strIncoTermLocation
				,strSalesPerson
				,dblContractValue
				,strCurrency
				,dtmPeriodFrom
				,dtmPeriodTo
				,strStatus
				,strBuyingOrderNo
				)
			SELECT strSender
				,strContractNo
				,dtmContractDate
				,strVendorAccountNo
				,strLocation
				,strCommodity
				,strTermsCode
				,strIncoTerm
				,strIncoTermLocation
				,strSalesPerson
				,dblContractValue
				,strCurrency
				,dtmPeriodFrom
				,dtmPeriodTo
				,strStatus
				,strBuyingOrderNo
			FROM tblIPContractHeaderStage
			WHERE intContractHeaderStageId = @intContractHeaderStageId

			DELETE
			FROM tblIPContractHeaderStage
			WHERE intContractHeaderStageId = @intContractHeaderStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPContractHeaderError (
				strSender
				,strContractNo
				,dtmContractDate
				,strVendorAccountNo
				,strLocation
				,strCommodity
				,strTermsCode
				,strIncoTerm
				,strIncoTermLocation
				,strSalesPerson
				,dblContractValue
				,strCurrency
				,dtmPeriodFrom
				,dtmPeriodTo
				,strStatus
				,strBuyingOrderNo
				,strErrorMessage
				)
			SELECT strSender
				,strContractNo
				,dtmContractDate
				,strVendorAccountNo
				,strLocation
				,strCommodity
				,strTermsCode
				,strIncoTerm
				,strIncoTermLocation
				,strSalesPerson
				,dblContractValue
				,strCurrency
				,dtmPeriodFrom
				,dtmPeriodTo
				,strStatus
				,strBuyingOrderNo
				,@ErrMsg
			FROM tblIPContractHeaderStage
			WHERE intContractHeaderStageId = @intContractHeaderStageId

			DELETE
			FROM tblIPContractHeaderStage
			WHERE intContractHeaderStageId = @intContractHeaderStageId
		END CATCH

		SELECT @intContractHeaderStageId = MIN(intContractHeaderStageId)
		FROM @tblIPContractHeaderStage
		WHERE intContractHeaderStageId > @intContractHeaderStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPContractHeaderStage S
	JOIN @tblIPContractHeaderStage TS ON TS.intContractHeaderStageId = S.intContractHeaderStageId
	WHERE S.intStatusId = - 1

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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
