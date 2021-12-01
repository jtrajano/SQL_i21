CREATE PROCEDURE [dbo].[uspCTGetEmailInfo]
		@strId			NVARCHAR(MAX),
		@strMailType	NVARCHAR(100),
		@strURL	NVARCHAR(MAX),
		@intCurrentUserEntityId int
AS 
BEGIN
	DECLARE @strNumber					NVARCHAR(100),
			@intEntityId				INT,
			@strEntityName				NVARCHAR(200),
			@body						NVARCHAR(MAX) = '',
			@Subject					NVARCHAR(MAX) = '',
			@Filter						NVARCHAR(MAX) = '',
			@strIds						NVARCHAR(MAX),
			@intUniqueId				INT,
			@Id							INT,
			@routeScreen				NVARCHAR(50),
			@intSalespersonId			INT,
			@strDefaultContractReport	NVARCHAR(50),
			@strCustomerContract		NVARCHAR(50),
			@strThanks					NVARCHAR(MAX) = 'Thank you for your business.',
			@ysnContractSlspnOnEmail	BIT = 0,
			@strSalespersonName		NVARCHAR(255) = ''

	SELECT @strDefaultContractReport = strDefaultContractReport, @ysnContractSlspnOnEmail = ysnContractSlspnOnEmail FROM tblCTCompanyPreference

	DECLARE @loop TABLE
	(
		intUniqueId INT IDENTITY(1,1),
		Id INT,
		intEntityId INT,
		strNumber NVARCHAR(50),
		intSalespersonId INT
	)

	IF @strMailType = 'Item Contract'
	BEGIN
		SET @routeScreen = 'ItemContract'
		INSERT INTO @loop
		SELECT intItemContractHeaderId,intEntityId,strContractNumber,intSalespersonId FROM tblCTItemContractHeader WHERE intItemContractHeaderId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	IF @strMailType = 'Contract'
	BEGIN
		if (@ysnContractSlspnOnEmail = 1)
		BEGIN
			set @strSalespersonName = (select top 1 strName from tblEMEntity where intEntityId in (select distinct intSalespersonId from tblCTContractHeader where intContractHeaderId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))))
		END
		ELSE
		BEGIN
			set @strSalespersonName = (select top 1 strName from tblEMEntity where intEntityId = @intCurrentUserEntityId)
		END
		SET @routeScreen = 'Contract'
		INSERT INTO @loop
		SELECT intContractHeaderId,intEntityId,strContractNumber,intSalespersonId FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	ELSE IF @strMailType = 'Sequence'
	BEGIN
		
		SET @routeScreen = 'Contract'
		INSERT INTO @loop
		SELECT CD.intContractHeaderId,CH.intEntityId,CH.strContractNumber +'-'+ CAST(CD.intContractSeq AS NVARCHAR(10)) ,CH.intSalespersonId 
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE CD.intContractDetailId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	ELSE IF @strMailType = 'Sample Instruction'
	BEGIN
		--SET @routeScreen = 'Contract'
		--INSERT INTO @loop
		--SELECT intContractHeaderId,intEntityId,strContractNumber,intSalespersonId FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
		SET @routeScreen = 'Contract'
		INSERT INTO @loop
		SELECT CD.intContractHeaderId,CH.intEntityId,CH.strContractNumber +'-'+ CAST(CD.intContractSeq AS NVARCHAR(10)) ,CH.intSalespersonId 
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE CD.intContractDetailId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	ELSE IF @strMailType = 'Release Instruction'
	BEGIN
		SET @routeScreen = 'Contract'
		INSERT INTO @loop
		SELECT CD.intContractHeaderId,CH.intEntityId,CH.strContractNumber +'-'+ CAST(CD.intContractSeq AS NVARCHAR(10)) ,CH.intSalespersonId 
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE CD.intContractDetailId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	ELSE IF @strMailType = 'Release Instructions'
	BEGIN
		SET @routeScreen = 'Contract'
		INSERT INTO @loop
		SELECT CD.intContractHeaderId,CH.intEntityId,CH.strContractNumber +'-'+ CAST(CD.intContractSeq AS NVARCHAR(10)) + '-' + RI.strReleaseNumber ,CH.intSalespersonId 
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		INNER JOIN tblCTContractReleaseInstruction RI ON RI.intContractDetailId = CD.intContractDetailId
		WHERE RI.intContractReleaseInstructionId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	ELSE IF @strMailType = 'Price Contract'
	BEGIN
		SET @routeScreen = 'PriceContract'
		INSERT	INTO @loop
		SELECT	PF.intPriceFixationId,
				CH.intEntityId,
				CH.strContractNumber,
				CH.intSalespersonId
		FROM	tblCTContractHeader CH
		JOIN	tblCTPriceFixation	PF	ON	PF.intContractHeaderId	=	CH.intContractHeaderId
		WHERE	PF.intPriceFixationId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END

	SELECT @intEntityId = intEntityId FROM @loop
	SELECT @strEntityName = strName FROM tblEMEntity WHERE intEntityId = @intEntityId

	SELECT @intSalespersonId = intSalespersonId FROM @loop

	IF @strMailType = 'Contract'
	BEGIN
		SELECT	@strIds	=	STUFF(															
										(
											SELECT	DISTINCT												
													'|^|' +	LTRIM(intEntityContactId)
											FROM	vyuCTEntityToContact 
											WHERE	intEntityId = @intEntityId
											AND		ISNULL(strEmail,'') <> ''
											AND		strEmailDistributionOption LIKE '%Contracts%'
											FOR XML PATH('')
										),1,3, ''
									)
				
		FROM	vyuCTEntityToContact CH
		WHERE	intEntityId = @intEntityId
	END
	ELSE
	BEGIN
		SELECT	@strIds	=	STUFF(															
										(
											SELECT	DISTINCT												
													'|^|' +	LTRIM(intEntityContactId)
											FROM	vyuCTEntityToContact 
											WHERE	intEntityId = @intEntityId
											AND		ISNULL(strEmail,'') <> ''
											FOR XML PATH('')
										),1,3, ''
									)
				
		FROM	vyuCTEntityToContact CH
		WHERE	intEntityId = @intEntityId
	END
	IF EXISTS ( 
	SELECT	DISTINCT	1 
	FROM	vyuCTEntityToContact 
	WHERE	intEntityId = @intEntityId
	AND		ISNULL(strEmail,'') <> '' 
	AND     strEmail NOT LIKE  '_%@__%.__%' )

	BEGIN 
		RAISERROR('Entity has invalid Email Address.', 16, 1);
		RETURN;
	END

	SELECT	@strNumber	=	STUFF(															
									(
										SELECT	DISTINCT												
												', ' +	LTRIM(strNumber)
										FROM	@loop
										FOR XML PATH('')
									),1,2, ''
								)
				
	FROM	@loop CH

	SET @Subject = @strMailType + ' - ' + @strNumber

	IF @strMailType = 'Sample Instruction'
	BEGIN
		SELECT @strCustomerContract = isnull(strCustomerContract,'') FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT TOP 1 Id FROM @loop)
		SET @Subject = 'Contract' + ' - ' + @strNumber + ' - Sample Instruction - Your ref. no. ' + @strCustomerContract
	END

	IF @strMailType = 'Release Instruction'
	BEGIN
		SELECT @strCustomerContract = isnull(strCustomerContract,'') FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT TOP 1 Id FROM @loop)
		SET @Subject = 'Contract' + ' - ' + @strNumber + ' - Release Instruction - Your ref. no. ' + @strCustomerContract
	END

	IF @strMailType = 'Release Instructions'
	BEGIN
		SELECT @strCustomerContract = strCustomerContract FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT TOP 1 Id FROM @loop)
		SET @Subject = 'Contract' + ' - ' + @strNumber + ' - Release Instruction - Your ref. no. ' + @strCustomerContract
	END

	IF @strMailType = 'Sequence'
	BEGIN
		SELECT @strCustomerContract = strCustomerContract FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT TOP 1 Id FROM @loop)
		SET @Subject = 'Contract' + ' - ' + @strNumber + ' -  Your ref. no. ' + @strCustomerContract
	END

	IF	@strDefaultContractReport	=	'ContractJDE' AND @strMailType = 'Price Contract'
	BEGIN
		SET @strMailType = 'Price Fixation'
		SEt @strThanks = 'This confirmation of Price Fixation is deemed to be correct and accepted by you unless explicitly objected in writing latest 24 hours after the price fixation date.'
	END

	SET @body +='<!DOCTYPE html>'
	SET @body +='<html>'
	SET @body +='<body>Dear <strong>'+@strEntityName+'</strong>, <br><br>'

	IF @strMailType <> 'Sample Instruction'
	BEGIN
		IF @strMailType = 'Price Contract'
			SET @body += 'Please find attached the price confirmation document.<br>'--'Please find attached the ' + LOWER(@strMailType) + '. <br>'
		
		ELSE IF @strMailType <> 'Release Instruction' AND @strMailType <> 'Release Instructions' and @strDefaultContractReport <> 'ContractJDE'
			SET @body += 'Please find attached the contract document.<br>'--'Please find attached the ' + LOWER(@strMailType) + '. <br>'

		ELSE
			  SET @body +='Please use the link below to open your ' + LOWER(@strMailType) + '. <br><br>'		

		SELECT @intUniqueId = MIN(intUniqueId) FROM @loop
		WHILE ISNULL(@intUniqueId,0) > 0
		BEGIN
			SELECT	@Id = Id,@strNumber = strNumber FROM @loop WHERE intUniqueId = @intUniqueId
			if (@strDefaultContractReport = 'ContractJDE')
			begin
				SELECT  @body += '<p><a href="'+@strURL+'#/CT/'+@routeScreen+'?routeId='+LTRIM(@Id)+'">'+@strMailType+' - '+@strNumber+'</a></p>'
			end
			SELECT	@intUniqueId = MIN(intUniqueId) FROM @loop WHERE intUniqueId > @intUniqueId
		END
	END
	
	IF @strMailType = 'Sample Instruction'
	BEGIN
		SELECT  @body += 'Please find attached the sample instructions for contract - ' + @strNumber + '(Your ref. no. '+ @strCustomerContract +')'
	END

	IF @strMailType = 'Release Instruction'
	BEGIN
		SELECT  @body += 'Please find attached the release instructions for contract - ' + @strNumber + '(Your ref. no. '+ @strCustomerContract +')'
	END	

	IF @strMailType = 'Release Instructions'
	BEGIN
		SELECT  @body += 'Please find attached the release instructions for contract - ' + @strNumber + '(Your ref. no. '+ @strCustomerContract +')'
	END	

	IF (@strMailType IN ('Sample Instruction', 'Release Instruction', 'Release Instructions') or (@strMailType = 'Contract' and @strDefaultContractReport = 'ContractJDE'))
		SET @body += '<br>'
	SET @body +=@strThanks+'<br><br>'
	SET @body +='Sincerely, <br>'
		
	if (@strMailType = 'Contract')
	BEGIN
		SET @body +=@strSalespersonName
	END
	ELSE
	BEGIN
		SET @body +='#SIGNATURE#'
	END

	if (@strDefaultContractReport = 'ContractJDE')
	begin
		SET @body +='<br><strong>Please do not reply to this e-mail, this is sent from an unattended mail box.</strong>'
	end
	SET @body +='</html>'

	SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'
	
	SELECT @Subject AS strSubject,@Filter AS strFilters,@body AS strMessage, @intSalespersonId AS intSalespersonId
END