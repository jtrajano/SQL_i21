CREATE FUNCTION [dbo].[fnAPCreateVoucherData]
(
	@userId INT,
	@voucherPayables AS VoucherPayable READONLY
)
RETURNS @returntable TABLE
(
	[intPartitionId]		INT				NOT NULL,
	[intTermsId]			INT             NOT NULL,
	[dtmDueDate]			DATETIME        NOT NULL DEFAULT GETDATE(),
    [dtmDate]				DATETIME        NOT NULL DEFAULT GETDATE(),
	[dtmBillDate]			DATETIME NOT NULL DEFAULT GETDATE(), 
    [intAccountId]			INT             NOT NULL,
    [intEntityId]			INT NOT NULL , 
    [intEntityVendorId]		INT NOT NULL  , 
    [intTransactionType]	INT NOT NULL DEFAULT 0, 
	[strVendorOrderNumber]	NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[intShipToId]			INT NULL , 
	[strShipToAttention]	NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToAddress]		NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCity]			NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToState]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToZipCode]		NVARCHAR (12) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCountry]		NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToPhone]		NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromAttention]	NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromAddress]	NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCity]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromState]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromZipCode]	NVARCHAR (12) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCountry]	NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromPhone]		NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strReference]			NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
    [intShipFromId]			INT NULL , 
	[intShipFromEntityId]	INT NOT NULL,
	[intDeferredVoucherId]	INT NULL,
	[intPayToAddressId]		INT NULL , 
	[intShipViaId]			INT NULL , 
    [intStoreLocationId]	INT NULL , 
    [intContactId]			INT NULL , 
    [intOrderById]			INT NULL , 
	[intBookId]				INT NULL ,
	[intSubBookId]			INT NULL ,
    [intCurrencyId]			INT NOT NULL,
	[intSubCurrencyCents]	INT NOT NULL DEFAULT 1,
	[intDisbursementBank]			INT NULL,
	[strFinancingSourcedFrom] 		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[strFinancingTransactionNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN

	DECLARE @shipTo INT;
	DECLARE @currentDate DATETIME = GETDATE()
	DECLARE @apAccount INT;
	DECLARE @partitionId INT = 0;

	WITH voucherPayables AS (
		SELECT
			ROW_NUMBER() OVER(PARTITION BY intEntityVendorId,
										 intTransactionType,
										 intLocationId,
										 intShipToId,
										 intShipFromId,
										 intShipFromEntityId,
										 intPayToAddressId,
										 intCurrencyId,
										 strVendorOrderNumber,
										 strCheckComment
								ORDER BY intLineNo) AS intCountId
			,A.*
		FROM @voucherPayables A
		WHERE NULLIF(A.intPartitionId,0) IS NULL
		UNION ALL
		SELECT
			ROW_NUMBER() OVER(PARTITION BY intPartitionId ORDER BY intLineNo) AS intCountId
			,A.*
		FROM @voucherPayables A
		WHERE A.intPartitionId > 0
		-- WHERE EXISTS (
		-- 	SELECT * FROM (
		-- 		SELECT
		-- 			MIN(header.intVoucherPayableId) intVoucherPayableId,
		-- 			MIN(header.intEntityVendorId) intEntityVendorId,
		-- 			header.strVendorOrderNumber strVendorOrderNumber,
		-- 			MIN(header.intTransactionType) intTransactionType,
		-- 			MIN(header.intLocationId) intLocationId,
		-- 			MIN(header.intShipToId) intShipToId,
		-- 			MIN(header.intShipFromId) intShipFromId,
		-- 			MIN(header.intShipFromEntityId) intShipFromEntityId,
		-- 			MIN(header.intPayToAddressId) intPayToAddressId,
		-- 			MIN(header.intCurrencyId) intCurrencyId
		-- 		FROM @voucherPayables header
		-- 		GROUP BY 
		-- 			header.intEntityVendorId,
		-- 			header.strVendorOrderNumber,
		-- 			header.intTransactionType,
		-- 			header.intLocationId,
		-- 			header.intShipToId,
		-- 			header.intShipFromId,
		-- 			header.intShipFromEntityId,
		-- 			header.intPayToAddressId,
		-- 			header.intCurrencyId
		-- 	) filteredPayables
		-- 	WHERE filteredPayables.intVoucherPayableId = A.intVoucherPayableId
		-- )
	)

	INSERT @returntable
	(
		[intPartitionId]		,
		[intTermsId]			,
		[dtmDate]				,
		[dtmDueDate]			,
		[dtmBillDate]			,
		[intAccountId]			,
		[intEntityId]			,
		[intEntityVendorId]		,
		[intTransactionType]	,
		[strVendorOrderNumber]	,
		[strComment]			,
		[intShipToId]			,
		[strShipToAttention]	,
		[strShipToAddress]		,
		[strShipToCity]			,
		[strShipToState]		,
		[strShipToZipCode]		,
		[strShipToCountry]		,
		[strShipToPhone]		,
		[strShipFromAttention]	,
		[strShipFromAddress]	,
		[strShipFromCity]		,
		[strShipFromState]		,
		[strShipFromZipCode]	,
		[strShipFromCountry]	,
		[strShipFromPhone]		,
		[strReference]			,
		[intShipFromId]			,
		[intShipFromEntityId]	,
		[intDeferredVoucherId]	,
		[intPayToAddressId]		, 
		[intShipViaId]			,
		[intStoreLocationId]	,
		[intContactId]			,
		[intOrderById]			,
		[intBookId]				,
		[intSubBookId]			,
		[intCurrencyId]			,
		[intSubCurrencyCents]	,
		[intDisbursementBank]	,
		[strFinancingSourcedFrom],
		[strFinancingTransactionNumber]
	)
	SELECT
		[intPartitionId]		=	A.intPartitionId,
		[intTermsId]			=	termData.intTermID,
									-- CASE WHEN A.intTermId > 0 THEN A.intTermId --Voucher Payable data
									-- 	WHEN A.intShipFromId > 0 AND B2.intTermsId > 0 THEN B2.intTermsId --Voucher Payable 'Ship From' data
									-- 	WHEN B.intTermsId > 0 THEN B.intTermsId --default location
									-- ELSE vendor.intTermsId END, --vendor
		[dtmDate]				=	DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0),
		[dtmDueDate]			=	DATEADD(dd, DATEDIFF(dd, 0,dbo.fnGetDueDateBasedOnTerm(A.dtmDate, termData.intTermID)), 0),
		[dtmBillDate]			=	ISNULL(DATEADD(dd, DATEDIFF(dd, 0,A.dtmVoucherDate), 0), DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0)),
		[intAccountId]			=	CASE WHEN A.intAPAccount > 0 THEN A.intAPAccount
										WHEN A.intTransactionType IN (2, 13)
											THEN (CASE WHEN A.intLocationId > 0 THEN payableLoc.intPurchaseAdvAccount
												ELSE userCompLoc.intPurchaseAdvAccount END)
										ELSE (
											CASE WHEN A.intLocationId > 0 THEN payableLoc.intAPAccount
											ELSE userCompLoc.intAPAccount END
										) END,
		[intEntityId]			=	@userId,
		[intEntityVendorId]		=	A.intEntityVendorId,
		[intTransactionType]	=	A.intTransactionType,
		[strVendorOrderNumber]	=	A.strVendorOrderNumber,
		[strComment]			=	A.strCheckComment,
		[intShipToId]			=	CASE WHEN A.intLocationId > 0 THEN A.intLocationId ELSE userCompLoc.intCompanyLocationId END,
		[strShipToAttention]	=	NULL,
		[strShipToAddress]		=	CASE WHEN A.intLocationId > 0 THEN payableLoc.strAddress ELSE userCompLoc.strAddress END,
		[strShipToCity]			=	CASE WHEN A.intLocationId > 0 THEN payableLoc.strCity ELSE userCompLoc.strCity END,
		[strShipToState]		=	CASE WHEN A.intLocationId > 0 THEN payableLoc.strCountry ELSE userCompLoc.strCountry END,
		[strShipToZipCode]		=	CASE WHEN A.intLocationId > 0 THEN payableLoc.strPhone ELSE userCompLoc.strPhone END,
		[strShipToCountry]		=	CASE WHEN A.intLocationId > 0 THEN payableLoc.strStateProvince ELSE userCompLoc.strStateProvince END,
		[strShipToPhone]		=	CASE WHEN A.intLocationId > 0 THEN payableLoc.strZipPostalCode ELSE userCompLoc.strZipPostalCode END,
		[strShipFromAttention]	=	NULL,
		[strShipFromAddress]	=	shipFromData.strAddress,
									-- CASE WHEN A.intShipFromEntityId > 0 THEN shipFromEntityLoc.strAddress --ship from entity
									-- 	WHEN A.intShipFromId > 0 THEN B2.strAddress --voucher payable data
									-- ELSE B.strAddress END, --vendor default location
		[strShipFromCity]		=	shipFromData.strCity,
									-- CASE WHEN A.intShipFromEntityId > 0 THEN shipFromEntityLoc.strCity
									-- 	WHEN A.intShipFromId > 0 THEN B2.strCity
									-- ELSE B.strCity END,
		[strShipFromState]		=	shipFromData.strState,
									-- CASE WHEN A.intShipFromEntityId > 0 THEN shipFromEntityLoc.strState
									-- 	WHEN A.intShipFromId > 0 THEN B2.strState
									-- ELSE B.strState END,
		[strShipFromZipCode]	=	shipFromData.strZipCode,
									-- CASE WHEN A.intShipFromEntityId > 0 THEN shipFromEntityLoc.strZipCode
									-- 	WHEN A.intShipFromId > 0 THEN B2.strZipCode
									-- ELSE B.strZipCode END,
		[strShipFromCountry]	=	shipFromData.strCountry,
									-- CASE WHEN A.intShipFromEntityId > 0 THEN shipFromEntityLoc.strCountry
									-- 	WHEN A.intShipFromId > 0 THEN B2.strCountry
									-- ELSE B.strCountry END,
		[strShipFromPhone]		=	shipFromData.strPhone,
									-- CASE WHEN A.intShipFromEntityId > 0 THEN shipFromEntityLoc.strPhone
									-- 	WHEN A.intShipFromId > 0 THEN B2.strPhone
									-- ELSE B.strPhone END,
		[strReference]			=	A.strReference,
		[intShipFromId]			=	shipFromData.intEntityLocationId,
									-- CASE WHEN A.intShipFromEntityId > 0 THEN shipFromEntityLoc.intEntityLocationId --ship from entity
									-- 	WHEN A.intShipFromId > 0 THEN A.intShipFromId --voucher payable data
									-- ELSE B.intEntityLocationId END, --vendor default location
		[intShipFromEntityId]	=	CASE WHEN A.intShipFromEntityId > 0 THEN A.intShipFromEntityId
										ELSE A.intEntityVendorId
									END,
		[intDeferredVoucherId]	=	A.intDeferredVoucherId,
		[intPayToAddressId]		=	CASE WHEN A.intPayToAddressId > 0 THEN A.intPayToAddressId --Voucher Payable data
										WHEN A.intShipFromId > 0 AND A.intShipFromEntityId IS NULL THEN A.intShipFromId --Voucher Payable data
									ELSE shipFromData.intEntityLocationId END, --vendor default location
		[intShipViaId]			=	A.intShipViaId,
		[intStoreLocationId]	=	CASE WHEN A.intLocationId > 0 THEN A.intLocationId ELSE userCompLoc.intCompanyLocationId END,
		[intContactId]			=	C.intEntityContactId,
		[intOrderById]			=	@userId,
		[intBookId]				=	ISNULL(A.intBookId,ctBookEntities.intBookId),
		[intSubBookId]			=	ISNULL(A.intSubBookId,ctBookEntities.intSubBookId),
		[intCurrencyId]			=	CASE WHEN A.intCurrencyId > 0 THEN A.intCurrencyId 
									ELSE vendor.intCurrencyId END,
		[intSubCurrencyCents]	=	CASE WHEN A.intSubCurrencyCents > 0 THEN A.intSubCurrencyCents
									ELSE ISNULL(NULLIF(subCur.intCent, 0), 1) END,
		[intDisbursementBank]	= A.intDisbursementBank,
		[strFinancingSourcedFrom] = A.strFinancingSourcedFrom,
		[strFinancingTransactionNumber] = A.strFinancingTransactionNumber
	FROM voucherPayables A
	INNER JOIN tblAPVendor vendor ON A.intEntityVendorId = vendor.intEntityId
	-- LEFT JOIN tblEMEntityLocation B ON vendor.intEntityId = B.intEntityId AND B.ysnDefaultLocation = 1--vendor default location
	-- LEFT JOIN tblEMEntityLocation B2 ON B2.intEntityLocationId = A.intShipFromId AND B2.intEntityId = A.intEntityVendorId --voucher payable ship from vendor
	-- LEFT JOIN tblEMEntityLocation B3 ON B3.intEntityLocationId = A.intShipFromId AND B2.intEntityId = A.intShipFromEntityId --voucher payable ship from entity
	-- LEFT JOIN tblEMEntityLocation shipFromEntityLoc ON A.intShipFromEntityId = shipFromEntityLoc.intEntityId AND shipFromEntityLoc.ysnDefaultLocation = 1 --ship from entity location
	LEFT JOIN tblEMEntityToContact C ON A.intEntityVendorId = C.intEntityId AND C.ysnDefaultContact = 1
	LEFT JOIN tblSMCompanyLocation payableLoc ON A.intLocationId = payableLoc.intCompanyLocationId
	LEFT JOIN tblSMUserSecurity userData ON userData.intEntityId = @userId
	LEFT JOIN tblSMCompanyLocation userCompLoc ON userData.intCompanyLocationId = userCompLoc.intCompanyLocationId
	LEFT JOIN tblSMCurrency subCur ON subCur.intMainCurrencyId = A.intCurrencyId AND subCur.ysnSubCurrency = 1
	OUTER APPLY (
		SELECT TOP 1 *
		FROM (
			--There is a intShipFromEntityId and intShipFromId value and that intShipFromId is a valid location of intShipFromEntityId
			SELECT
				shipFromEntityLoc.*
			FROM tblEMEntityLocation shipFromEntityLoc
			WHERE A.intShipFromEntityId = shipFromEntityLoc.intEntityId 
			AND shipFromEntityLoc.intEntityLocationId = A.intShipFromId
			UNION ALL
			--There is a intShipFromEntityId and intShipFromId value is not valid or null
			SELECT
				shipFromEntityLoc.*
			FROM tblEMEntityLocation shipFromEntityLoc
			WHERE A.intShipFromEntityId = shipFromEntityLoc.intEntityId 
			AND shipFromEntityLoc.ysnDefaultLocation = 1
			UNION ALL
			--There is no intShipFromEntityId but there is intShipFromId and a valid ship from id of vendor
			SELECT
				vendorLoc.*
			FROM tblEMEntityLocation vendorLoc
			WHERE A.intEntityVendorId = vendorLoc.intEntityId 
			AND vendorLoc.intEntityLocationId = A.intShipFromId
			UNION ALL
			--There is no intShipFromEntityId and intShipFromId, use vendor default location
			SELECT
				vendorLoc.*
			FROM tblEMEntityLocation vendorLoc
			WHERE A.intEntityVendorId = vendorLoc.intEntityId 
			AND vendorLoc.ysnDefaultLocation = 1
		) shipFromHeirarchy
	) shipFromData
	OUTER APPLY (
		SELECT TOP 1 *
		FROM (
			--use deferred interest term
			SELECT
				term.*
			FROM tblSMTerm term
			INNER JOIN tblAPDeferredPaymentInterest deferredInterest
				ON deferredInterest.strTerm = term.strTerm AND A.intDeferredVoucherId > 0
			UNION ALL
			--There is term value received
			SELECT
				payableTerm.*
			FROM tblSMTerm payableTerm
			WHERE payableTerm.intTermID = A.intTermId
			UNION ALL
			--there is ship from received, use the term setup on that ship from
			SELECT
				shipFromTerm.*
			FROM tblEMEntityLocation shipFrom
			INNER JOIN tblSMTerm shipFromTerm ON shipFrom.intTermsId = shipFromTerm.intTermID
			WHERE shipFrom.intEntityLocationId = A.intShipFromId AND shipFrom.intEntityId = A.intEntityVendorId
			UNION ALL
			--use contract term
			SELECT
				defaultTerm.* 
			FROM  tblCTContractHeader CH
			INNER JOIN tblSMTerm defaultTerm ON  defaultTerm.intTermID = CH.intTermId
			WHERE A.intContractHeaderId = CH.intContractHeaderId  AND A.intContractHeaderId > 0
			UNION ALL
			--use vendor default location term
			SELECT
				shipFromTerm.*
			FROM tblEMEntityLocation defaultLoc
			INNER JOIN tblSMTerm shipFromTerm ON defaultLoc.intTermsId = shipFromTerm.intTermID
			WHERE defaultLoc.intEntityId = A.intEntityVendorId AND defaultLoc.ysnDefaultLocation = 1
			UNION ALL
			--use vendor default term
			SELECT
				defaultTerm.*
			FROM tblSMTerm defaultTerm
			WHERE defaultTerm.intTermID = vendor.intTermsId
		) termHeirarchy
	) termData
	OUTER APPLY (
		SELECT TOP 1
			bookEntity.intEntityId
			,bookEntity.intBookId
			,ctbook.strBook
			,bookEntity.intSubBookId
			,ctsubbook.strSubBook
		FROM tblCTBookVsEntity bookEntity
		INNER JOIN tblCTBook ctbook ON bookEntity.intBookId = ctbook.intBookId
		INNER JOIN tblCTSubBook ctsubbook ON bookEntity.intSubBookId = ctsubbook.intSubBookId
		WHERE bookEntity.intEntityId = A.intEntityVendorId
	) ctBookEntities
	WHERE A.intCountId = 1

	-- UPDATE A
	-- SET A.dtmDate = deferredInterest.dtmPaymentPostDate,
	-- 	A.dtmDueDate = deferredInterest.dtmPaymentDueDateOverride, 
	-- 	A.dtmBillDate = deferredInterest.dtmPaymentInvoiceDate,
	-- 	A.intTermsId = term.intTermID,
	-- 	A.intDeferredVoucherId = @currentVoucherId,
	-- 	A.strComment = deferredInterest.strCheckComment
	-- FROM tblAPBill A
	-- CROSS APPLY tblAPDeferredPaymentInterest deferredInterest
	-- INNER JOIN tblSMTerm term ON deferredInterest.strTerm = term.strTerm
	-- INNER JOIN @voucherCreated B ON A.intBillId = B.intBillId

	-- UPDATE A
	-- 	SET A.intDeferredVoucherId = @currentVoucherId
	-- FROM tblAPBillDetail A
	-- INNER JOIN @voucherCreated B ON A.intBillId = B.intBillId

	-- UPDATE A
	-- 	SET A.dtmDeferredInterestDate = deferredInterest.dtmPaymentDueDateOverride,
	-- 		A.dtmInterestAccruedThru = deferredInterest.dtmCalculationDate
	-- FROM tblAPBill A
	-- CROSS APPLY tblAPDeferredPaymentInterest deferredInterest
	-- INNER JOIN tblSMTerm term ON deferredInterest.strTerm = term.strTerm
	-- INNER JOIN @voucherCreated B ON A.intBillId = B.intBillId
	
	RETURN;
END